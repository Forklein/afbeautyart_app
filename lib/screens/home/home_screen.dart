import 'package:flutter/material.dart';
import '../../widgets/bottom_dock.dart';
import '../appointments/appointments_screen.dart';
import '../profile/profile_screen.dart';
import '../services/services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  static const pages = [
    ServicesScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: BottomDock(
      currentIndex: index,
      onTap: (value) => setState(() => index = value),
    ),
  );
}
