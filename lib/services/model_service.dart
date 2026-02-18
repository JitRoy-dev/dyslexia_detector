import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      // Load your TFLite model from assets
      _interpreter = await Interpreter.fromAsset('assets/model/dyslexia_model.tflite');
      _isModelLoaded = true;
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
      _isModelLoaded = false;
    }
  }

  Future<String> predictDyslexia(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      return 'Model not loaded. Please add your model to assets/model/';
    }

    try {
      // Read and preprocess image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        return 'Error: Could not decode image';
      }

      // Resize image to model input size (adjust based on your model)
      final resizedImage = img.copyResize(image, width: 224, height: 224);

      // Convert to input tensor format
      var input = _imageToByteListFloat32(resizedImage);

      // Prepare output tensor
      var output = List.filled(1 * 2, 0.0).reshape([1, 2]);

      // Run inference
      _interpreter!.run(input, output);

      // Process output
      double dyslexiaProb = output[0][1];
      double normalProb = output[0][0];

      if (dyslexiaProb > normalProb) {
        return 'Dyslexia Detected\nConfidence: ${(dyslexiaProb * 100).toStringAsFixed(1)}%';
      } else {
        return 'No Dyslexia Detected\nConfidence: ${(normalProb * 100).toStringAsFixed(1)}%';
      }
    } catch (e) {
      return 'Error during prediction: $e';
    }
  }

  List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image) {
    // Convert image to normalized float values
    var convertedBytes = List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              (pixel.r / 255.0),
              (pixel.g / 255.0),
              (pixel.b / 255.0),
            ];
          },
        ),
      ),
    );
    return convertedBytes;
  }

  void dispose() {
    _interpreter?.close();
  }
}
