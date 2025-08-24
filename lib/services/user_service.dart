import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? currentUserStream() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).snapshots();
  }

  Future<void> ensureUserOnSignIn({
    required String uid,
    required String? name,
    required String? email,
    required String? image,
  }) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();
    final now = FieldValue.serverTimestamp();

    if (!snap.exists) {
      await ref.set({
        'id': uid,
        'Name': name,
        'Email': email,
        'Image': image,
        'role': 'student',
        'createdAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
    } else {
      // Update basic profile without overwriting role
      await ref.set({
        'Name': name,
        'Email': email,
        'Image': image,
        'updatedAt': now,
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).set({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
