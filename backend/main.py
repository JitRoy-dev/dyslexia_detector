from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import torch
import torch.nn as nn
from PIL import Image
import io
import numpy as np
from typing import Dict
import uvicorn
import pytesseract
import cv2
import base64

app = FastAPI(title="Dyslexia Detection API")

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global model variable
model = None
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

class DyslexiaModel(nn.Module):
    def __init__(self, hidden_size=256):
        super(DyslexiaModel, self).__init__()
        
        # CNN layers for feature extraction
        self.cnn = nn.Sequential(
            nn.Conv2d(1, 64, kernel_size=3, padding=1),  # cnn.0
            nn.ReLU(),
            nn.MaxPool2d(2, 2),
            nn.Conv2d(64, 128, kernel_size=3, padding=1),  # cnn.3
            nn.ReLU(),
            nn.MaxPool2d(2, 2),
            nn.Conv2d(128, 256, kernel_size=3, padding=1),  # cnn.6
            nn.ReLU(),
            nn.Conv2d(256, 256, kernel_size=3, padding=1),  # cnn.8
            nn.ReLU(),
            nn.MaxPool2d((2, 1)),
            nn.Conv2d(256, 512, kernel_size=3, padding=1),  # cnn.11
            nn.ReLU(),
            nn.BatchNorm2d(512),  # cnn.13
            nn.Conv2d(512, 512, kernel_size=3, padding=1),  # cnn.14
            nn.ReLU(),
            nn.BatchNorm2d(512),  # cnn.16
            nn.MaxPool2d((2, 1)),
            nn.Conv2d(512, 512, kernel_size=2, padding=0),  # cnn.18
            nn.ReLU()
        )
        
        # Map to sequence (512 channels * 3 height = 1536)
        self.map_to_sequence = nn.Linear(1536, hidden_size)
        
        # Bidirectional GRU layers
        self.gru1 = nn.GRU(hidden_size, hidden_size, bidirectional=True, batch_first=True)
        self.gru2 = nn.GRU(hidden_size * 2, hidden_size, bidirectional=True, batch_first=True)
        
        # Classification head (binary classification)
        self.classification_head = nn.Sequential(
            nn.Linear(hidden_size * 2, 256),  # classification_head.0
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(256, 1)  # classification_head.3 (binary output)
        )
    
    def forward(self, x):
        # CNN feature extraction
        x = self.cnn(x)
        
        # Reshape for sequence processing
        batch_size, channels, height, width = x.size()
        x = x.permute(0, 3, 1, 2)  # [batch, width, channels, height]
        x = x.reshape(batch_size, width, channels * height)
        
        # Map to sequence
        x = self.map_to_sequence(x)
        
        # GRU layers
        x, _ = self.gru1(x)
        x, _ = self.gru2(x)
        
        # Global average pooling over sequence
        x = x.mean(dim=1)
        
        # Classification
        x = self.classification_head(x)
        
        return x

def load_model(model_path: str):
    """Load the trained PyTorch model"""
    global model
    try:
        # Option 1: If you saved the entire model (not recommended but simpler)
        # model = torch.load(model_path, map_location=device)
        
        # Option 2: If you saved only state_dict (recommended)
        # You need to define the architecture first, then load weights
        model = DyslexiaModel()
        model.load_state_dict(torch.load(model_path, map_location=device))
        
        model.to(device)
        model.eval()
        print(f"Model loaded successfully on {device}")
    except Exception as e:
        print(f"Error loading model: {e}")
        raise

def preprocess_image(image: Image.Image) -> torch.Tensor:
    """Preprocess image for model input"""
    # Convert to grayscale
    image = image.convert('L')
    
    # Resize to model input size: 64 height x 256 width
    image = image.resize((256, 64))  # PIL resize takes (width, height)
    
    # Convert to numpy array and normalize
    img_array = np.array(image) / 255.0
    
    # Convert to tensor and add batch and channel dimensions
    img_tensor = torch.from_numpy(img_array).float()
    img_tensor = img_tensor.unsqueeze(0).unsqueeze(0)  # Shape: [1, 1, 64, 256]
    
    return img_tensor.to(device)

