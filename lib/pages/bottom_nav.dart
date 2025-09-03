import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:compudecsi/pages/booking.dart';
import 'package:compudecsi/pages/home.dart';
import 'package:compudecsi/pages/profile.dart';
import 'package:compudecsi/admin/admin_panel.dart';
import 'package:compudecsi/admin/manage_events.dart';
import 'package:compudecsi/admin/qr_scanner_page.dart';
import 'package:compudecsi/admin/checkin_audit_page.dart';
import 'package:compudecsi/utils/variables.dart';

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
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        page: const Home(),
      ),
      _TabItem(
        label: 'Minhas Palestras',
        icon: const Icon(Icons.confirmation_num_outlined),
        selectedIcon: const Icon(Icons.confirmation_num),
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
        final isSpeaker = role == 'speaker';
        final isStaff = role == 'staff';
        final hasAdminAccess = isAdmin || isSpeaker;
        final hasStaffAccess = isStaff;
        final tabs = _buildTabs(isAdmin: isAdmin, userImage: userImage);
        // Clamp index if tabs changed (e.g., admin -> non-admin)
        if (currentIndex >= tabs.length) currentIndex = tabs.length - 1;

        return Scaffold(
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xffC4C4C4), width: 1),
              ),
            ),
            child: NavigationBar(
              elevation: 3,
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
                      backgroundColor: Colors.transparent,
                    ),
                    selectedIcon: CircleAvatar(
                      backgroundImage: NetworkImage(t.userImage!),
                      radius: 12,
                      backgroundColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(
                              0xff841e73,
                            ), // Your primary purple color
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    label: t.label,
                  );
                }
                return NavigationDestination(
                  icon: t.icon,
                  selectedIcon: t.selectedIcon,
                  label: t.label,
                );
              }).toList(),
            ),
          ),
          body: tabs[currentIndex].page,
          floatingActionButton: hasAdminAccess
              ? FloatingActionButton.extended(
                  onPressed: () {
                    if (isSpeaker) {
                      // For lecturers (speakers), navigate to manage events page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageEventsPage(),
                        ),
                      );
                    } else {
                      // For admins, navigate to admin panel
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminPanel()),
                      );
                    }
                  },
                  icon: Icon(
                    isSpeaker ? Icons.event : Icons.admin_panel_settings,
                  ),
                  label: Text(isSpeaker ? 'Meus Eventos' : 'Admin'),
                )
              : hasStaffAccess
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckinAuditPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.event_available),
                  label: const Text('Check-ins'),
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
  final Icon? selectedIcon;
  final Widget page;
  final String? userImage;
  _TabItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    required this.page,
    this.userImage,
  });
}
