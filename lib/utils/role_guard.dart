import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoleGuard extends StatelessWidget {
  final Set<String> requiredRoles; // 'admin', 'speaker', 'student'
  final WidgetBuilder builder;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.requiredRoles,
    required this.builder,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return fallback ?? const _AccessDenied();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final role = snapshot.data?.data()?['role'] as String? ?? 'student';
        if (requiredRoles.contains(role)) {
          return builder(context);
        }
        return fallback ?? const _AccessDenied();
      },
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Acesso negado')));
  }
}
