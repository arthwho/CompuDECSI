import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, speaker, admin, staff }

UserRole roleFromString(String? value) {
  switch (value) {
    case 'admin':
      return UserRole.admin;
    case 'speaker':
      return UserRole.speaker;
    case 'staff':
      return UserRole.staff;
    case 'student':
    default:
      return UserRole.student;
  }
}

String roleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.speaker:
      return 'speaker';
    case UserRole.staff:
      return 'staff';
    case UserRole.student:
      return 'student';
  }
}

class AppUser {
  final String id;
  final String? name;
  final String? email;
  final String? image;
  final UserRole role;

  AppUser({
    required this.id,
    required this.role,
    this.name,
    this.email,
    this.image,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      id: doc.id,
      name: data['Name'] as String?,
      email: data['Email'] as String?,
      image: data['Image'] as String?,
      role: roleFromString(data['role'] as String?),
    );
  }
}
