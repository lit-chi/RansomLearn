import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ransom_learn/main.dart';

void main() {
  testWidgets('App launches and displays splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RansomLearnApp());
    expect(find.text('RANSOMLEARN'), findsOneWidget);
  });
}
