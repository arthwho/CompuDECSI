import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/services/shared_pref.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class DetailsPage extends StatefulWidget {
  String image, name, local, date, time, description, speaker;
  String? eventId;
  DetailsPage({
    required this.image,
    required this.name,
    required this.local,
    required this.date,
    required this.time,
    required this.description,
    required this.speaker,
    this.eventId,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String? id, name, image;
  String? checkinCode;

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
      await fetchCheckinCode();
    }

    setState(() {});
  }

  Future<void> fetchCheckinCode() async {
    try {
      DocumentSnapshot? eventDoc = await DatabaseMethods().getEventById(
        widget.eventId!,
      );
      if (eventDoc != null && eventDoc.exists) {
        setState(() {
          checkinCode = eventDoc.get('checkinCode') as String?;
        });
      }
    } catch (e) {
      print("Error fetching check-in code: $e");
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
        backgroundColor: Colors.transparent,
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
                      // ds["speakerImage"] != null &&
                      //     ds["speakerImage"].toString().isNotEmpty
                      // ? CircleAvatar(
                      //     backgroundImage: NetworkImage(
                      //       ds["speakerImage"],
                      //     ),
                      //     radius: 20,
                      //   )
                      Icon(Icons.account_circle, size: 40),
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
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: PrimaryButton(
                      text: 'Fazer checkin',
                      onPressed: () {
                        _showCodeInputDialog();
                      },
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
