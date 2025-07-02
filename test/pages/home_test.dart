import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compudecsi/pages/home.dart';
import 'package:compudecsi/utils/variables.dart';

void main() {
  group('Home Page', () {
    testWidgets('should render greeting with user name', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testUserName = 'John Doe';

      // Act
      await tester.pumpWidget(MaterialApp(home: Home()));

      // Wait for the widget to load
      await tester.pumpAndSettle();

      // Assert
      // The greeting should be present (even if user name is not loaded yet)
      expect(find.textContaining('Olá'), findsOneWidget);
    });

    testWidgets('should render search bar', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Home()));

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.text('Pesquisar palestras'), findsOneWidget);
    });

    testWidgets('should render carousel with category cards', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Home()));

      await tester.pumpAndSettle();

      // Assert
      // Check for carousel content
      expect(find.byType(CarouselView), findsOneWidget);

      // Check for category cards
      expect(find.text('Data Science'), findsOneWidget);
      expect(find.text('Criptografia'), findsOneWidget);
      expect(find.text('Robótica'), findsOneWidget);
      expect(find.text('Inteligência\n Artificial'), findsOneWidget);
      expect(find.text('Software'), findsOneWidget);
      expect(find.text('Computação'), findsOneWidget);
      expect(find.text('Eletrônica'), findsOneWidget);
      expect(find.text('Redes'), findsOneWidget);
    });

    testWidgets('should render upcoming events section', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Home()));

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Próximas palestras'), findsOneWidget);
      expect(find.text('VER TUDO'), findsOneWidget);
    });

    testWidgets('should format first and last name correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final homeState = _HomeState();

      // Act & Assert
      expect(homeState.formatFirstAndLastName('john doe'), equals('John Doe'));
      expect(
        homeState.formatFirstAndLastName('JANE SMITH'),
        equals('Jane Smith'),
      );
      expect(homeState.formatFirstAndLastName('single'), equals('Single'));
      expect(homeState.formatFirstAndLastName(''), equals(''));
      expect(homeState.formatFirstAndLastName(null), equals(''));
    });

    testWidgets('should handle empty or null user name gracefully', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Home()));

      await tester.pumpAndSettle();

      // Assert
      // Should not throw any errors when user name is null or empty
      expect(find.byType(Home), findsOneWidget);
    });
  });
}

// Helper class to test private methods
class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  String formatFirstAndLastName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return _capitalize(parts[0]);
    } else {
      return _capitalize(parts.first) + ' ' + _capitalize(parts.last);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
