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
        Icon(Icons.home, size: 35, color: Colors.white),
        Icon(Icons.home_repair_service_sharp, size: 35, color: Colors.white),
        Icon(Icons.wechat_sharp, size: 35, color: Colors.white),
        Icon(Icons.person, size: 35, color: Colors.white),
      ],

      color: const Color.fromARGB(255, 0, 18, 97), // Main bar color
      buttonBackgroundColor:
          const Color.fromARGB(255, 0, 8, 71), // Button background color

    

      backgroundColor: Colors.white,
      animationCurve: Curves.easeOutExpo,
      animationDuration: const Duration(milliseconds: 500),
      onTap: onTap,
      letIndexChange: (index) => true,
    );
  }
}
