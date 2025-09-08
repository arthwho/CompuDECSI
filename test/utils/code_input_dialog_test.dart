import 'package:compudecsi/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openDialog(
    WidgetTester tester,
    void Function(String) onSubmit,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => CodeInputDialog(onCodeSubmitted: onSubmit),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('submits when 6 digits entered and Confirm pressed', (
    tester,
  ) async {
    String? submitted;
    await openDialog(tester, (c) => submitted = c);

    // Bottom sheet content should be visible now
    final field = find.byType(TextField);
    expect(field, findsOneWidget);

    await tester.enterText(field, '123456');
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(submitted, '123456');
  });

  testWidgets('shows error when less than 6 digits', (tester) async {
    await openDialog(tester, (_) {});

    final field = find.byType(TextField);
    await tester.enterText(field, '12345');
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    expect(
      find.text('Por favor, digite um código de 6 dígitos'),
      findsOneWidget,
    );
  });
}
