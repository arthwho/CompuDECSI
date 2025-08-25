import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/services/event_service.dart';

void main() {
  group('EventStatus mapping', () {
    test('statusFromString maps correctly', () {
      expect(statusFromString('live'), EventStatus.live);
      expect(statusFromString('finished'), EventStatus.finished);
      expect(statusFromString('scheduled'), EventStatus.scheduled);
      expect(statusFromString('anything-else'), EventStatus.scheduled);
    });

    test('statusToString maps correctly', () {
      expect(statusToString(EventStatus.live), 'live');
      expect(statusToString(EventStatus.finished), 'finished');
      expect(statusToString(EventStatus.scheduled), 'scheduled');
    });
  });
}
