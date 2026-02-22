class PredictionResult {
  final String? prediction;
  final double confidence;
  final String status;
  final String? error;
  final String? message;
  final String? grayscaleImage;
  final Map<String, dynamic>? textDetection;

  PredictionResult({
    this.prediction,
    required this.confidence,
    required this.status,
    this.error,
    this.message,
    this.grayscaleImage,
    this.textDetection,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      prediction: json['prediction'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      status: json['status'] as String,
      error: json['error'] as String?,
      message: json['message'] as String?,
      grayscaleImage: json['grayscale_image'] as String?,
      textDetection: json['text_detection'] as Map<String, dynamic>?,
    );
  }

  bool get isDyslexic => prediction?.toLowerCase().contains('dyslexic') ?? false;
  
  bool get hasError => status == 'error' || error != null;
  
  bool get isNoTextError => error == 'no_text_detected';
  
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
}
