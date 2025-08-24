import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar usuários')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
            return const Center(child: Text('Acesso negado (somente admin).'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: const InputDecoration(
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

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();
                        final image = (data['Image'] ?? '') as String;
                        final name = (data['Name'] ?? 'Sem nome') as String;
                        final email = (data['Email'] ?? '') as String;
                        final role = (data['role'] ?? 'student') as String;

                        return ListTile(
                          leading: image.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(image),
                                )
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(email),
                          trailing: DropdownButton<String>(
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
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (value) async {
                              if (value == null) return;
                              await _db.collection('users').doc(doc.id).set({
                                'role': value,
                                'updatedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Papel atualizado.'),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
