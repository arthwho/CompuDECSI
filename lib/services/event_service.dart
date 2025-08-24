import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus { scheduled, live, finished }

EventStatus statusFromString(String? v) {
  switch (v) {
    case 'live':
      return EventStatus.live;
    case 'finished':
      return EventStatus.finished;
    case 'scheduled':
    default:
      return EventStatus.scheduled;
  }
}

String statusToString(EventStatus s) {
  switch (s) {
    case EventStatus.live:
      return 'live';
    case EventStatus.finished:
      return 'finished';
    case EventStatus.scheduled:
      return 'scheduled';
  }
}

class EventService {
  final _db = FirebaseFirestore.instance;

  /// Given an event map (doc.data()), determine if it's finished.
  /// Uses `endAt` Timestamp if present, otherwise falls back to `date` (dd/MM/yyyy)
  /// and considers it finished after the end of that day.
  bool isFinished(Map<String, dynamic> data, {DateTime? now}) {
    now ??= DateTime.now();
    final endAt = data['endAt'];
    if (endAt is Timestamp) {
      return endAt.toDate().isBefore(now);
    }
    final String? dateStr = data['date'] as String?;
    if (dateStr != null && dateStr.trim().isNotEmpty) {
      try {
        final parts = dateStr.split('/'); // dd/MM/yyyy
        final d = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
          23,
          59,
          59,
        );
        return d.isBefore(now);
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Optionally sync status to 'finished' for past events (admin/manual usage).
  Future<void> syncStatuses() async {
    final q = await _db.collection('events').get();
    final now = DateTime.now();
    final batch = _db.batch();
    for (final doc in q.docs) {
      final data = doc.data();
      if (isFinished(data, now: now)) {
        batch.set(doc.reference, {
          'status': 'finished',
        }, SetOptions(merge: true));
      }
    }
    await batch.commit();
  }
}
