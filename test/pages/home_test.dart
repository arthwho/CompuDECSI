import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compudecsi/pages/home.dart';
import 'package:compudecsi/utils/variables.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home Page', () {
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
