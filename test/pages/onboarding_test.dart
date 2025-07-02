import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compudecsi/pages/onboarding_page.dart';

void main() {
  group('Onboarding Page', () {
    testWidgets('should render onboarding content', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Onboarding()));

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Onboarding), findsOneWidget);
    });

    testWidgets('should render page indicators', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Onboarding()));

      await tester.pumpAndSettle();

      // Assert
      // Should have 3 dots for 3 onboarding pages
      expect(find.byType(AnimatedDot), findsNWidgets(3));
    });

    testWidgets('should render Google sign in button', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Onboarding()));

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Continuar com o Google'), findsOneWidget);
    });

    testWidgets('should render onboarding content correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Onboarding()));

      await tester.pumpAndSettle();

      // Assert
      // Check for first onboarding page content
      expect(find.text('A 4ª Semana da Computação na sua mão'), findsOneWidget);
      expect(
        find.text('Acompanhe as palestras da semana da computação no ICEA'),
        findsOneWidget,
      );
    });

    testWidgets('should handle page swiping', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Onboarding()));

      await tester.pumpAndSettle();

      // Swipe to next page
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Assert
      // Should show second page content
      expect(find.text('Q&A em tempo real'), findsOneWidget);
      expect(
        find.text(
          'Faça perguntas sobre a palestra e aprenda de forma dinâmica',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should render animated background', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Onboarding()));

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedBackground), findsOneWidget);
    });

    testWidgets('should render flexible asset images', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Onboarding()));

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FlexibleAssetImage), findsOneWidget);
    });
  });

  group('AnimatedDot', () {
    testWidgets('should render active dot correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedDot(isActive: true))),
      );

      // Assert
      expect(find.byType(AnimatedDot), findsOneWidget);
    });

    testWidgets('should render inactive dot correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedDot(isActive: false))),
      );

      // Assert
      expect(find.byType(AnimatedDot), findsOneWidget);
    });
  });

  group('OnboardingContent', () {
    testWidgets('should render with provided content', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testIllustration = 'assets/test.png';
      const testTitle = 'Test Title';
      const testText = 'Test Description';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingContent(
              illustration: testIllustration,
              title: testTitle,
              text: testText,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testText), findsOneWidget);
      expect(find.byType(FlexibleAssetImage), findsOneWidget);
    });
  });

  group('FlexibleAssetImage', () {
    testWidgets('should render SVG image', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexibleAssetImage(assetName: 'assets/test.svg'),
          ),
        ),
      );

      // Assert
      expect(find.byType(FlexibleAssetImage), findsOneWidget);
    });

    testWidgets('should render PNG image', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexibleAssetImage(assetName: 'assets/test.png'),
          ),
        ),
      );

      // Assert
      expect(find.byType(FlexibleAssetImage), findsOneWidget);
    });

    testWidgets('should render GIF image', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexibleAssetImage(assetName: 'assets/test.gif'),
          ),
        ),
      );

      // Assert
      expect(find.byType(FlexibleAssetImage), findsOneWidget);
    });
  });

  group('onboardingData', () {
    test('should have correct number of onboarding pages', () {
      expect(onboardingData.length, equals(3));
    });

    test('should have required fields for each page', () {
      for (final page in onboardingData) {
        expect(page.containsKey('illustration'), isTrue);
        expect(page.containsKey('title'), isTrue);
        expect(page.containsKey('text'), isTrue);
      }
    });

    test('should have valid content for first page', () {
      final firstPage = onboardingData[0];
      expect(
        firstPage['title'],
        equals('A 4ª Semana da Computação na sua mão'),
      );
      expect(
        firstPage['text'],
        equals('Acompanhe as palestras da semana da computação no ICEA'),
      );
    });

    test('should have valid content for second page', () {
      final secondPage = onboardingData[1];
      expect(secondPage['title'], equals('Q&A em tempo real'));
      expect(
        secondPage['text'],
        equals('Faça perguntas sobre a palestra e aprenda de forma dinâmica'),
      );
    });

    test('should have valid content for third page', () {
      final thirdPage = onboardingData[2];
      expect(thirdPage['title'], equals('Check-in e comprovante de presença '));
      expect(
        thirdPage['text'],
        equals(
          'Faça check-in nas palestras que assistir e ganhe horas complementares!',
        ),
      );
    });
  });
}
