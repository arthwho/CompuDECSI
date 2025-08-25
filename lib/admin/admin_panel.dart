import 'package:compudecsi/admin/manage_users.dart';
import 'package:compudecsi/admin/feedback_dashboard.dart';
import 'package:compudecsi/admin/upload_event.dart';
import 'package:compudecsi/admin/manage_categories.dart';
import 'package:compudecsi/utils/role_guard.dart';
import 'package:flutter/material.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRoles: const {'admin'},
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Administração'),
          backgroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.white,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Gerenciar usuários'),
                subtitle: const Text('Alunos, palestrantes e administradores'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersPage()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.reviews),
                title: const Text('Feedback dos eventos'),
                subtitle: const Text('Médias e comentários enviados'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FeedbackDashboardPage(),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Criar palestra'),
                subtitle: const Text('Cadastro de eventos/palestras'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadEvent()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Gerenciar categorias'),
                subtitle: const Text('Adicionar, editar ou remover categorias'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageCategoriesPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
