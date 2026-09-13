import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coherent_strength_running/running_engine.dart';
import 'package:coherent_strength_running/running_screen.dart';

void main() {
  testWidgets('LiveRunScreen UI flows correctly', (tester) async {
    final engine = RunningEngine();
    await tester.pumpWidget(MaterialApp(home: LiveRunScreen(engine: engine)));

    // Verify initial state
    expect(find.text('RUNNING'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);

    // Test pause
    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('PAUSED'), findsOneWidget);

    // Test resume
    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(find.text('RUNNING'), findsOneWidget);
  });
}
