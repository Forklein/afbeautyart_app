
import 'package:flutter/material.dart';

class BottomDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTap,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.spa_outlined),
        selectedIcon: Icon(Icons.spa),
        label: 'Servizi',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Prenotazioni',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profilo',
      ),
    ],
  );
}
