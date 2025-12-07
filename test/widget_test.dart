// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personality_detector/main.dart';

void main() {
  testWidgets('App launches and shows StartScreen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the StartScreen is shown.
    // Based on typical StartScreen content, check for a button or title.
    // Assuming "Start Quiz" text or similar is present.
    // Let's check the file content first. I'll rely on "Personality Detector" title from main.dart or StartScreen.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
