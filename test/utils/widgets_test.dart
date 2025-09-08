import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compudecsi/utils/widgets.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('should render with correct text', (WidgetTester tester) async {
      // Arrange
      const testText = 'Test Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(text: testText, onPressed: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool wasPressed = false;
      const testText = 'Test Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: testText,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text(testText));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should render with icon when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testText = 'Test Button';
      const testIcon = Icon(Icons.add);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: testText,
              icon: testIcon,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should respect custom width and height', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testText = 'Test Button';
      const customWidth = 200.0;
      const customHeight = 60.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: testText,
              width: customWidth,
              height: customHeight,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      final buttonFinder = find.byType(SizedBox);
      final sizedBox = tester.widget<SizedBox>(buttonFinder.first);
      expect(sizedBox.width, equals(customWidth));
      expect(sizedBox.height, equals(customHeight));
    });
  });

  group('SecondaryButton', () {
    testWidgets('should render with correct text', (WidgetTester tester) async {
      // Arrange
      const testText = 'Secondary Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(text: testText, onPressed: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool wasPressed = false;
      const testText = 'Secondary Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              text: testText,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text(testText));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });
  });

  group('TertiaryButton', () {
    testWidgets('should render with correct text', (WidgetTester tester) async {
      // Arrange
      const testText = 'Tertiary Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TertiaryButton(text: testText, onPressed: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool wasPressed = false;
      const testText = 'Tertiary Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TertiaryButton(
              text: testText,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text(testText));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });
  });

  group('QuaternaryButton', () {
    testWidgets('should render with correct text', (WidgetTester tester) async {
      // Arrange
      const testText = 'Quaternary Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuaternaryButton(text: testText, onPressed: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool wasPressed = false;
      const testText = 'Quaternary Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuaternaryButton(
              text: testText,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text(testText));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });
  });

  group('GoogleSignInButton', () {
    testWidgets('should render with default text', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GoogleSignInButton(onPressed: () {})),
        ),
      );

      // Assert
      expect(find.text('Entrar com o Google'), findsOneWidget);
    });

    testWidgets('should render with custom text', (WidgetTester tester) async {
      // Arrange
      const customText = 'Custom Google Sign In';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(text: customText, onPressed: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text(customText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Entrar com o Google'));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should render Google icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GoogleSignInButton(onPressed: () {})),
        ),
      );

      // Assert
      // The button should contain an image asset or fallback icon
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
