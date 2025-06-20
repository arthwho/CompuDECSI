import 'package:flutter/material.dart';
import 'package:compudecsi/pages/booking.dart';
import 'package:compudecsi/pages/home.dart';
import 'package:compudecsi/pages/profile.dart';
import 'package:compudecsi/pages/messages.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> pages;
  late Home home;
  late Booking booking;
  late Profile profile;
  late Messages messages;
  int currentIndex = 0;

  @override
  void initState() {
    home = Home();
    booking = Booking();
    profile = Profile();
    messages = Messages();
    pages = [home, booking, messages, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.book, color: Colors.white),
          Icon(Icons.message_rounded, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
      ),
      body: pages[currentIndex],
    );
  }
}
