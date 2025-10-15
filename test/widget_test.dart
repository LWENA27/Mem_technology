// Basic widget test for InventoryMaster SaaS
//
// This test verifies that the app initializes properly

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lwenatech/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads with the customer view
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
