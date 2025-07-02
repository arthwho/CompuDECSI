import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
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
