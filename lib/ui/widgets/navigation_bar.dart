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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CurvedNavigationBar(
      index: selectedIndex,
      height: 70.0,
      items: const <Widget>[
        Icon(Icons.home, size: 35, color: Colors.white),
        Icon(Icons.home_repair_service_sharp, size: 35, color: Colors.white),
        Icon(Icons.wechat_sharp, size: 35, color: Colors.white),
        Icon(Icons.person, size: 35, color: Colors.white),
      ],
      
      // تغيير الألوان حسب الوضع
      color: isDark 
        ? const Color(0xFF1A1D2E) // لون داكن للـ Dark Mode
        : const Color.fromARGB(255, 0, 18, 97), // اللون الأزرق للـ Light Mode
        
      buttonBackgroundColor: isDark
        ? const Color(0xFF2D1B69) // لون أغمق للزر في Dark Mode
        : const Color.fromARGB(255, 0, 8, 71), // اللون الأزرق الغامق للـ Light Mode
      
      backgroundColor: isDark 
        ? const Color(0xFF0F1120) // خلفية داكنة
        : Colors.white, // خلفية بيضاء
        
      animationCurve: Curves.easeOutExpo,
      animationDuration: const Duration(milliseconds: 500),
      onTap: onTap,
      letIndexChange: (index) => true,
    );
  }
}