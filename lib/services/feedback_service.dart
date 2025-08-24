import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compudecsi/models/feedback.dart' as model;

class FeedbackService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('feedback');

  String? get currentUserId => _auth.currentUser?.uid;

  Future<model.FeedbackEntry?> getUserFeedbackForEvent(
    String userId,
    String eventId,
  ) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return model.FeedbackEntry.fromDoc(snap.docs.first);
  }

  Future<void> submit({
    required String eventId,
    int rating = 5,
    String? comment,
    String? sessionId,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw StateError('Usuário não autenticado');
    }

    // enforce one feedback per user per event
    final existing = await getUserFeedbackForEvent(uid, eventId);
    if (existing != null) {
      // update existing instead of duplicating
      await _col.doc(existing.id).set({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await _col.add({
      'eventId': eventId,
      'sessionId': sessionId,
      'userId': uid,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<model.FeedbackEntry>> watchEventFeedback(String eventId) {
    return _col
        .where('eventId', isEqualTo: eventId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => model.FeedbackEntry.fromDoc(d)).toList());
  }

  Future<double> averageForEvent(String eventId) async {
    final snap = await _col.where('eventId', isEqualTo: eventId).get();
    if (snap.docs.isEmpty) return 0;
    final sum = snap.docs.fold<int>(
      0,
      (acc, e) => acc + ((e.data()['rating'] as num).toInt()),
    );
    return sum / snap.docs.length;
  }
}
