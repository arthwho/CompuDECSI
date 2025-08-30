import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap, SetOptions(merge: true));
  }

  Future<bool> addEvent(Map<String, dynamic> userInfoMap, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("events")
          .doc(id)
          .set(userInfoMap);
      return true;
    } catch (e) {
      print("Error adding event: $e");
      return false;
    }
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

  // Enrollment methods - now stored as subcollections within events
  Future<String> enrollUserInEvent(String userId, String eventId) async {
    try {
      // Get user information for analytics
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();

      Map<String, dynamic> userData = {"userName": '', "userEmail": ''};

      if (userDoc.exists) {
        final userInfo = userDoc.data() as Map<String, dynamic>;
        userData = {
          "userName":
              userInfo['Name'] ??
              userInfo['name'] ??
              userInfo['userName'] ??
              '',
          "userEmail":
              userInfo['Email'] ??
              userInfo['email'] ??
              userInfo['userEmail'] ??
              '',
        };

        // Debug: Print user info to see what's available
        print("User document exists for $userId");
        print("User info: $userInfo");
        print("Extracted userName: ${userData['userName']}");
        print("Extracted userEmail: ${userData['userEmail']}");
      } else {
        print("User document does not exist for $userId");
      }

      // Generate a unique 6-digit enrollment code for this user in this event
      final code = await _generateUniqueEnrollmentCode(eventId);
      await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("enrollments")
          .doc(userId)
          .set({
            "userId": userId,
            "userName": userData['userName'],
            "userEmail": userData['userEmail'],
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
          .collection("events")
          .doc(eventId)
          .collection("enrollments")
          .doc(userId)
          .delete();
    } catch (e) {
      print("Error unenrolling user from event: $e");
      throw e;
    }
  }

  Future<bool> isUserEnrolledInEvent(String userId, String eventId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("enrollments")
          .doc(userId)
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
          .collection("events")
          .doc(eventId)
          .collection("enrollments")
          .doc(userId)
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
          .collection("events")
          .doc(eventId)
          .collection("enrollments")
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

  // Get all enrollments for a specific event
  Stream<QuerySnapshot> getEventEnrollments(String eventId) {
    try {
      return FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("enrollments")
          .snapshots();
    } catch (e) {
      print("Error getting event enrollments: $e");
      throw e;
    }
  }

  // Get all events where a user is enrolled (requires collection group query)
  Stream<QuerySnapshot> getUserEnrolledEvents(String userId) {
    try {
      return FirebaseFirestore.instance
          .collectionGroup("enrollments")
          .where("userId", isEqualTo: userId)
          .snapshots();
    } catch (e) {
      print("Error getting user enrolled events: $e");
      throw e;
    }
  }

  Future addUserCheckIn(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("checkedIn")
        .add(userInfoMap);
  }

  // Enhanced check-in methods with staff tracking
  Future addUserCheckInWithStaff(
    Map<String, dynamic> userInfoMap,
    String userId,
    String staffId,
    String staffName,
  ) async {
    // Add staff information to check-in details
    userInfoMap['checkedInBy'] = {
      'staffId': staffId,
      'staffName': staffName,
      'checkedInAt': FieldValue.serverTimestamp(),
    };

    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("checkedIn")
        .add(userInfoMap);
  }

  Future addEventCheckIn(
    Map<String, dynamic> userInfoMap,
    String eventId,
    String staffId,
    String staffName,
  ) async {
    // Get user information for analytics if not already present
    if (!userInfoMap.containsKey('userName') ||
        !userInfoMap.containsKey('userEmail')) {
      final userId = userInfoMap['userId'];
      if (userId != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

          if (userDoc.exists) {
            final userInfo = userDoc.data() as Map<String, dynamic>;
            userInfoMap['userName'] =
                userInfo['Name'] ?? userInfo['name'] ?? '';
            userInfoMap['userEmail'] =
                userInfo['Email'] ?? userInfo['email'] ?? '';
          }
        } catch (e) {
          print("Error fetching user info for check-in: $e");
        }
      }
    }

    // Add staff information to check-in details
    userInfoMap['checkedInBy'] = {
      'staffId': staffId,
      'staffName': staffName,
      'checkedInAt': FieldValue.serverTimestamp(),
    };

    return await FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .collection("checkedIn")
        .add(userInfoMap);
  }

  Future addStaffCheckInLog(
    Map<String, dynamic> userInfoMap,
    String staffId,
    String staffName,
  ) async {
    // Get user information for analytics if not already present
    if (!userInfoMap.containsKey('userName') ||
        !userInfoMap.containsKey('userEmail')) {
      final userId = userInfoMap['userId'];
      if (userId != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

          if (userDoc.exists) {
            final userInfo = userDoc.data() as Map<String, dynamic>;
            userInfoMap['userName'] =
                userInfo['Name'] ?? userInfo['name'] ?? '';
            userInfoMap['userEmail'] =
                userInfo['Email'] ?? userInfo['email'] ?? '';
          }
        } catch (e) {
          print("Error fetching user info for staff check-in log: $e");
        }
      }
    }

    // Add staff information to check-in details
    userInfoMap['checkedInBy'] = {
      'staffId': staffId,
      'staffName': staffName,
      'checkedInAt': FieldValue.serverTimestamp(),
    };

    return await FirebaseFirestore.instance
        .collection("staff")
        .doc(staffId)
        .collection("checkIns")
        .add(userInfoMap);
  }

  // Get check-ins for a specific event
  Stream<QuerySnapshot> getEventCheckIns(String eventId) {
    return FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .collection("checkedIn")
        .orderBy('checkedInAt', descending: true)
        .snapshots();
  }

  // Get check-ins performed by a specific staff member
  Stream<QuerySnapshot> getStaffCheckIns(String staffId) {
    return FirebaseFirestore.instance
        .collection("staff")
        .doc(staffId)
        .collection("checkIns")
        .orderBy('checkedInAt', descending: true)
        .snapshots();
  }

  // Get all staff check-in logs (for admin audit)
  Stream<QuerySnapshot> getAllStaffCheckIns() {
    return FirebaseFirestore.instance
        .collectionGroup("checkIns")
        .orderBy('checkedInAt', descending: true)
        .snapshots();
  }

  // Update an existing event
  Future<bool> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .update(eventData);
      return true;
    } catch (e) {
      print("Error updating event: $e");
      return false;
    }
  }

  // Delete an event
  Future<bool> deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .delete();
      return true;
    } catch (e) {
      print("Error deleting event: $e");
      return false;
    }
  }

  // Get all events as a list (for admin management)
  Future<List<Map<String, dynamic>>> getAllEventsList() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("events")
          .get();

      List<Map<String, dynamic>> events = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Sort events by date (most recent first)
      events.sort((a, b) {
        try {
          final dateA = _parseDateString(a['date'] ?? '');
          final dateB = _parseDateString(b['date'] ?? '');
          return dateB.compareTo(dateA); // descending order
        } catch (e) {
          return 0;
        }
      });

      return events;
    } catch (e) {
      print("Error getting events list: $e");
      return [];
    }
  }

  // Helper method to parse date string (dd/MM/yyyy) to DateTime
  DateTime _parseDateString(String dateStr) {
    if (dateStr.isEmpty) return DateTime.now();
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]), // year
        int.parse(parts[1]), // month
        int.parse(parts[0]), // day
      );
    }
    return DateTime.now();
  }
}
