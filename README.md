# Dyslexia Detector

A Flutter application that detects dyslexia from handwriting images using machine learning.

## Features

- Take photos using camera
- Select images from gallery
- Analyze handwriting for dyslexia indicators
- Display prediction results with confidence scores

## Setup Instructions

### 1. Install Dependencies

```bash
cd dyslexia_detector
flutter pub get
```

### 2. Add Your Model

Place your trained TensorFlow Lite model file in:
```
assets/model/dyslexia_model.tflite
```

### 3. Model Requirements

The current implementation expects:
- Input: 224x224 RGB image
- Output: 2 classes [normal, dyslexia]

Adjust the `ModelService` class if your model has different specifications.

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/
│   └── home_screen.dart   # Main UI screen
└── services/
    └── model_service.dart # ML model integration

assets/
└── model/
    └── dyslexia_model.tflite  # Your trained model (add this)
```

## Dependencies

- `image_picker`: Camera and gallery access
- `tflite_flutter`: TensorFlow Lite integration
- `path_provider`: File system access

## Notes

- Make sure to add your trained model file before running
- Camera permissions will be requested on first use
- Adjust image preprocessing in `ModelService` based on your model's requirements
