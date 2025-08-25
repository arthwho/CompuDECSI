import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/services/event_service.dart';

void main() {
  test('EventService.syncStatuses marks finished events', () async {
    final fake = FakeFirebaseFirestore();

    // Past by endAt
    await fake.collection('events').add({
      'name': 'Past via endAt',
      'endAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
    });
    // Future by endAt
    await fake.collection('events').add({
      'name': 'Future via endAt',
      'endAt': Timestamp.fromDate(DateTime(2030, 1, 1)),
    });
    // Past by date dd/MM/yyyy
    await fake.collection('events').add({
      'name': 'Past via date',
      'date': '01/01/2025',
    });

    final svc = EventService(db: fake);
    await svc.syncStatuses();

    final all = await fake.collection('events').get();
    final statuses = all.docs.map((d) => d.data()['status']).toList();
    expect(statuses.where((s) => s == 'finished').length, 2);
  });
}
