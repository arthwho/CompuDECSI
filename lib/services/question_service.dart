import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compudecsi/models/question.dart';

class QuestionService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  QuestionService({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _qCol(String sessionId) {
    return _db.collection('sessions').doc(sessionId).collection('questions');
  }

  Stream<List<Question>> watchQuestions(String sessionId) {
    return _qCol(sessionId)
        .orderBy('statusOrder')
        .orderBy('voteCount', descending: true)
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map((d) => Question.fromDoc(d)).toList());
  }

  Future<void> submitQuestion({
    required String sessionId,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }
    final now = FieldValue.serverTimestamp();
    final initialStatus = 'pending';
    await _qCol(sessionId).add({
      'text': text.trim(),
      'authorId': user.uid,
      'authorName': user.displayName,
      'createdAt': now,
      'status': initialStatus,
      'statusOrder': Question.mapStatusOrder(initialStatus),
      'voteCount': 0,
      'pinned': false,
    });
  }

  Future<void> toggleVote({
    required String sessionId,
    required String questionId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }
    final qref = _qCol(sessionId).doc(questionId);
    final vref = qref.collection('votes').doc(user.uid);

    await _db.runTransaction((tx) async {
      final vsnap = await tx.get(vref);
      final qsnap = await tx.get(qref);
      final current = (qsnap.data()?['voteCount'] as int?) ?? 0;
      if (vsnap.exists) {
        tx.delete(vref);
        tx.update(qref, {'voteCount': current - 1});
      } else {
        tx.set(vref, {'type': 'up', 'createdAt': FieldValue.serverTimestamp()});
        tx.update(qref, {'voteCount': current + 1});
      }
    });
  }

  Future<bool> hasVoted({
    required String sessionId,
    required String questionId,
    String? uid,
  }) async {
    final user = uid ?? _auth.currentUser?.uid;
    if (user == null) return false;
    final vref = _qCol(sessionId).doc(questionId).collection('votes').doc(user);
    final snap = await vref.get();
    return snap.exists;
  }

  Stream<bool> watchVoted({
    required String sessionId,
    required String questionId,
    String? uid,
  }) {
    final user = uid ?? _auth.currentUser?.uid;
    if (user == null) {
      return const Stream<bool>.empty();
    }
    final vref = _qCol(sessionId).doc(questionId).collection('votes').doc(user);
    return vref.snapshots().map((s) => s.exists);
  }

  Future<void> setStatus({
    required String sessionId,
    required String questionId,
    required String status,
  }) async {
    await _qCol(sessionId).doc(questionId).update({
      'status': status,
      'statusOrder': Question.mapStatusOrder(status),
      if (status == 'accepted') 'acceptedAt': FieldValue.serverTimestamp(),
      if (status == 'answered') 'answeredAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setPinned({
    required String sessionId,
    required String questionId,
    required bool pinned,
  }) async {
    await _qCol(sessionId).doc(questionId).update({
      'pinned': pinned,
      'statusOrder': pinned
          ? Question.mapStatusOrder('pinned')
          : Question.mapStatusOrder('pending'),
    });
  }
}
