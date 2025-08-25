import 'package:compudecsi/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('Shows enrollment code card and copy action', (tester) async {
    final widget = DetailsPage(
      image: '',
      name: 'Palestra X',
      local: 'Auditório',
      date: '01/01/2025',
      time: '10:00',
      description: 'Desc',
      speaker: 'Fulano da Silva',
      eventId: null, // avoid Firestore calls in init
      initialIsEnrolled: true,
      initialEnrollmentCode: '123456',
    );

    await tester.pumpWidget(_wrap(widget));
    await tester.pumpAndSettle();

    expect(find.text('Seu código de inscrição'), findsOneWidget);
    expect(find.text('123 456'), findsOneWidget);

    // Tap copy icon
    final copyBtn = find.byIcon(Icons.copy_rounded);
    expect(copyBtn, findsOneWidget);
    await tester.tap(copyBtn);
    await tester.pump();

    // SnackBar feedback after copy
    expect(
      find.text('Código copiado para a área de transferência'),
      findsOneWidget,
    );
  });
}
