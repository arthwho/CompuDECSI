import 'package:compudecsi/admin/manage_users.dart';
import 'package:compudecsi/admin/feedback_dashboard.dart';
import 'package:compudecsi/admin/manage_categories.dart';
import 'package:compudecsi/admin/manage_events.dart';
import 'package:compudecsi/admin/qr_scanner_page.dart';
import 'package:compudecsi/admin/checkin_audit_page.dart';
import 'package:compudecsi/utils/app_theme.dart';
import 'package:compudecsi/utils/role_guard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRoles: const {'admin', 'speaker', 'staff'},
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Administração'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: context.customBorder, height: 1.0),
          ),
        ),
        body: Container(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final role =
                  snapshot.data?.data()?['role'] as String? ?? 'student';
              final isAdmin = role == 'admin';
              final isStaff = role == 'staff';

              return ListView(
                children: [
                  const SizedBox(height: 8),
                  // Show user management only for admins
                  if (isAdmin) ...[
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Gerenciar usuários'),
                      subtitle: const Text(
                        'Alunos, palestrantes e administradores',
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageUsersPage(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  // Show feedback dashboard for admins, speakers, and staff
                  if (!isStaff) ...[
                    ListTile(
                      leading: const Icon(Icons.reviews),
                      title: const Text('Feedback dos eventos'),
                      subtitle: Text(
                        isAdmin
                            ? 'Médias e comentários enviados'
                            : 'Feedback dos seus eventos',
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeedbackDashboardPage(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  // Show event management for admins and speakers (not staff)
                  if (!isStaff) ...[
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('Gerenciar eventos'),
                      subtitle: const Text('Criar, editar e excluir eventos'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageEventsPage(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  // Show QR scanner for admins, speakers, and staff
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Scanner QR Code'),
                    subtitle: const Text('Fazer check-in dos participantes'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QRScannerPage()),
                    ),
                  ),
                  const Divider(height: 1),
                  // Show check-in audit for admins and staff
                  if (isAdmin || isStaff) ...[
                    ListTile(
                      leading: const Icon(Icons.assessment),
                      title: Text(
                        isAdmin ? 'Auditoria de Check-ins' : 'Check-ins',
                      ),
                      subtitle: Text(
                        isAdmin
                            ? 'Verificar check-ins por evento e staff'
                            : 'Verificar check-ins e realizar novos',
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckinAuditPage(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  // Show category management only for admins
                  if (isAdmin) ...[
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Gerenciar categorias'),
                      subtitle: const Text(
                        'Adicionar, editar ou remover categorias',
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageCategoriesPage(),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
