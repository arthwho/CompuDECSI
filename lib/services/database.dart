import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap, SetOptions(merge: true));
  }

  Future addEvent(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("events")
        .doc(id)
        .set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getAllEvents() async {
    return await FirebaseFirestore.instance.collection("events").snapshots();
  }

  Future<DocumentSnapshot?> getEventByCode(String code) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("events")
          .where("checkinCode", isEqualTo: code)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print("Error getting event by code: $e");
      return null;
    }
  }

  Future<DocumentSnapshot?> getEventById(String eventId) async {
    try {
      return await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .get();
    } catch (e) {
      print("Error getting event by ID: $e");
      return null;
    }
  }

  // Enrollment methods
  Future<String> enrollUserInEvent(String userId, String eventId) async {
    try {
      // Generate a unique 6-digit enrollment code for this user in this event
      final code = await _generateUniqueEnrollmentCode(eventId);
      await FirebaseFirestore.instance
          .collection("enrollments")
          .doc("${userId}_${eventId}")
          .set({
            "userId": userId,
            "eventId": eventId,
            "enrolledAt": FieldValue.serverTimestamp(),
            "enrollmentCode": code,
          });
      return code;
    } catch (e) {
      print("Error enrolling user in event: $e");
      throw e;
    }
  }

  Future<void> unenrollUserFromEvent(String userId, String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection("enrollments")
          .doc("${userId}_${eventId}")
          .delete();
    } catch (e) {
      print("Error unenrolling user from event: $e");
      throw e;
    }
  }

  Future<bool> isUserEnrolledInEvent(String userId, String eventId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("enrollments")
          .doc("${userId}_${eventId}")
          .get();
      return doc.exists;
    } catch (e) {
      print("Error checking enrollment status: $e");
      return false;
    }
  }

  Future<String?> getEnrollmentCode(String userId, String eventId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("enrollments")
          .doc("${userId}_${eventId}")
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        var code = data['enrollmentCode'] as String?;
        if (code == null || code.isEmpty) {
          code = await _generateUniqueEnrollmentCode(eventId);
          await doc.reference.update({"enrollmentCode": code});
        }
        return code;
      }
      return null;
    } catch (e) {
      print("Error fetching enrollment code: $e");
      return null;
    }
  }

  Future<String> _generateUniqueEnrollmentCode(String eventId) async {
    final rand = Random();
    // Try multiple times to avoid rare collisions within an event
    for (int i = 0; i < 10; i++) {
      final code = (rand.nextInt(900000) + 100000).toString();
      final exists = await _codeExistsForEvent(eventId, code);
      if (!exists) return code;
    }
    // Extremely unlikely: return last generated 6-digit code
    return (rand.nextInt(900000) + 100000).toString();
  }

  Future<bool> _codeExistsForEvent(String eventId, String code) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("enrollments")
          .where("eventId", isEqualTo: eventId)
          .where("enrollmentCode", isEqualTo: code)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking code uniqueness: $e");
      // On error, assume it exists to force another attempt
      return true;
    }
  }

  Stream<QuerySnapshot> getUserEnrolledEvents(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection("enrollments")
          .where("userId", isEqualTo: userId)
          .snapshots();
    } catch (e) {
      print("Error getting user enrolled events: $e");
      throw e;
    }
  }

  Future addUserBooking(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("bookings")
        .add(userInfoMap);
  }

  Future addAdminBooking(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("lectures")
        .add(userInfoMap);
  }
}
