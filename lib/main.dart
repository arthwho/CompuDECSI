import 'package:compudecsi/admin/upload_event.dart';
import 'package:compudecsi/pages/bottom_nav.dart';
import 'package:compudecsi/pages/detail_page.dart';
import 'package:compudecsi/pages/home.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CompuDECSI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: SignUp(),
    );
  }
}