def detect_text_in_image(image: Image.Image) -> Dict:
    """
    Detect if image contains text using OCR.
    Returns dict with has_text (bool), confidence (float), and grayscale_image (base64 string if no text)
    """
    try:
        # Convert PIL image to OpenCV format
        img_array = np.array(image)
        
        # Convert to grayscale if needed
        if len(img_array.shape) == 3:
            gray = cv2.cvtColor(img_array, cv2.COLOR_RGB2GRAY)
        else:
            gray = img_array
        
        # Apply preprocessing to improve OCR accuracy
        # Increase contrast
        gray = cv2.equalizeHist(gray)
        
        # Apply adaptive thresholding
        thresh = cv2.adaptiveThreshold(
            gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2
        )
        
        # Use pytesseract to detect text
        # Get detailed data including confidence scores
        ocr_data = pytesseract.image_to_data(thresh, output_type=pytesseract.Output.DICT)
        
        # Filter out low confidence detections and empty text
        valid_text = []
        confidences = []
        
        for i, text in enumerate(ocr_data['text']):
            conf = int(ocr_data['conf'][i])
            if conf > 30 and text.strip():  # Confidence threshold of 30%
                valid_text.append(text.strip())
                confidences.append(conf)
        
        # Determine if text was found
        has_text = len(valid_text) > 0
        avg_confidence = sum(confidences) / len(confidences) if confidences else 0
        
        # If no text found, convert image to grayscale and encode as base64
        grayscale_base64 = None
        if not has_text:
            # Convert to grayscale
            gray_image = Image.fromarray(gray)
            
            # Convert to base64
            buffered = io.BytesIO()
            gray_image.save(buffered, format="PNG")
            grayscale_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')
        
        return {
            "has_text": has_text,
            "confidence": float(avg_confidence),
            "text_count": len(valid_text),
            "grayscale_image": grayscale_base64
        }
    
    except Exception as e:
        print(f"Text detection error: {e}")
        # If OCR fails, assume no text and return grayscale version
        gray = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2GRAY) if len(np.array(image).shape) == 3 else np.array(image)
        gray_image = Image.fromarray(gray)
        buffered = io.BytesIO()
        gray_image.save(buffered, format="PNG")
        grayscale_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')
        
        return {
            "has_text": False,
            "confidence": 0.0,
            "text_count": 0,
            "grayscale_image": grayscale_base64,
            "error": str(e)
        }

@app.on_event("startup")
async def startup_event():
    """Load model on startup"""
    load_model("model/dyslexia_model.pth")

@app.get("/")
async def root():
    return {"message": "Dyslexia Detection API", "status": "running"}

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "device": str(device)
    }

@app.post("/predict")
async def predict(file: UploadFile = File(...)) -> Dict:
    """
    Predict dyslexia from handwritten image.
    First validates that the image contains text.
    """
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    try:
        # Read and process image
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        # Detect text in image
        text_detection = detect_text_in_image(image)
        
        # If no text detected, return error with grayscale image
        if not text_detection["has_text"]:
            return {
                "prediction": None,
                "confidence": 0.0,
                "status": "error",
                "error": "no_text_detected",
                "message": "No text detected in the image. Please upload an image containing handwritten text.",
                "grayscale_image": text_detection["grayscale_image"],
                "text_detection": {
                    "has_text": False,
                    "confidence": text_detection["confidence"],
                    "text_count": text_detection["text_count"]
                }
            }
        
        # Preprocess for model
        img_tensor = preprocess_image(image)
        
        # Predict
        with torch.no_grad():
            output = model(img_tensor)
            # Binary classification with sigmoid
            probability = torch.sigmoid(output).item()
            predicted_class = 1 if probability > 0.5 else 0
            confidence = probability if predicted_class == 1 else (1 - probability)
            
            # Class 0: Non-Dyslexic, Class 1: Dyslexic
            prediction = "Dyslexic" if predicted_class == 1 else "Non-Dyslexic"
        
        return {
            "prediction": prediction,
            "confidence": float(confidence),
            "status": "success",
            "text_detection": {
                "has_text": True,
                "confidence": text_detection["confidence"],
                "text_count": text_detection["text_count"]
            }
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
