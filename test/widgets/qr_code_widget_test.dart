import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compudecsi/widgets/qr_code_widget.dart';

void main() {
  group('QRCodeWidget', () {
    testWidgets('should display QR code with correct data', (
      WidgetTester tester,
    ) async {
      const testData = '123456';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: QRCodeWidget(data: testData)),
        ),
      );

      // Verify that the widget displays the test data
      expect(find.text('Código: $testData'), findsOneWidget);
      expect(
        find.text('Apresente este QR Code para o check-in'),
        findsOneWidget,
      );
    });

    testWidgets('should display with custom size', (WidgetTester tester) async {
      const testData = '123456';
      const customSize = 150.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QRCodeWidget(data: testData, size: customSize),
          ),
        ),
      );

      // The widget should be rendered with the custom size
      expect(find.byType(QRCodeWidget), findsOneWidget);
    });

    testWidgets('should display with custom colors', (
      WidgetTester tester,
    ) async {
      const testData = '123456';
      const backgroundColor = Colors.black;
      const foregroundColor = Colors.white;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QRCodeWidget(
              data: testData,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
            ),
          ),
        ),
      );

      // The widget should be rendered with custom colors
      expect(find.byType(QRCodeWidget), findsOneWidget);
    });
  });
}
