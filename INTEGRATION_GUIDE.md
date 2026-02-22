# Dyslexia Detection - Flutter + FastAPI Integration Guide

## Overview
This guide will help you integrate your PyTorch dyslexia detection model with your Flutter app using FastAPI.

## Project Structure
```
dyslexia_detector/
├── backend/
│   ├── main.py              # FastAPI server
│   ├── requirements.txt     # Python dependencies
│   ├── model/              # Place your .pth model here
│   └── README.md
├── lib/
│   ├── models/
│   │   └── prediction_result.dart
│   ├── services/
│   │   └── api_service.dart
│   ├── screens/
│   │   └── home_screen.dart
│   └── main.dart
└── pubspec.yaml
```

## Setup Instructions

### 1. Backend Setup (FastAPI)

#### Step 1: Navigate to backend directory
```bash
cd backend
```

#### Step 2: Create virtual environment
```bash
python -m venv venv

# Activate:
# Windows: venv\Scripts\activate
# Mac/Linux: source venv/bin/activate
```

#### Step 3: Install dependencies
```bash
pip install -r requirements.txt
```

#### Step 4: Add your model
- Create a `model` folder in the backend directory
- Copy your trained `.pth` model file to `backend/model/dyslexia_model.pth`

#### Step 5: Update model architecture
Edit `backend/main.py` and replace the `DyslexiaModel` class with your actual model architecture:

```python
class DyslexiaModel(nn.Module):
    def __init__(self):
        super(DyslexiaModel, self).__init__()
        # Add your model layers here
        self.conv1 = nn.Conv2d(...)
        # ... rest of your architecture
    
    def forward(self, x):
        # Add your forward pass
        return x
```

#### Step 6: Update preprocessing
Modify the `preprocess_image` function to match your training preprocessing:
- Image size
- Normalization values
- Color channels
- Any other transformations

#### Step 7: Run the API
```bash
python main.py
```

The API will start at `http://localhost:8000`

### 2. Flutter App Setup

#### Step 1: Install dependencies
```bash
cd ..  # Back to project root
flutter pub get
```

#### Step 2: Configure API URL
Edit `lib/services/api_service.dart` and update the `baseUrl`:

- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000`
  - Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

#### Step 3: Update Android permissions (if needed)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

#### Step 4: Update iOS permissions (if needed)
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture handwriting images</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select images</string>
```

#### Step 5: Run the app
```bash
flutter run
```

## Testing the Integration

### 1. Test API directly
```bash
curl http://localhost:8000/health
```

### 2. Test prediction with curl
```bash
curl -X POST "http://localhost:8000/predict" \
  -F "file=@path/to/test_image.jpg"
```

### 3. Test in Flutter app
1. Start the FastAPI backend
2. Run the Flutter app
3. Check the cloud icon in the app bar (should be green if connected)
4. Select an image from camera or gallery
5. Click "Analyze Handwriting"

## Troubleshooting

### API Connection Issues
- Ensure FastAPI server is running
- Check firewall settings
- Verify the correct IP address in `api_service.dart`
- For physical devices, ensure phone and computer are on the same network

### Model Loading Issues
- Verify model file path is correct
- Ensure model architecture matches the saved model
- Check PyTorch version compatibility

### Image Processing Issues
- Verify image preprocessing matches training
- Check image size and format
- Ensure normalization values are correct

## API Endpoints

### GET /
Returns API information

### GET /health
Health check endpoint
```json
{
  "status": "healthy",
  "model_loaded": true,
  "device": "cpu"
}
```

### POST /predict
Upload image for prediction
- **Input**: Multipart form data with image file
- **Output**:
```json
{
  "prediction": "Dyslexic" or "Non-Dyslexic",
  "confidence": 0.85,
  "status": "success"
}
```

## Next Steps

1. Fine-tune the model preprocessing
2. Add error handling and logging
3. Implement result history
4. Add authentication if needed
5. Deploy to production server
6. Optimize model inference speed

## Production Deployment

For production, consider:
- Using a cloud service (AWS, GCP, Azure)
- Adding HTTPS
- Implementing authentication
- Using a production WSGI server (Gunicorn)
- Containerizing with Docker
- Adding monitoring and logging
