import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dyslexia_detector/main.dart';

void main() {
  testWidgets('App loads with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const DyslexiaDetectorApp());

    expect(find.text('Dyslexia Detector'), findsOneWidget);
    expect(find.text('No image selected'), findsOneWidget);
  });
}
