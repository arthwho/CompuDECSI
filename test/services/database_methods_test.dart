import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:compudecsi/services/database.dart';

void main() {
  group('DatabaseMethods enrollment', () {
    test('enrollUserInEvent generates and persists 6-digit code', () async {
      final fake = FakeFirebaseFirestore();
      final db = DatabaseMethods(firestore: fake);

      final code = await db.enrollUserInEvent('u1', 'e1');
      expect(code.length, 6);

      final doc = await fake.collection('enrollments').doc('u1_e1').get();
      expect(doc.exists, true);
      expect(doc.data()!['enrollmentCode'], code);
      expect(doc.data()!['eventId'], 'e1');
      expect(doc.data()!['userId'], 'u1');
    });

    test('generates unique codes per event', () async {
      final fake = FakeFirebaseFirestore();
      final db = DatabaseMethods(firestore: fake);

      final c1 = await db.enrollUserInEvent('u1', 'e1');
      final c2 = await db.enrollUserInEvent('u2', 'e1');
      expect(c1, isNot(equals(c2)));
    });

    test('getEnrollmentCode creates one when missing', () async {
      final fake = FakeFirebaseFirestore();
      final db = DatabaseMethods(firestore: fake);

      await fake.collection('enrollments').doc('u1_e1').set({
        'userId': 'u1',
        'eventId': 'e1',
      });

      final code = await db.getEnrollmentCode('u1', 'e1');
      expect(code, isNotNull);
      expect(code!.length, 6);

      final doc = await fake.collection('enrollments').doc('u1_e1').get();
      expect(doc.data()!['enrollmentCode'], code);
    });
  });

  test('addUserBooking and addAdminBooking persist booking data', () async {
    final fake = FakeFirebaseFirestore();
    final db = DatabaseMethods(firestore: fake);

    final booking = {
      'name': 'User',
      'lectureName': 'Talk',
      'eventId': 'e1',
      'enrollmentCode': '123456',
    };

    await db.addUserBooking(booking, 'u1');
    await db.addAdminBooking(booking);

    final userBookings = await fake
        .collection('users')
        .doc('u1')
        .collection('bookings')
        .get();
    expect(userBookings.docs.length, 1);
    expect(userBookings.docs.first.data()['eventId'], 'e1');

    final lectures = await fake.collection('lectures').get();
    expect(lectures.docs.length, 1);
    expect(lectures.docs.first.data()['lectureName'], 'Talk');
  });
}
