import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coherent_strength_running/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CoherentStrengthRunning());

    // Verify text presence
    expect(find.text('COHERENT'), findsOneWidget);
    // "Strength Running" appears in the title.
    expect(find.text('Strength Running'), findsAtLeastNWidgets(1));
    expect(find.text('Train with clarity.'), findsOneWidget);
    expect(find.text("TODAY'S SESSION"), findsOneWidget);
    expect(find.text('Easy Run'), findsAtLeastNWidgets(1));

    // Verify exactly one "Start Session" button.
    expect(find.widgetWithText(ElevatedButton, 'Start Session'), findsOneWidget);
  });
}
