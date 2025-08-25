import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compudecsi/pages/detail_page.dart';
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/services/event_service.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final user = FirebaseAuth.instance.currentUser;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final EventService _eventService = EventService();

  String formatFirstAndLastName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return _capitalize(parts[0]);
    } else {
      return _capitalize(parts.first) + ' ' + _capitalize(parts.last);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Minhas Palestras'),
          backgroundColor: Colors.white,
        ),
        body: Center(child: Text('Faça login para ver suas palestras')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Minhas Palestras'),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _databaseMethods.getUserEnrolledEvents(user!.uid),
        builder: (context, enrollmentSnapshot) {
          if (enrollmentSnapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar palestras: ${enrollmentSnapshot.error}',
              ),
            );
          }

          if (!enrollmentSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final enrollments = enrollmentSnapshot.data!.docs;

          if (enrollments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Você ainda não se inscreveu em nenhuma palestra',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore as palestras disponíveis na página inicial',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: enrollments.length,
            itemBuilder: (context, index) {
              final enrollment =
                  enrollments[index].data() as Map<String, dynamic>;
              final eventId = enrollment['eventId'] as String;

              return FutureBuilder<DocumentSnapshot?>(
                future: _databaseMethods.getEventById(eventId),
                builder: (context, eventSnapshot) {
                  if (!eventSnapshot.hasData || eventSnapshot.data == null) {
                    return SizedBox.shrink();
                  }

                  final eventData =
                      eventSnapshot.data!.data() as Map<String, dynamic>?;
                  if (eventData == null) {
                    return SizedBox.shrink();
                  }

                  final isFinished = _eventService.isFinished(eventData);

                  return Center(
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                image: eventData['image'] ?? '',
                                name: eventData['name'] ?? '',
                                local: eventData['local'] ?? '',
                                date: eventData['date'] ?? '',
                                time: eventData['time'] ?? '',
                                description: eventData['description'] ?? '',
                                speaker: eventData['speaker'] ?? '',
                                speakerImage: eventData['speakerImage'] ?? '',
                                eventId: eventId,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // Card Header
                            ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      eventData['name'] ?? "Sem título",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFinished
                                          ? Colors.grey
                                          : AppColors.accent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isFinished ? 'Finalizada' : 'Agendada',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                bottom: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    eventData['date'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.btnPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.btnPrimary,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    eventData['time'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.btnPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.btnPrimary,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    eventData['local'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.btnPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Event details
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      eventData['speakerImage'] != null &&
                                              eventData['speakerImage']
                                                  .toString()
                                                  .isNotEmpty
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                eventData['speakerImage'],
                                              ),
                                              radius: 20,
                                            )
                                          : Icon(
                                              Icons.account_circle,
                                              size: 40,
                                            ),
                                      SizedBox(width: 8),
                                      Text(
                                        formatFirstAndLastName(
                                          eventData['speaker'],
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
