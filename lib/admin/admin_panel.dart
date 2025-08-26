import 'package:compudecsi/admin/manage_users.dart';
import 'package:compudecsi/admin/feedback_dashboard.dart';
import 'package:compudecsi/admin/upload_event.dart';
import 'package:compudecsi/admin/manage_categories.dart';
import 'package:compudecsi/admin/manage_events.dart';
import 'package:compudecsi/utils/role_guard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRoles: const {'admin', 'speaker'},
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Administração'),
          backgroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.white,
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
                  // Show feedback dashboard for both admins and speakers
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
                  // Show upload event for both admins and speakers
                  ExpansionTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Gerenciar Palestras'),
                    subtitle: const Text('Criar, editar e excluir palestras'),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline, size: 20),
                        title: const Text('Criar Palestra'),
                        subtitle: const Text('Adicionar nova palestra'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UploadEvent(),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit, size: 20),
                        title: const Text('Editar Palestras'),
                        subtitle: const Text(
                          'Visualizar e modificar palestras',
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageEventsPage(),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, size: 20),
                        title: const Text('Excluir Palestras'),
                        subtitle: const Text('Remover palestras do sistema'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageEventsPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
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
