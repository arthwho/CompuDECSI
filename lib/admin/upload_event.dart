import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadEvent extends StatefulWidget {
  const UploadEvent({super.key});

  @override
  State<UploadEvent> createState() => _UploadEventState();
}

class _UploadEventState extends State<UploadEvent> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController localController = new TextEditingController();
  final List<String> eventCategory = [
    'Data Science',
    'Criptografia',
    'Robótica',
    'Inteligência Artificial',
    'Software',
    'Computação',
    'Eletrônica',
    'Telecomunicações',
  ];
  String? value;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? selectedSpeaker;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    setState(() {
      users = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    setState(() {});
  }

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 00);
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2026),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    String _categoryToValue(String? category) {
      switch (category) {
        case 'Data Science':
          return 'data_science';
        case 'Criptografia':
          return 'cryptography';
        case 'Robótica':
          return 'robotics';
        case 'Inteligência Artificial':
          return 'ai';
        case 'Software':
          return 'software';
        case 'Computação':
          return 'computing';
        case 'Eletrônica':
          return 'electronics';
        case 'Telecomunicações':
          return 'telecom';
        default:
          return '';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Criar palestra',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            left: AppSpacing.viewPortSide,
            right: AppSpacing.viewPortSide,
            bottom: AppSpacing.viewPortBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // selectedImage != null
              //     ? Center(
              //         child: ClipRRect(
              //           borderRadius: AppBorderRadius.md,
              //           child: Image.file(
              //             selectedImage!,
              //             height: 90,
              //             width: 90,
              //             fit: BoxFit.cover,
              //           ),
              //         ),
              //       )
              //     : Center(
              //         child: GestureDetector(
              //           onTap: () {
              //             getImage();
              //           },
              //           child: Container(
              //             height: 90,
              //             width: 90,
              //             decoration: BoxDecoration(
              //               border: Border.all(color: Colors.black45, width: 2),
              //               borderRadius: BorderRadius.circular(20),
              //             ),
              //             child: Icon(
              //               Icons.add_circle,
              //               color: Colors.black45,
              //               size: 30,
              //             ),
              //           ),
              //         ),
              //       ),
              // SizedBox(height: 20),
              Text(
                'Nome da Palestra',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xffececf8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Qual o nome da palestra?',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Event Category',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xffececf8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items: eventCategory
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        this.value = value;
                      });
                    },
                    dropdownColor: Color(0xffececf8),
                    hint: Text(
                      'Qual o tema da palestra?',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    value: value,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Event Date and Time',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _pickDate();
                    },
                    child: Icon(Icons.calendar_month, color: Colors.black),
                  ),
                  SizedBox(width: 10),
                  Text(DateFormat('dd/MM/yyyy').format(selectedDate!)),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      _pickTime();
                    },
                    child: Icon(Icons.access_time, color: Colors.black),
                  ),
                  SizedBox(width: 10),
                  Text(formatTimeOfDay(selectedTime)),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Event Description',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xffececf8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  maxLines: 6,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Fale mais sobre a palestra',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Palestrante(s)',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xffececf8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    value: selectedSpeaker,
                    items: users.map((user) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: user,
                        child: Row(
                          children: [
                            user["Image"] != null &&
                                    user["Image"].toString().isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      user["Image"],
                                    ),
                                    radius: 16,
                                  )
                                : CircleAvatar(
                                    child: Icon(Icons.person),
                                    radius: 16,
                                  ),
                            SizedBox(width: 10),
                            Text(user["Name"] ?? "Sem nome"),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSpeaker = value;
                      });
                    },
                    hint: Text('Selecione o palestrante'),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Local da Palestra',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xffececf8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: localController,
                  decoration: InputDecoration(
                    hintText: 'Onde será realizada a palestra?',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FilledButton.tonal(
                  onPressed: () async {
                    //String addId = randomAlphaNumeric(10);
                    //Reference firebaseStorageRef = FirebaseStorage.instance
                    //    .ref()
                    //    .child("blogImages")
                    //    .child(addId);

                    //final UploadTask task = firebaseStorageRef.putFile(
                    //  selectedImage!,
                    //);
                    //var downloadUrl = await (await task).ref.getDownloadURL();
                    String id = randomAlphaNumeric(10);
                  String checkinCode = randomAlphaNumeric(
                    6,
                  ); // Generate 6-digit code
                  Map<String, dynamic> uploadEvent = {
                    "image": "", //ou usar o downloadUrl
                    "name": nameController.text,
                    "category": _categoryToValue(value),
                    "description": descriptionController.text,
                    "speaker": selectedSpeaker != null
                        ? selectedSpeaker!["Name"]
                        : "",
                    "speakerImage": selectedSpeaker != null
                        ? selectedSpeaker!["Image"]
                        : "",
                    "local": localController.text,
                    "date": DateFormat('dd/MM/yyyy').format(selectedDate!),
                    "time": formatTimeOfDay(selectedTime),
                    // status inicial; será considerado "finalizado" quando a data exceder
                    "status": "scheduled",
                    "checkinCode": checkinCode, // Add the check-in code
                  };
                    await DatabaseMethods().addEvent(uploadEvent, id).then((
                      value,
                    ) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Palestra criada com sucesso!"),
                        ),
                      );
                      setState(() {
                        nameController.clear();
                        descriptionController.clear();
                        localController.clear();
                        selectedImage = null;
                        value = null;
                      });
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'Upload Event',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
