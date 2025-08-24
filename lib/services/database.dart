import 'package:cloud_firestore/cloud_firestore.dart';

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
  Future<void> enrollUserInEvent(String userId, String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection("enrollments")
          .doc("${userId}_${eventId}")
          .set({
            "userId": userId,
            "eventId": eventId,
            "enrolledAt": FieldValue.serverTimestamp(),
          });
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
