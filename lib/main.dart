import 'package:compudecsi/view/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme)
            .copyWith(
              bodyMedium: GoogleFonts.poppins(
                textStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
