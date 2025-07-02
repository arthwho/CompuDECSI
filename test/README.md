# CompuDECSI Test Suite

This directory contains comprehensive unit tests for the CompuDECSI Flutter application.

## Test Structure

```
test/
├── README.md                    # This file
├── widget_test.dart             # Main app widget tests
├── services/
│   ├── auth_test.dart           # Authentication service tests
│   └── shared_pref_test.dart    # Shared preferences service tests
├── utils/
│   ├── variables_test.dart      # App variables and constants tests
│   └── widgets_test.dart        # Custom widget component tests
└── pages/
    ├── home_test.dart           # Home page widget tests
    └── onboarding_test.dart     # Onboarding page widget tests
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/services/shared_pref_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run tests with verbose output
```bash
flutter test --verbose
```

## Test Categories

### 1. Service Tests (`test/services/`)
- **shared_pref_test.dart**: Tests for SharedPreferences helper class
  - Tests saving and retrieving user data
  - Tests handling of null/empty values
  - Tests all CRUD operations

### 2. Utility Tests (`test/utils/`)
- **variables_test.dart**: Tests for app constants and styling
  - Tests color values
  - Tests spacing and size constants
  - Tests text styles and button styles
- **widgets_test.dart**: Tests for custom widget components
  - Tests all button variants (Primary, Secondary, Tertiary, Quaternary)
  - Tests GoogleSignInButton
  - Tests CodeInputDialog

### 3. Page Tests (`test/pages/`)
- **home_test.dart**: Tests for Home page functionality
  - Tests greeting display
  - Tests search bar rendering
  - Tests carousel with category cards
  - Tests name formatting logic
- **onboarding_test.dart**: Tests for Onboarding page
  - Tests page content rendering
  - Tests page navigation
  - Tests animated components
  - Tests onboarding data structure

### 4. Main App Tests (`test/widget_test.dart`)
- Tests main app initialization
- Tests app configuration (title, debug banner, etc.)

## Test Dependencies

The tests use the following dependencies (already added to `pubspec.yaml`):
- `flutter_test`: Flutter's testing framework
- `mockito`: For creating mocks (when needed)
- `build_runner`: For generating mock classes

## Writing New Tests

When adding new features, follow these guidelines:

1. **Test Structure**: Use the Arrange-Act-Assert pattern
2. **Test Naming**: Use descriptive test names that explain what is being tested
3. **Grouping**: Group related tests using `group()` blocks
4. **Coverage**: Aim for high test coverage, especially for business logic
5. **Mocking**: Use mocks for external dependencies (Firebase, network calls, etc.)

### Example Test Structure
```dart
group('FeatureName', () {
  test('should do something when condition is met', () async {
    // Arrange
    final testData = 'test';
    
    // Act
    final result = await someFunction(testData);
    
    // Assert
    expect(result, equals(expectedValue));
  });
});
```

## Continuous Integration

These tests are designed to run in CI/CD pipelines. Make sure all tests pass before merging code changes.

## Coverage Goals

- **Services**: 90%+ coverage
- **Utils**: 95%+ coverage  
- **Pages**: 80%+ coverage (focus on business logic)
- **Overall**: 85%+ coverage

## Troubleshooting

### Common Issues

1. **Firebase Tests**: Some tests may fail if Firebase is not properly configured for testing
2. **Asset Tests**: Image asset tests may fail if assets are not properly declared in `pubspec.yaml`
3. **Mock Generation**: Run `flutter packages pub run build_runner build` if you need to generate mocks

### Running Tests in Isolation

If you're having issues with specific tests, you can run them in isolation:

```bash
# Run only service tests
flutter test test/services/

# Run only widget tests
flutter test test/utils/ test/pages/

# Run a single test
flutter test test/services/shared_pref_test.dart
``` 