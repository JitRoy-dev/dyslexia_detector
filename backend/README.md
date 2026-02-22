# Dyslexia Detection FastAPI Backend

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Place your trained model:
   - Copy your `.pth` model file to `backend/model/dyslexia_model.pth`

4. Update the model architecture:
   - Edit `main.py` and replace the `DyslexiaModel` class with your actual model architecture
   - Update the `preprocess_image` function to match your training preprocessing

## Run the API

```bash
python main.py
```

The API will be available at `http://localhost:8000`

## API Endpoints

- `GET /` - API info
- `GET /health` - Health check
- `POST /predict` - Upload image for prediction

## Testing

```bash
curl -X POST "http://localhost:8000/predict" -F "file=@test_image.jpg"
```
