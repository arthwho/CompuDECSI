import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compudecsi/models/feedback.dart' as model;
import 'package:compudecsi/services/database.dart';

class FeedbackService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Get feedback collection for a specific event
  CollectionReference<Map<String, dynamic>> _feedbackCol(String eventId) =>
      _db.collection('events').doc(eventId).collection('feedback');

  String? get currentUserId => _auth.currentUser?.uid;

  Future<model.FeedbackEntry?> getUserFeedbackForEvent(
    String userId,
    String eventId,
  ) async {
    final snap = await _feedbackCol(
      eventId,
    ).where('userId', isEqualTo: userId).limit(1).get();
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
      await _feedbackCol(eventId).doc(existing.id).set({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await _feedbackCol(eventId).add({
      'sessionId': sessionId,
      'userId': uid,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<model.FeedbackEntry>> watchEventFeedback(String eventId) {
    return _feedbackCol(eventId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => model.FeedbackEntry.fromDoc(d)).toList());
  }

  Future<double> averageForEvent(String eventId) async {
    final snap = await _feedbackCol(eventId).get();
    if (snap.docs.isEmpty) return 0;
    final sum = snap.docs.fold<int>(
      0,
      (acc, e) => acc + ((e.data()['rating'] as num).toInt()),
    );
    return sum / snap.docs.length;
  }

  // Check if the current user can submit feedback for an event
  Future<bool> canUserSubmitFeedback(String eventId) async {
    final uid = currentUserId;
    if (uid == null) return false;

    // Check if user has checked-in to this event
    return await DatabaseMethods().isUserCheckedInToEvent(uid, eventId);
  }
}
