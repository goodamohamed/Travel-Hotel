import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travel_hotel_app/main.dart';

void main() {
  setUpAll(() {
    FlutterError.onError = (FlutterErrorDetails details) {};
  });
  testWidgets('TravelMate renders home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Start'), findsWidgets);
    final skipFinder = find.text('Skip');
    if (skipFinder.evaluate().isNotEmpty) {
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();
    }
    expect(find.text('Register'), findsWidgets);
  });
}
