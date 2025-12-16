import 'package:aura_health_companion/ui/screens/doctor/doctor_request_screen.dart'; // 👈 تأكد من استيراد الملف هنا
import 'package:aura_health_companion/ui/screens/services/medicine_screen.dart';
import 'package:aura_health_companion/ui/screens/mental_health/mental_health_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:aura_health_companion/ui/screens/health_journey_game/game_screen.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/fitness_coach_main.dart';
import 'package:aura_health_companion/ui/screens/nutrition/nutrition_main_entry.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const List<Map<String, dynamic>> services = [
    {"title": "Watch Data", "icon": Icons.watch, "route": "/watch", "color": Color.fromARGB(255, 0, 21, 139)},
    {"title": "Request Doctor", "icon": Icons.person_search, "route": "/request_doctor", "color": Color(0xFF2563EB)}, 
    {"title": "Medicine", "icon": Icons.medication, "route": "/medicine", "color": Colors.red},
    {"title": "Mental Health", "icon": Icons.psychology, "route": "/mental_health", "color": Colors.purple},
    {"title": "Nutrition & Diet", "icon": Icons.restaurant, "route": "/nutrition", "color": Colors.orange},
    {"title": "Prevention", "icon": Icons.health_and_safety, "route": "/prevention", "color": Colors.green},
    {"title": "Fitness Coach", "icon": Icons.fitness_center, "route": "/fitness", "color": Colors.cyan},
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
        MaterialPageRoute(builder: (context) => MedicineScreenn())
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
        MaterialPageRoute(builder: (context) => const NutritionMainEntry()),
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
    
    else if (route == '/fitness') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FitnessCoachMain()),
      );
    }
    else {
      // الروابط الأخرى التي قد تكون مسجلة في main.dart
      Navigator.pushNamed(context, route);
    }
  }

  void _navigateToGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthJourneyGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Services',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: isDark 
                ? [const Color(0xFF1A1D2E), const Color(0xFF0F1120)]
                : [const Color(0xFF00177E), const Color(0xFF0F1120)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // بطاقة اللعبة المميزة
              _buildGameCard(context, isDark),
              
              const SizedBox(height: 24),
              
              // عنوان قسم الخدمات
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الخدمات الصحية',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F1120),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // شبكة الخدمات
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: services.map((service) {
                  return GestureDetector(
                    onTap: () => _navigateToService(context, service['route']),
                    child: _buildServiceCard(service, isDark),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToGame(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
              ? [const Color(0xFF2D1B69), const Color(0xFF6B46C1)]
              : [const Color(0xFF6B46C1), const Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? const Color(0xFF9333EA) : const Color(0xFF6B46C1))
                  .withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // تأثيرات الخلفية
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            
            // المحتوى
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'جديد',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'رحلة الصحة 🎮',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اهزم أعداء الصحة وابدأ رحلتك نحو وزن مثالي!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'العب الآن',
                        style: TextStyle(
                          color: Color(0xFF6B46C1),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF6B46C1),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: service['color'].withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              service['icon'],
              size: 36,
              color: service['color'],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              service['title'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF0F1120),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}