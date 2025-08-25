import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/services/feedback_service.dart';
import 'package:compudecsi/utils/role_guard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackDashboardPage extends StatelessWidget {
  const FeedbackDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FeedbackService();
    return RoleGuard(
      requiredRoles: const {'admin', 'speaker'},
      builder: (context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Feedback dos eventos'),
          backgroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.white,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final currentUserRole =
                  userSnapshot.data?.data()?['role'] as String? ?? 'student';
              final isAdmin = currentUserRole == 'admin';

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var events = snapshot.data?.docs ?? const [];

                  // Filter events for speakers - only show events they're presenting
                  if (!isAdmin) {
                    final currentUserName =
                        userSnapshot.data?.data()?['Name'] as String?;
                    events = events.where((event) {
                      final eventSpeaker = event.data()['speaker'] as String?;
                      return eventSpeaker == currentUserName;
                    }).toList();
                  }

                  if (events.isEmpty) {
                    return Center(
                      child: Text(
                        isAdmin
                            ? 'Nenhum evento cadastrado.'
                            : 'Você não tem eventos com feedback ainda.',
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final e = events[index];
                      final title = e.data()['name'] as String? ?? 'Sem título';
                      final eventId = e.id;
                      return FutureBuilder<double>(
                        future: service.averageForEvent(eventId),
                        builder: (context, avgSnap) {
                          final avg = (avgSnap.data ?? 0).toStringAsFixed(2);
                          return ListTile(
                            title: Text(title),
                            subtitle: Text('Média de avaliações: $avg'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => _EventFeedbackList(
                                    eventId: eventId,
                                    title: title,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EventFeedbackList extends StatelessWidget {
  final String eventId;
  final String title;
  const _EventFeedbackList({required this.eventId, required this.title});

  @override
  Widget build(BuildContext context) {
    final service = FeedbackService();
    return Scaffold(
      appBar: AppBar(title: Text('Feedback — $title')),
      body: StreamBuilder(
        stream: service.watchEventFeedback(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = (snapshot.data as List?) ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('Sem feedbacks ainda.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = items[index];
              return ListTile(
                leading: Icon(Icons.star, color: Colors.amber[700]),
                title: Text('Nota: ${entry.rating}'),
                subtitle: Text(entry.comment ?? '-'),
                dense: true,
              );
            },
          );
        },
      ),
    );
  }
}
