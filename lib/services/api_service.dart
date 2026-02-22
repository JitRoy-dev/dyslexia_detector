import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // IMPORTANT: Update this based on your setup
  // 
  // For Android Emulator: http://10.0.2.2:8000
  // For iOS Simulator: http://localhost:8000
  // For Physical Device: http://YOUR_COMPUTER_IP:8000
  //   - Windows: Run 'ipconfig' in terminal, look for IPv4 Address
  //   - Mac/Linux: Run 'ifconfig' or 'ip addr', look for inet address
  //   - Example: http://192.168.1.100:8000
  //
  // Make sure your computer and phone are on the same WiFi network!
  
  // TODO: Replace with your computer's IP address for physical device
  static const String baseUrl = 'http://192.168.1.44:8000';

  Future<Map<String, dynamic>> predictDyslexia(File imageFile) async {
    try {
      print('Sending request to: $baseUrl/predict');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Server not responding');
        },
      );
      
      var response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Cannot connect to server. Make sure:\n'
          '1. Backend is running (python main.py)\n'
          '2. Correct IP address in baseUrl\n'
          '3. Same WiFi network (for physical device)\n'
          'Error: $e');
    } on TimeoutException catch (e) {
      throw Exception('Connection timeout. Server might be slow or not responding.\nError: $e');
    } catch (e) {
      throw Exception('Error connecting to API: $e');
    }
  }

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      print('Checking health at: $baseUrl/health');
      
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      print('Health check status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return {
          'connected': true,
          'data': json.decode(response.body),
        };
      }
      return {'connected': false, 'error': 'Status ${response.statusCode}'};
    } on SocketException catch (e) {
      print('Socket error: $e');
      return {'connected': false, 'error': 'Cannot reach server'};
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      return {'connected': false, 'error': 'Connection timeout'};
    } catch (e) {
      print('Health check error: $e');
      return {'connected': false, 'error': e.toString()};
    }
  }
}
