import 'package:flutter/material.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/fitness_profile_screen.dart';

class FitnessWelcomeScreen extends StatelessWidget {
  const FitnessWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Fitness Icon
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                      ? [const Color(0xFF2D1B69), const Color(0xFF6B46C1)]
                      : [const Color(0xFF00177E), const Color(0xFF0F1120)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? const Color(0xFF6B46C1) : const Color(0xFF00177E))
                          .withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Welcome Title
              Text(
                'مرحباً بك في مدرب اللياقة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F1120),
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Welcome Description
              Text(
                'سنساعدك في بناء خطة تمارين مخصصة\nبناءً على أهدافك ومستوى لياقتك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Features List
              _buildFeatureItem(
                icon: Icons.trending_up,
                title: 'خطط مخصصة',
                description: 'تمارين مصممة خصيصاً لأهدافك',
                isDark: isDark,
              ),
              
              const SizedBox(height: 20),
              
              _buildFeatureItem(
                icon: Icons.psychology,
                title: 'تمارين متنوعة',
                description: 'مكتبة شاملة من التمارين المختلفة',
                isDark: isDark,
              ),
              
              const SizedBox(height: 20),
              
              _buildFeatureItem(
                icon: Icons.track_changes,
                title: 'متابعة مستمرة',
                description: 'تتبع تقدمك وتحقيق أهدافك',
                isDark: isDark,
              ),
              
              const Spacer(),
              
              // Start Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FitnessProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00177E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ابدأ الآن',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_back, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00177E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00177E),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F1120),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}