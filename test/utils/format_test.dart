import 'package:flutter_test/flutter_test.dart';
import 'package:compudecsi/utils/format.dart';

void main() {
  test('formatEnrollmentCode adds space between 3-3 digits', () {
    expect(formatEnrollmentCode('123456'), '123 456');
    expect(formatEnrollmentCode('000000'), '000 000');
  });

  test('formatEnrollmentCode leaves other lengths unchanged', () {
    expect(formatEnrollmentCode('12345'), '12345');
    expect(formatEnrollmentCode('1234567'), '1234567');
    expect(formatEnrollmentCode(''), '');
  });
}
