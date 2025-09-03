import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  String _query = '';

  // Multi-selection state
  Set<String> _selectedUserIds = {};
  bool _isSelectionMode = false;

  // Global key for the role change button
  final GlobalKey _roleButtonKey = GlobalKey();

  Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream() {
    return _db
        .collection('users')
        .orderBy('Name', descending: false)
        .snapshots();
  }

  bool _isAdmin(DocumentSnapshot<Map<String, dynamic>>? userDoc) {
    if (userDoc == null || !userDoc.exists) return false;
    final role = userDoc.data()?['role'] as String?;
    return role == 'admin';
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedUserIds.clear();
      }
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _selectAllUsers(List<DocumentSnapshot<Map<String, dynamic>>> docs) {
    setState(() {
      if (_selectedUserIds.length == docs.length) {
        _selectedUserIds.clear();
      } else {
        _selectedUserIds = docs.map((doc) => doc.id).toSet();
      }
    });
  }

  Future<void> _changeMultipleRoles(String newRole) async {
    if (_selectedUserIds.isEmpty) return;

    try {
      final batch = _db.batch();

      for (String userId in _selectedUserIds) {
        final userRef = _db.collection('users').doc(userId);
        batch.set(userRef, {
          'role': newRole,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedUserIds.length} usuários atualizados para $newRole',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear selection and exit selection mode
        setState(() {
          _selectedUserIds.clear();
          _isSelectionMode = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar usuários: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedUserIds.length} usuários selecionados')
            : const Text('Gerenciar usuários'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: currentUid == null
              ? null
              : _db.collection('users').doc(currentUid).snapshots(),
          builder: (context, meSnap) {
            if (currentUid == null) {
              return const Center(child: Text('Precisa estar autenticado.'));
            }
            if (!meSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!_isAdmin(meSnap.data)) {
              return const Center(
                child: Text('Acesso negado (somente admin).'),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.border),
                        borderRadius: AppBorderRadius.md,
                      ),
                      labelText: 'Buscar por nome ou email',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _usersStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs.where((d) {
                        final data = d.data();
                        final name = (data['Name'] ?? '')
                            .toString()
                            .toLowerCase();
                        final email = (data['Email'] ?? '')
                            .toString()
                            .toLowerCase();
                        return _query.isEmpty ||
                            name.contains(_query) ||
                            email.contains(_query);
                      }).toList();

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text('Nenhum usuário encontrado.'),
                        );
                      }

                      return Column(
                        children: [
                          // Select All button (only visible in selection mode)
                          if (_isSelectionMode)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value:
                                        _selectedUserIds.length == docs.length,
                                    onChanged: (_) => _selectAllUsers(docs),
                                  ),
                                  Text(
                                    _selectedUserIds.length == docs.length
                                        ? 'Desmarcar todos'
                                        : 'Selecionar todos',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_selectedUserIds.length} de ${docs.length} selecionados',
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: docs.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final data = doc.data();
                                final image = (data['Image'] ?? '') as String;
                                final name =
                                    (data['Name'] ?? 'Sem nome') as String;
                                final email = (data['Email'] ?? '') as String;
                                final role =
                                    (data['role'] ?? 'student') as String;
                                final isSelected = _selectedUserIds.contains(
                                  doc.id,
                                );

                                return ListTile(
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isSelectionMode)
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) =>
                                              _toggleUserSelection(doc.id),
                                        ),
                                      image.isNotEmpty
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                image,
                                              ),
                                            )
                                          : const CircleAvatar(
                                              child: Icon(Icons.person),
                                            ),
                                    ],
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(email),
                                  trailing: _isSelectionMode
                                      ? null
                                      : DropdownButton<String>(
                                          value: role,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'student',
                                              child: Text('Aluno'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'speaker',
                                              child: Text('Palestrante'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'staff',
                                              child: Text('Staff'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'admin',
                                              child: Text('Admin'),
                                            ),
                                          ],
                                          onChanged: (value) async {
                                            if (value == null) return;
                                            await _db
                                                .collection('users')
                                                .doc(doc.id)
                                                .set({
                                                  'role': value,
                                                  'updatedAt':
                                                      FieldValue.serverTimestamp(),
                                                }, SetOptions(merge: true));
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Papel atualizado.',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 8,
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _isSelectionMode
                ? Row(
                    children: [
                      // X button to exit selection mode
                      FilledButton(
                        onPressed: _toggleSelectionMode,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.destructive,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Role change dropdown
                      Expanded(
                        child: FilledButton.icon(
                          key: _roleButtonKey,
                          onPressed: () {
                            // Show the same popup menu as in the AppBar
                            final RenderBox? button =
                                _roleButtonKey.currentContext
                                        ?.findRenderObject()
                                    as RenderBox?;
                            if (button != null) {
                              final Offset offset = button.localToGlobal(
                                Offset.zero,
                              );
                              final Size buttonSize = button.size;

                              showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  offset.dx,
                                  offset.dy -
                                      10, // Position just above the button
                                  offset.dx + buttonSize.width,
                                  offset.dy,
                                ),
                                items: [
                                  const PopupMenuItem(
                                    value: 'student',
                                    child: Text('Definir como Aluno'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'speaker',
                                    child: Text('Definir como Palestrante'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'staff',
                                    child: Text('Definir como Staff'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'admin',
                                    child: Text('Definir como Admin'),
                                  ),
                                ],
                              ).then((value) {
                                if (value != null) {
                                  _changeMultipleRoles(value);
                                }
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Alterar papel em massa',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : FilledButton.icon(
                    onPressed: _toggleSelectionMode,
                    icon: const Icon(Icons.checklist),
                    label: const Text(
                      'Modo seleção múltipla',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
