# Configuration file for the Dyslexia Detection API

# Model Configuration
MODEL_PATH = "/backend/model/dyslexia_model.pth"
IMAGE_SIZE = (224, 224)  # Adjust based on your model
DEVICE = "cuda"  # or "cpu"

# Preprocessing Configuration
MEAN = [0.485, 0.456, 0.406]  # ImageNet defaults
STD = [0.229, 0.224, 0.225]   # ImageNet defaults

# API Configuration
HOST = "0.0.0.0"
PORT = 8000
DEBUG = False

# Prediction Configuration
CONFIDENCE_THRESHOLD = 0.5
MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.bmp'}
