import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DyslexiaDetectorApp());
}

class DyslexiaDetectorApp extends StatelessWidget {
  const DyslexiaDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dyslexia Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
