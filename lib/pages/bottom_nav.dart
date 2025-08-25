import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:compudecsi/pages/booking.dart';
import 'package:compudecsi/pages/home.dart';
import 'package:compudecsi/pages/profile.dart';
import 'package:compudecsi/admin/admin_panel.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;

  List<_TabItem> _buildTabs({required bool isAdmin, String? userImage}) {
    final tabs = <_TabItem>[
      _TabItem(
        label: 'Início',
        icon: const Icon(Icons.home_filled),
        page: const Home(),
      ),
      _TabItem(
        label: 'Palestras',
        icon: const Icon(Icons.bookmark),
        page: const Booking(),
      ),
      _TabItem(
        label: 'Perfil',
        icon: const Icon(Icons.person),
        page: const Profile(),
        userImage: userImage,
      ),
    ];
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final stream = user == null
        ? null
        : FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        final role = snap.data?.data()?['role'] as String? ?? 'student';
        final userImage = snap.data?.data()?['Image'] as String?;
        final isAdmin = role == 'admin';
        final tabs = _buildTabs(isAdmin: isAdmin, userImage: userImage);
        // Clamp index if tabs changed (e.g., admin -> non-admin)
        if (currentIndex >= tabs.length) currentIndex = tabs.length - 1;

        return Scaffold(
          bottomNavigationBar: NavigationBar(
            labelTextStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            selectedIndex: currentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            destinations: tabs.map((t) {
              // Special handling for profile tab with user image
              if (t.label == 'Perfil' &&
                  t.userImage != null &&
                  t.userImage!.isNotEmpty) {
                return NavigationDestination(
                  icon: CircleAvatar(
                    backgroundImage: NetworkImage(t.userImage!),
                    radius: 12,
                  ),
                  label: t.label,
                );
              }
              return NavigationDestination(icon: t.icon, label: t.label);
            }).toList(),
          ),
          body: tabs[currentIndex].page,
          floatingActionButton: isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminPanel()),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Admin'),
                )
              : null,
        );
      },
    );
  }
}

class _TabItem {
  final String label;
  final Icon icon;
  final Widget page;
  final String? userImage;
  _TabItem({
    required this.label,
    required this.icon,
    required this.page,
    this.userImage,
  });
}
