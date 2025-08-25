import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:compudecsi/services/shared_pref.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('SharedpreferenceHelper saves and reads user data', () async {
    final helper = SharedpreferenceHelper();

    await helper.saveUserId('uid_123');
    await helper.saveUserName('Ada Lovelace');
    await helper.saveUserEmail('ada@example.com');
    await helper.saveUserImage('https://img');
    await helper.saveUserEmoji('rocket');

    expect(await helper.getUserId(), 'uid_123');
    expect(await helper.getUserName(), 'Ada Lovelace');
    expect(await helper.getUserEmail(), 'ada@example.com');
    expect(await helper.getUserImage(), 'https://img');
    expect(await helper.getUserEmoji(), 'rocket');
  });
}
