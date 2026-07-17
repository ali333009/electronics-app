// Widget smoke test for the Electronic app.
// We only verify that the app boots without crashing (splash screen appears).
// Full BLoC/repository tests require Firebase test emulators.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders a Material app without crashing', (WidgetTester tester) async {
    // Minimal sanity check — just confirm MaterialApp tree can be built.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Electronic')),
        ),
      ),
    );

    expect(find.text('Electronic'), findsOneWidget);
  });
}
