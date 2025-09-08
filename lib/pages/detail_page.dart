import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/pages/qa_page.dart';
import 'package:compudecsi/services/shared_pref.dart';
import 'package:compudecsi/services/event_service.dart';
import 'package:compudecsi/pages/feedback_page.dart';
import 'package:compudecsi/services/notification_service.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compudecsi/admin/manage_events.dart';
import 'package:compudecsi/widgets/qr_code_bottom_sheet.dart';
import 'dart:async';
import 'package:compudecsi/utils/app_theme.dart' as theme;

// ignore: must_be_immutable
class DetailsPage extends StatefulWidget {
  String image, name, local, date, time, description, speaker;
  String? eventId;
  String? speakerImage;
  DetailsPage({
    super.key,
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
  String? _enrollmentCode;
  Map<String, dynamic>? _eventData;
  bool _isFinished = false;
  bool _isEnrolled = false;
  bool _isLoadingEnrollment = true;
  bool _isEventStarted = false;
  String _countdownText = '';
  Timer? _countdownTimer;
  String? userRole;
  String? currentUserName;

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  ontheload() async {
    id = await SharedpreferenceHelper().getUserId();
    name = await SharedpreferenceHelper().getUserName();
    image = await SharedpreferenceHelper().getUserImage();

    // Load user role for edit/delete permissions
    await _loadUserRole();

    if (widget.eventId != null) {
      await _fetchEvent();
      await _checkEnrollmentStatus();
    }

    // Start countdown timer for Q&A
    _startCountdownTimer();

    setState(() {});
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            userRole = userData['role'] ?? 'student';
            currentUserName = userData['Name'] ?? '';
          });
        }
      } catch (e) {
        print('Error loading user role: $e');
        setState(() {
          userRole = 'student';
        });
      }
    }
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
      String? code;
      if (enrolled) {
        code = await DatabaseMethods().getEnrollmentCode(id!, widget.eventId!);
      }
      setState(() {
        _isEnrolled = enrolled;
        _enrollmentCode = code;
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
      final code = await DatabaseMethods().enrollUserInEvent(
        id!,
        widget.eventId!,
      );
      setState(() {
        _isEnrolled = true;
        _enrollmentCode = code;
      });

      // Schedule notification for the event
      await _scheduleEventNotification();

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

  Future<void> _scheduleEventNotification() async {
    if (widget.eventId == null) return;

    try {
      print('=== DETAIL PAGE NOTIFICATION DEBUG ===');
      print('Event ID: ${widget.eventId}');
      print('Event Name: ${widget.name}');
      print('Event Date: ${widget.date}');
      print('Event Time: ${widget.time}');

      // Parse event date and time
      final eventDateTime = _parseEventDateTime(widget.date, widget.time);
      print('Parsed DateTime: $eventDateTime');

      if (eventDateTime != null) {
        print('About to call NotificationService.scheduleEventNotification...');

        await NotificationService().scheduleEventNotification(
          eventId: widget.eventId!,
          eventTitle: widget.name,
          eventLocation: widget.local,
          eventDateTime: eventDateTime,
          eventDescription: widget.description,
        );

        print('✅ Notification scheduled for event: ${widget.name}');

        // Verify the notification was actually scheduled
        final pendingNotifications = await NotificationService()
            .getPendingNotifications();
        print('=== VERIFICATION ===');
        print(
          'Total pending notifications after scheduling: ${pendingNotifications.length}',
        );
        for (var notification in pendingNotifications) {
          print(
            'Pending notification: ID=${notification.id}, Title=${notification.title}',
          );
        }
      } else {
        print('❌ Failed to parse event date/time');
      }
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  DateTime? _parseEventDateTime(String date, String time) {
    try {
      print('=== DATE PARSING DEBUG ===');
      print('Input date: "$date"');
      print('Input time: "$time"');

      // Parse date (assuming format like "15/12/2024")
      final dateParts = date.split('/');
      print('Date parts: $dateParts');
      if (dateParts.length != 3) {
        print(
          '❌ Invalid date format - expected 3 parts, got ${dateParts.length}',
        );
        return null;
      }

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      print('Parsed date: day=$day, month=$month, year=$year');

      // Parse time (assuming format like "14:30")
      final timeParts = time.split(':');
      print('Time parts: $timeParts');
      if (timeParts.length != 2) {
        print(
          '❌ Invalid time format - expected 2 parts, got ${timeParts.length}',
        );
        return null;
      }

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      print('Parsed time: hour=$hour, minute=$minute');

      // Create DateTime in local timezone (Brazil)
      final result = DateTime(year, month, day, hour, minute);
      print('✅ Final DateTime: $result');
      print('DateTime timezone: ${result.timeZoneName}');
      print('DateTime is UTC: ${result.isUtc}');
      return result;
    } catch (e) {
      print('❌ Error parsing date/time: $e');
      return null;
    }
  }

  void _startCountdownTimer() {
    final eventDateTime = _parseEventDateTime(widget.date, widget.time);
    if (eventDateTime == null) return;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = eventDateTime.difference(now);

      if (difference.isNegative) {
        // Event has started
        setState(() {
          _isEventStarted = true;
          _countdownText = '';
        });
        timer.cancel();
      } else {
        // Event hasn't started yet, update countdown
        setState(() {
          _isEventStarted = false;
          _countdownText = _formatCountdown(difference);
        });
      }
    });
  }

  String _formatCountdown(Duration difference) {
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h ${difference.inMinutes % 60}m';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m ${difference.inSeconds % 60}s';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ${difference.inSeconds % 60}s';
    } else {
      return '${difference.inSeconds}s';
    }
  }

  String _formatEnrollmentCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)} ${code.substring(3)}';
    }
    return code;
  }

  void _showQRCodeBottomSheet() {
    if (_enrollmentCode == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return QRCodeBottomSheet(
          enrollmentCode: _enrollmentCode!,
          eventName: widget.name,
        );
      },
    );
  }

  Future<void> _copyEnrollmentCode() async {
    if (_enrollmentCode == null) return;
    await Clipboard.setData(ClipboardData(text: _enrollmentCode!));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado para a área de transferência'),
      ),
    );
  }

  Future<void> _unenrollFromEvent() async {
    if (id == null || widget.eventId == null) return;

    try {
      await DatabaseMethods().unenrollUserFromEvent(id!, widget.eventId!);
      setState(() {
        _isEnrolled = false;
      });

      // Cancel the scheduled notification for this event
      await NotificationService().cancelEventNotification(widget.eventId!);

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

      // Only accept the user's unique enrollment code for this event
      final isOwnEnrollmentCode =
          _enrollmentCode != null && code.trim() == _enrollmentCode;

      // Hide loading indicator
      Navigator.of(context).pop();

      if (isOwnEnrollmentCode) {
        await performCheckIn();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código inválido. Use seu código de inscrição.'),
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
      return '${_capitalize(parts.first)} ${_capitalize(parts.last)}';
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  bool _canEditEvent() {
    if (userRole == 'admin') {
      return true; // Admins can edit all events
    }

    if (userRole == 'speaker' && currentUserName != null) {
      // Speakers can only edit events they are lecturing
      return widget.speaker == currentUserName;
    }

    return false; // Students cannot edit events
  }

  void _showEditEventDialog() {
    if (widget.eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID do evento não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageEventsPage()),
    ).then((_) {
      // Refresh the page when returning from edit
      ontheload();
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir o evento "${widget.name}"?\n\nEsta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (widget.eventId != null) {
                  final success = await DatabaseMethods().deleteEvent(
                    widget.eventId!,
                  );

                  if (success) {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evento excluído com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    Navigator.of(context).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao excluir evento'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_canEditEvent()) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditEventDialog,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          ],
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: AppSpacing.viewPortSide,
          right: AppSpacing.viewPortSide,
          bottom: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  if (_isFinished) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          color:
                              Theme.of(context)
                                  .extension<theme.CustomColors>()
                                  ?.highlightedText ??
                              theme.CustomColors.light.highlightedText,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Evento finalizado',
                          style: TextStyle(
                            color:
                                Theme.of(context)
                                    .extension<theme.CustomColors>()
                                    ?.highlightedText ??
                                theme.CustomColors.light.highlightedText,
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
                              color:
                                  Theme.of(context)
                                      .extension<theme.CustomColors>()
                                      ?.highlightedText ??
                                  theme.CustomColors.light.highlightedText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context)
                                      .extension<theme.CustomColors>()
                                      ?.highlightedText ??
                                  theme.CustomColors.light.highlightedText,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.time,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context)
                                      .extension<theme.CustomColors>()
                                      ?.highlightedText ??
                                  theme.CustomColors.light.highlightedText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context)
                                      .extension<theme.CustomColors>()
                                      ?.highlightedText ??
                                  theme.CustomColors.light.highlightedText,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.local,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context)
                                      .extension<theme.CustomColors>()
                                      ?.highlightedText ??
                                  theme.CustomColors.light.highlightedText,
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
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.description,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // QR Code button (only show when enrolled and event is not finished)
                  if (_isEnrolled && !_isLoadingEnrollment && !_isFinished)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: context.customCategoryBG,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _showQRCodeBottomSheet,
                        icon: Icon(
                          Icons.qr_code_scanner,
                          color: context.customCategoryBG,
                        ),
                        label: Text(
                          'VER INGRESSO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.customCategoryBG,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Action buttons

            // Removed Inscrever-se button - moved to BottomAppBar
            // Q&A and Check-in buttons (only show when enrolled and event is not finished)
            if (_isEnrolled && !_isLoadingEnrollment && !_isFinished)
              Container(
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextButton(
                        onPressed: _unenrollFromEvent,
                        style: TextButton.styleFrom(
                          foregroundColor: context.appColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.customBorder, width: 1),
          ),
        ),
        child: BottomAppBar(
          color: Theme.of(context).cardColor,
          elevation: 8,
          height: 80, // Increased height to accommodate the button
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _isLoadingEnrollment
                ? const Center(child: CircularProgressIndicator())
                : _isFinished && _isEnrolled
                ? FilledButton(
                    onPressed: () {
                      final title = 'Avaliar — ${widget.name}';
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Avaliar evento',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : _isFinished && !_isEnrolled
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Você não participou deste evento :(',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  )
                : !_isEnrolled
                ? FilledButton(
                    onPressed: _enrollInEvent,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Inscrever-se',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 56, // Fixed height to prevent overflow
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.red, AppColors.purple],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FilledButton(
                      onPressed: (userRole == 'admin' || _isEventStarted)
                          ? () {
                              final sessionId =
                                  widget.eventId ??
                                  widget.name.trim().toLowerCase();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => QAPage(
                                    sessionId: sessionId,
                                    sessionTitle: 'Q&A — ${widget.name}',
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor:
                            (userRole == 'admin' || _isEventStarted)
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Participar do Q&A',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14, // Slightly smaller font
                            ),
                          ),
                          if (!_isEventStarted &&
                              _countdownText.isNotEmpty) ...[
                            const SizedBox(height: 2), // Reduced spacing
                            Text(
                              'Abre em $_countdownText',
                              style: TextStyle(
                                fontSize: 10, // Smaller font for countdown
                                fontWeight: FontWeight.normal,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> performCheckIn() async {
    try {
      Map<String, dynamic> checkInDetail = {
        "name": name,
        "image": image,
        "date": widget.date,
        "time": widget.time,
        "lectureName": widget.name,
        "lectureImage": widget.image,
        "eventId": widget.eventId,
        "enrollmentCode": _enrollmentCode,
        "Date": widget.date,
        "Time": widget.time,
        "Speaker": widget.speaker,
        "Location": widget.local,
      };
      await DatabaseMethods().addUserCheckIn(checkInDetail, id!);

      // Also add to event check-ins for better organization
      if (widget.eventId != null) {
        await DatabaseMethods().addEventCheckIn(
          checkInDetail,
          widget.eventId!,
          '',
          'User Self-Check-in',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkin realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
