import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  Map<String, dynamic>? _enrollmentData;
  String? _errorMessage;
  String? _staffId;
  String? _staffName;

  @override
  void initState() {
    super.initState();
    _loadStaffInfo();
  }

  Future<void> _loadStaffInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            _staffId = user.uid;
            _staffName = userData['Name'] ?? 'Staff Member';
          });
        }
      }
    } catch (e) {
      print('Error loading staff info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Escanear QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Mobile Scanner View
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (_isScanning && !_isProcessing && barcode.rawValue != null) {
                  _processScannedCode(barcode.rawValue!);
                  break; // Process only the first barcode
                }
              }
            },
          ),

          // Scanner overlay
          CustomPaint(
            painter: ScannerOverlay(),
            child: const SizedBox.expand(),
          ),

          // Instructions
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Posicione o QR Code dentro da área destacada para escanear',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Processando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await controller.toggleTorch();
        },
        backgroundColor: AppColors.purpleDark,
        child: const Icon(Icons.flash_on, color: Colors.white),
      ),
    );
  }

  Future<void> _processScannedCode(String code) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _enrollmentData = null;
    });

    try {
      // Find the enrollment by code
      final enrollment = await _findEnrollmentByCode(code);

      if (enrollment != null) {
        // Get user and event details
        final userData = await _getUserData(enrollment['userId']);
        final eventData = await _getEventData(enrollment['eventId']);

        if (userData != null && eventData != null) {
          setState(() {
            _enrollmentData = {
              'enrollment': enrollment,
              'user': userData,
              'event': eventData,
            };
          });

          // Show confirmation dialog
          _showCheckInConfirmation();
        } else {
          setState(() {
            _errorMessage = 'Dados do usuário ou evento não encontrados';
          });
          _showErrorDialog();
        }
      } else {
        setState(() {
          _errorMessage = 'Código de inscrição não encontrado';
        });
        _showErrorDialog();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao processar código: $e';
      });
      _showErrorDialog();
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _findEnrollmentByCode(String code) async {
    try {
      // Use collection group query to search across all enrollments subcollections
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('enrollments')
          .where('enrollmentCode', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        // Extract eventId from the document path
        final pathParts = doc.reference.path.split('/');
        final eventId =
            pathParts[pathParts.length -
                3]; // events/{eventId}/enrollments/{userId}
        return {'id': doc.id, 'eventId': eventId, ...data};
      }
      return null;
    } catch (e) {
      print('Error finding enrollment: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getEventData(String eventId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting event data: $e');
      return null;
    }
  }

  void _showCheckInConfirmation() {
    if (_enrollmentData == null) return;

    final user = _enrollmentData!['user'];
    final event = _enrollmentData!['event'];
    final enrollment = _enrollmentData!['enrollment'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Check-in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Usuário: ${user['Name'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Evento: ${event['name'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Data: ${event['date'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Horário: ${event['time'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Local: ${event['local'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetScanner();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _performCheckIn(enrollment),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleDark,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar Check-in'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(_errorMessage ?? 'Erro desconhecido'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetScanner();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleDark,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCheckIn(Map<String, dynamic> enrollment) async {
    try {
      final userId = enrollment['userId'];
      final eventId = enrollment['eventId'];
      final event = _enrollmentData!['event'];
      final user = _enrollmentData!['user'];

      // Create check-in details
      Map<String, dynamic> checkInDetail = {
        "name": user['Name'] ?? 'N/A',
        "image": user['Image'] ?? '',
        "date": event['date'] ?? '',
        "time": event['time'] ?? '',
        "lectureName": event['name'] ?? '',
        "lectureImage": event['image'] ?? '',
        "eventId": eventId,
        "enrollmentCode": enrollment['enrollmentCode'],
        "Date": event['date'] ?? '',
        "Time": event['time'] ?? '',
        "Speaker": event['speaker'] ?? '',
        "Location": event['local'] ?? '',
        "checkedInAt": FieldValue.serverTimestamp(),
      };

      // Use enhanced check-in methods with staff tracking
      if (_staffId != null && _staffName != null) {
        // Add to user check-ins with staff info
        await DatabaseMethods().addUserCheckInWithStaff(
          checkInDetail,
          userId,
          _staffId!,
          _staffName!,
        );

        // Add to event check-ins (for event-specific tracking)
        await DatabaseMethods().addEventCheckIn(
          checkInDetail,
          eventId,
          _staffId!,
          _staffName!,
        );

        // Add to staff check-in logs (for staff accountability)
        await DatabaseMethods().addStaffCheckInLog(
          checkInDetail,
          _staffId!,
          _staffName!,
        );
      } else {
        // Fallback to original methods if staff info is not available
        await DatabaseMethods().addUserCheckIn(checkInDetail, userId);

        // Also add to event check-ins for better organization
        await DatabaseMethods().addEventCheckIn(
          checkInDetail,
          eventId,
          '',
          'Admin Check-in',
        );
      }

      // Close dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-in realizado com sucesso para ${user['Name']}'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset scanner
      _resetScanner();
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao realizar check-in: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _resetScanner();
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _isProcessing = false;
      _enrollmentData = null;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.width * 0.8,
    );

    // Draw the background
    canvas.drawRect(Offset.zero & size, paint);

    // Clear the scan area
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(
          RRect.fromRectAndRadius(scanArea, const Radius.circular(12)),
        ),
      ),
      Paint()..color = Colors.transparent,
    );

    // Draw the border
    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanArea, const Radius.circular(0)),
      borderPaint,
    );

    // Draw corner indicators
    final cornerLength = 30.0;
    final cornerThickness = 3.0;
    final cornerPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerThickness;

    // Top-left corner
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top + cornerLength),
      Offset(scanArea.left, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + cornerLength, scanArea.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanArea.right - cornerLength, scanArea.top),
      Offset(scanArea.right, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom - cornerLength),
      Offset(scanArea.left, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + cornerLength, scanArea.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanArea.right - cornerLength, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom - cornerLength),
      Offset(scanArea.right, scanArea.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
