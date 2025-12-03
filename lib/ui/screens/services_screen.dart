import 'package:aura_health_companion/ui/screens/doctor/doctor_request_screen.dart'; // 👈 تأكد من استيراد الملف هنا
import 'package:aura_health_companion/ui/screens/services/medicine_screen.dart';
import 'package:aura_health_companion/ui/screens/mental_health/mental_health_home_screen.dart';
import 'package:aura_health_companion/ui/screens/nutrition/nutrition_onboarding.dart';
import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const List<Map<String, dynamic>> services = [
    {"title": "Watch Data", "icon": Icons.watch, "route": "/watch", "color": Color.fromARGB(255, 0, 21, 139)},
    {"title": "Request Doctor", "icon": Icons.person_search, "route": "/request_doctor", "color": Color(0xFF2563EB)}, 
    {"title": "Medicine", "icon": Icons.medication, "route": "/medicine", "color": Colors.red},
    {"title": "Mental Health", "icon": Icons.psychology, "route": "/mental_health", "color": Colors.purple},
    {"title": "Nutrition & Diet", "icon": Icons.restaurant, "route": "/nutrition", "color": Colors.orange},
    {"title": "Prevention", "icon": Icons.health_and_safety, "route": "/prevention", "color": Colors.green},
    {"title": "AI Fitness Coach", "icon": Icons.fitness_center, "route": "/fitness", "color": Colors.cyan},
    {"title": "Emergency", "icon": Icons.emergency, "route": "/emergency", "color": Colors.redAccent},
    {"title": "Genetic Health", "icon": Icons.biotech, "route": "/genetic_health", "color": Colors.indigo},
    {"title": "Community", "icon": Icons.groups, "route": "/community", "color": Colors.pink},
    {"title": "Challenges", "icon": Icons.flag, "route": "/challenges", "color": Colors.amber},
    {"title": "Reminders", "icon": Icons.alarm, "route": "/reminders", "color": Colors.teal},
    {"title": "Order Medicine", "icon": Icons.local_pharmacy, "route": "/order_medicine", "color": Colors.deepOrange},
  ];

  void _navigateToService(BuildContext context, String route) {
    if (route == '/medicine') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MedicineScreenn()),
      );
    } 
    else if (route == '/mental_health') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MentalHealthHomeScreen()),
      );
    } 
    else if (route == '/nutrition') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NutritionOnboardingFlow()),
      );
    } 
    // 👇👇👇 هنا الإصلاح 👇👇👇
    else if (route == '/request_doctor') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DoctorRequestScreen()),
      );
    }
    // 👆👆👆
    else {
      // الروابط الأخرى التي قد تكون مسجلة في main.dart
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Services',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: [Color(0xFF00177E), Color(0xFF0F1120)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: services.map((service) {
            return GestureDetector(
              onTap: () => _navigateToService(context, service['route']),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      service['icon'],
                      size: 40,
                      color: service['color'],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}