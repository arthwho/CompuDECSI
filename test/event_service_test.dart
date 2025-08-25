import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/services/event_service.dart';

void main() {
  group('EventService.isFinished', () {
    final svc = EventService();

    test('returns false for future date string', () {
      final now = DateTime(2025, 1, 1, 12, 0, 0);
      final data = {
        'date': '02/01/2025', // dd/MM/yyyy (next day)
      };
      expect(svc.isFinished(data, now: now), isFalse);
    });

    test('returns true for past date string', () {
      final now = DateTime(2025, 1, 3, 0, 0, 0);
      final data = {'date': '01/01/2025'};
      expect(svc.isFinished(data, now: now), isTrue);
    });

    test('uses endAt Timestamp when present', () {
      final now = DateTime(2025, 1, 2, 0, 0, 0);
      final past = Timestamp.fromDate(DateTime(2025, 1, 1, 23, 59, 0));
      final future = Timestamp.fromDate(DateTime(2025, 1, 3, 0, 0, 0));

      expect(svc.isFinished({'endAt': past}, now: now), isTrue);
      expect(svc.isFinished({'endAt': future}, now: now), isFalse);
    });
  });

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
