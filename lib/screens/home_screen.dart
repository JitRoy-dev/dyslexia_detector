import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../models/prediction_result.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  PredictionResult? _result;
  bool _isLoading = false;
  bool _apiHealthy = false;
  Uint8List? _grayscaleImageBytes;

  @override
  void initState() {
    super.initState();
    _checkApiHealth();
  }

  Future<void> _checkApiHealth() async {
    final result = await _apiService.checkHealth();
    setState(() {
      _apiHealthy = result['connected'] ?? false;
    });
    
    if (!_apiHealthy) {
      print('API Health Check Failed: ${result['error']}');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _result = null;
          _grayscaleImageBytes = null;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _grayscaleImageBytes = null;
    });

    try {
      final response = await _apiService.predictDyslexia(_selectedImage!);
      final result = PredictionResult.fromJson(response);
      
      setState(() {
        _result = result;
        
        // If no text detected, decode the grayscale image
        if (result.isNoTextError && result.grayscaleImage != null) {
          _grayscaleImageBytes = base64Decode(result.grayscaleImage!);
        }
      });
      
      // Show error message if no text detected
      if (result.isNoTextError) {
        _showError(result.message ?? 'No text detected in the image');
      }
    } catch (e) {
      _showError('Prediction failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dyslexia Detector'),
        actions: [
          IconButton(
            icon: Icon(_apiHealthy ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _checkApiHealth,
            tooltip: _apiHealthy ? 'API Connected' : 'API Disconnected',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_apiHealthy)
              Card(
                color: Colors.orange.shade100,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'API server not connected. Please start the backend.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Image display
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _grayscaleImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.memory(
                            _grayscaleImageBytes!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'GRAYSCALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_selectedImage!, fit: BoxFit.contain),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No image selected'),
                            ],
                          ),
                        ),
            ),
            const SizedBox(height: 16),
            
            // Image picker buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Analyze button
            ElevatedButton(
              onPressed: _selectedImage != null && !_isLoading && _apiHealthy
                  ? _analyzeImage
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Analyze Handwriting', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            
            // Results
            if (_result != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _result!.isNoTextError
                      ? Column(
                          children: [
                            const Icon(
                              Icons.text_fields_outlined,
                              size: 64,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Text Detected',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _result!.message ?? 'Please upload an image with handwritten text',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'The image has been converted to grayscale above.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Icon(
                              _result!.isDyslexic ? Icons.warning : Icons.check_circle,
                              size: 64,
                              color: _result!.isDyslexic ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _result!.prediction ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Confidence: ${_result!.confidencePercentage}',
                              style: const TextStyle(fontSize: 18),
                            ),
                            if (_result!.textDetection != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Text detected: ${_result!.textDetection!['text_count']} words',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
