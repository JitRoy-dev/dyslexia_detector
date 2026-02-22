# Text Detection Setup Guide

This guide explains how to set up the text detection feature for the Dyslexia Detection API.

## Overview

The app now validates that uploaded images contain text before making predictions. Images without text are rejected and converted to grayscale for display.

## Requirements

### Python Dependencies

Install the required packages:

```bash
pip install -r requirements.txt
```

### Tesseract OCR

The text detection feature uses Tesseract OCR. You need to install it on your system:

#### Windows

1. Download the installer from: https://github.com/UB-Mannheim/tesseract/wiki
2. Run the installer (e.g., `tesseract-ocr-w64-setup-5.3.3.20231005.exe`)
3. Add Tesseract to your PATH, or set it in your code:
   ```python
   import pytesseract
   pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
   ```

#### macOS

```bash
brew install tesseract
```

#### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install tesseract-ocr
```

#### Linux (Fedora/RHEL)

```bash
sudo dnf install tesseract
```

## How It Works

1. **Image Upload**: User uploads an image via the Flutter app
2. **Text Detection**: Backend uses Tesseract OCR to detect text in the image
3. **Validation**:
   - If text is detected → Proceed with dyslexia prediction
   - If no text is detected → Return error with grayscale version of the image
4. **Response**: Flutter app displays either:
   - Prediction results (if text found)
   - Error message with grayscale image (if no text found)

## API Response Format

### Success (Text Detected)

```json
{
  "prediction": "Dyslexic" or "Non-Dyslexic",
  "confidence": 0.85,
  "status": "success",
  "text_detection": {
    "has_text": true,
    "confidence": 75.5,
    "text_count": 12
  }
}
```

### Error (No Text Detected)

```json
{
  "prediction": null,
  "confidence": 0.0,
  "status": "error",
  "error": "no_text_detected",
  "message": "No text detected in the image. Please upload an image containing handwritten text.",
  "grayscale_image": "base64_encoded_grayscale_image_data",
  "text_detection": {
    "has_text": false,
    "confidence": 0.0,
    "text_count": 0
  }
}
```

## Testing

Test the text detection with different images:

1. **Image with text**: Should proceed with prediction
2. **Image without text** (e.g., landscape, face): Should show error and grayscale version
3. **Low quality text**: May be rejected if OCR confidence is too low

## Configuration

You can adjust the text detection sensitivity in `main.py`:

```python
# In detect_text_in_image function
conf = int(ocr_data['conf'][i])
if conf > 30 and text.strip():  # Change threshold here (0-100)
```

Lower threshold = more sensitive (may accept non-text images)
Higher threshold = stricter (may reject poor quality text)

## Troubleshooting

### "Tesseract not found" error

- Ensure Tesseract is installed and in your PATH
- On Windows, set the path explicitly in `main.py`

### Text not being detected in valid images

- Lower the confidence threshold (currently 30)
- Check image quality and contrast
- Ensure text is clearly visible

### False positives (non-text images passing)

- Increase the confidence threshold
- Add minimum text count requirement
- Enhance preprocessing steps
