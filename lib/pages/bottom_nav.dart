import 'package:flutter/material.dart';
import 'package:compudecsi/pages/booking.dart';
import 'package:compudecsi/pages/home.dart';
import 'package:compudecsi/pages/profile.dart';
import 'package:compudecsi/pages/messages.dart';

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
      bottomNavigationBar: NavigationBar(
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_filled), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'Palestras'),

          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      body: pages[currentIndex],
    );
  }
}
