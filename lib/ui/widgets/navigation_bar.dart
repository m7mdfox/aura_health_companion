import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class NavigationBarr extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const NavigationBarr({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selectedIndex,
      height: 70.0,
      items: const <Widget>[
        Icon(Icons.home, size: 35),
        Icon(Icons.medical_information, size: 35),
        Icon(Icons.search, size: 35),
        Icon(Icons.person, size: 35),
      ],
      color: const Color.fromARGB(255, 0, 177, 121),
      buttonBackgroundColor: const Color.fromARGB(
        255,
        0,
        255,
        119,
        // ignore: deprecated_member_use
      ).withOpacity(0.5),
      backgroundColor: Colors.white,
      animationCurve: Curves.easeOutExpo,
      animationDuration: const Duration(milliseconds: 500),
      onTap: onTap,
      letIndexChange: (index) => true,
    );
  }
}
