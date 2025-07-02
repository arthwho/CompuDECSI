import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:compudecsi/services/shared_pref.dart';

void main() {
  group('SharedpreferenceHelper', () {
    late SharedpreferenceHelper sharedPrefHelper;

    setUp(() {
      sharedPrefHelper = SharedpreferenceHelper();
    });

    group('saveUserId', () {
      test('should save user ID successfully', () async {
        // Arrange
        const testUserId = 'test_user_123';

        // Act
        final result = await sharedPrefHelper.saveUserId(testUserId);

        // Assert
        expect(result, isTrue);

        // Verify the value was actually saved
        final savedUserId = await sharedPrefHelper.getUserId();
        expect(savedUserId, equals(testUserId));
      });

      test('should handle empty string', () async {
        // Arrange
        const testUserId = '';

        // Act
        final result = await sharedPrefHelper.saveUserId(testUserId);

        // Assert
        expect(result, isTrue);

        final savedUserId = await sharedPrefHelper.getUserId();
        expect(savedUserId, equals(testUserId));
      });
    });

    group('saveUserName', () {
      test('should save user name successfully', () async {
        // Arrange
        const testUserName = 'John Doe';

        // Act
        final result = await sharedPrefHelper.saveUserName(testUserName);

        // Assert
        expect(result, isTrue);

        final savedUserName = await sharedPrefHelper.getUserName();
        expect(savedUserName, equals(testUserName));
      });
    });

    group('saveUserEmail', () {
      test('should save user email successfully', () async {
        // Arrange
        const testUserEmail = 'john.doe@example.com';

        // Act
        final result = await sharedPrefHelper.saveUserEmail(testUserEmail);

        // Assert
        expect(result, isTrue);

        final savedUserEmail = await sharedPrefHelper.getUserEmail();
        expect(savedUserEmail, equals(testUserEmail));
      });
    });

    group('saveUserImage', () {
      test('should save user image URL successfully', () async {
        // Arrange
        const testUserImage = 'https://example.com/avatar.jpg';

        // Act
        final result = await sharedPrefHelper.saveUserImage(testUserImage);

        // Assert
        expect(result, isTrue);

        final savedUserImage = await sharedPrefHelper.getUserImage();
        expect(savedUserImage, equals(testUserImage));
      });
    });

    group('getUserId', () {
      test('should return null when no user ID is saved', () async {
        // Clear any existing data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(SharedpreferenceHelper.userIdKey);

        // Act
        final result = await sharedPrefHelper.getUserId();

        // Assert
        expect(result, isNull);
      });
    });

    group('getUserName', () {
      test('should return null when no user name is saved', () async {
        // Clear any existing data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(SharedpreferenceHelper.userNameKey);

        // Act
        final result = await sharedPrefHelper.getUserName();

        // Assert
        expect(result, isNull);
      });
    });

    group('getUserEmail', () {
      test('should return null when no user email is saved', () async {
        // Clear any existing data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(SharedpreferenceHelper.userEmailKey);

        // Act
        final result = await sharedPrefHelper.getUserEmail();

        // Assert
        expect(result, isNull);
      });
    });

    group('getUserImage', () {
      test('should return null when no user image is saved', () async {
        // Clear any existing data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(SharedpreferenceHelper.userImageKey);

        // Act
        final result = await sharedPrefHelper.getUserImage();

        // Assert
        expect(result, isNull);
      });
    });
  });
}
