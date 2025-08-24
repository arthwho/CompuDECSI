import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/pages/qa_page.dart';
import 'package:compudecsi/services/shared_pref.dart';
import 'package:compudecsi/services/event_service.dart';
import 'package:compudecsi/pages/feedback_page.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class DetailsPage extends StatefulWidget {
  String image, name, local, date, time, description, speaker;
  String? eventId;
  String? speakerImage;
  DetailsPage({
    required this.image,
    required this.name,
    required this.local,
    required this.date,
    required this.time,
    required this.description,
    required this.speaker,
    this.eventId,
    this.speakerImage,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String? id, name, image;
  String? checkinCode;
  Map<String, dynamic>? _eventData;
  bool _isFinished = false;
  bool _isEnrolled = false;
  bool _isLoadingEnrollment = true;

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  ontheload() async {
    id = await SharedpreferenceHelper().getUserId();
    name = await SharedpreferenceHelper().getUserName();
    image = await SharedpreferenceHelper().getUserImage();

    if (widget.eventId != null) {
      await _fetchEvent();
      await _checkEnrollmentStatus();
    }

    setState(() {});
  }

  Future<void> _fetchEvent() async {
    try {
      DocumentSnapshot? eventDoc = await DatabaseMethods().getEventById(
        widget.eventId!,
      );
      if (eventDoc != null && eventDoc.exists) {
        final data = eventDoc.data() as Map<String, dynamic>;
        final finished = EventService().isFinished(data);
        setState(() {
          _eventData = data;
          _isFinished = finished;
          checkinCode = data['checkinCode'] as String?;
        });
      }
    } catch (e) {
      print("Error fetching check-in code: $e");
    }
  }

  Future<void> _checkEnrollmentStatus() async {
    if (id == null || widget.eventId == null) {
      setState(() {
        _isLoadingEnrollment = false;
      });
      return;
    }

    try {
      bool enrolled = await DatabaseMethods().isUserEnrolledInEvent(
        id!,
        widget.eventId!,
      );
      setState(() {
        _isEnrolled = enrolled;
        _isLoadingEnrollment = false;
      });
    } catch (e) {
      print("Error checking enrollment status: $e");
      setState(() {
        _isLoadingEnrollment = false;
      });
    }
  }

  Future<void> _enrollInEvent() async {
    if (id == null || widget.eventId == null) return;

    try {
      await DatabaseMethods().enrollUserInEvent(id!, widget.eventId!);
      setState(() {
        _isEnrolled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscrição realizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao realizar inscrição. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
      print("Error enrolling in event: $e");
    }
  }

  Future<void> _unenrollFromEvent() async {
    if (id == null || widget.eventId == null) return;

    try {
      await DatabaseMethods().unenrollUserFromEvent(id!, widget.eventId!);
      setState(() {
        _isEnrolled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscrição cancelada com sucesso!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar inscrição. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
      print("Error unenrolling from event: $e");
    }
  }

  void _showCodeInputDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CodeInputDialog(
          onCodeSubmitted: (String code) {
            _validateAndCheckin(code);
          },
        );
      },
    );
  }

  Future<void> _validateAndCheckin(String code) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // Validate the code
      DocumentSnapshot? eventDoc = await DatabaseMethods().getEventByCode(code);

      // Hide loading indicator
      Navigator.of(context).pop();

      if (eventDoc != null) {
        // Code is valid, proceed with check-in
        await makeBooking();
      } else {
        // Code is invalid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Código inválido. Verifique o código fornecido pelo palestrante.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao validar código. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
      print(e);
    }
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        margin: EdgeInsets.only(
          left: AppSpacing.viewPortSide,
          right: AppSpacing.viewPortSide,
          bottom: AppSpacing.viewPortBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (_isFinished) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: AppColors.purple,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Evento finalizado',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.date,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.btnPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.btnPrimary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.time,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.btnPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.btnPrimary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.local,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.btnPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(8),
                  //   child: Image.asset(
                  //     'assets/icea.png',
                  //     width: MediaQuery.of(context).size.width,
                  //     fit: BoxFit.cover,
                  //     height: 200,
                  //   ),
                  // ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      widget.speakerImage != null &&
                              widget.speakerImage!.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                widget.speakerImage!,
                              ),
                              radius: 20,
                            )
                          : Icon(Icons.account_circle, size: 40),
                      SizedBox(width: 8),
                      Text(
                        formatFirstAndLastName(widget.speaker),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(widget.description!, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            // Action buttons
            if (_isLoadingEnrollment)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_isFinished)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FilledButton(
                  onPressed: () {
                    final title = 'Avaliar — ' + widget.name;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FeedbackPage(
                          eventId: widget.eventId ?? widget.name,
                          eventTitle: title,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                  ),
                  child: const Text(
                    'Avaliar evento',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else if (!_isEnrolled)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FilledButton(
                  onPressed: _enrollInEvent,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                  ),
                  child: const Text(
                    'Inscrever-se',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            // Q&A and Check-in buttons (only show when enrolled)
            if (_isEnrolled && !_isLoadingEnrollment)
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.red, AppColors.purple],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: FilledButton(
                              onPressed: _isFinished
                                  ? null
                                  : () {
                                      final sessionId =
                                          widget.eventId ??
                                          widget.name.trim().toLowerCase();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => QAPage(
                                            sessionId: sessionId,
                                            sessionTitle:
                                                'Q&A — ' + widget.name,
                                          ),
                                        ),
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                _isFinished
                                    ? 'Q&A indisponível (finalizado)'
                                    : 'Participar do Q&A',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: OutlinedButton(
                        onPressed: _isFinished ? null : _showCodeInputDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.purple,
                          side: BorderSide(color: AppColors.purple, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          _isFinished
                              ? 'Check-in indisponível (finalizado)'
                              : 'Fazer checkin',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: OutlinedButton(
                        onPressed: _unenrollFromEvent,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          'Cancelar inscrição',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> makeBooking() async {
    try {
      Map<String, dynamic> bookingDetail = {
        "name": name,
        "image": image,
        "date": widget.date,
        "time": widget.time,
        "lectureName": widget.name,
        "lectureImage": widget.image,
        "Date": widget.date,
        "Time": widget.time,
        "Speaker": widget.speaker,
        "Location": widget.local,
      };
      await DatabaseMethods().addUserBooking(bookingDetail, id!).then((
        value,
      ) async {
        await DatabaseMethods().addAdminBooking(bookingDetail);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkin realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }
}
