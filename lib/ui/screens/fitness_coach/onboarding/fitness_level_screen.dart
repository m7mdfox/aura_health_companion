import 'package:flutter/material.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/onboarding/equipment_screen.dart';

class FitnessLevelScreen extends StatefulWidget {
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String goal;
  final List<String> focusAreas;

  const FitnessLevelScreen({
    super.key,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.goal,
    required this.focusAreas,
  });

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  String? _selectedLevel;

  final List<Map<String, dynamic>> _levels = [
    {
      'id': 'beginner',
      'title': 'مبتدئ',
      'subtitle': 'جديد في التمارين أو لم أتمرن منذ فترة طويلة',
      'description': 'تمارين بسيطة ومناسبة للمبتدئين مع شرح تفصيلي',
      'icon': Icons.star_border,
      'color': const Color(0xFF10B981),
      'intensity': 1,
    },
    {
      'id': 'intermediate',
      'title': 'متوسط',
      'subtitle': 'أتمرن بانتظام ولدي خبرة جيدة',
      'description': 'تمارين متوسطة الصعوبة مع تنوع في الحركات',
      'icon': Icons.star_half,
      'color': const Color(0xFFF59E0B),
      'intensity': 2,
    },
    {
      'id': 'advanced',
      'title': 'متقدم',
      'subtitle': 'خبرة واسعة وأبحث عن تحديات جديدة',
      'description': 'تمارين متقدمة وتحديات قوية لتطوير الأداء',
      'icon': Icons.star,
      'color': const Color(0xFFEF4444),
      'intensity': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('مستوى اللياقة'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [const Color(0xFF1A1D2E), const Color(0xFF0F1120)]
                : [const Color(0xFF00177E), const Color(0xFF0F1120)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            _buildProgressIndicator(4, 5, isDark),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              'ما هو مستوى لياقتك الحالي؟',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F1120),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'اختر المستوى الذي يصف حالتك البدنية بشكل أفضل',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Fitness Levels
            ...List.generate(_levels.length, (index) {
              final level = _levels[index];
              final isSelected = _selectedLevel == level['id'];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLevel = level['id'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                          ? level['color']
                          : (isDark ? Colors.white12 : Colors.grey[300]!),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                            ? level['color'].withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                          blurRadius: isSelected ? 15 : 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon Circle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: level['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            level['icon'],
                            size: 32,
                            color: level['color'],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    level['title'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F1120),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Intensity Dots
                                  Row(
                                    children: List.generate(3, (i) {
                                      return Container(
                                        margin: const EdgeInsets.only(left: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: i < level['intensity']
                                            ? level['color']
                                            : (isDark ? Colors.white24 : Colors.grey[300]),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                level['subtitle'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                level['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.grey[500],
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Selected Indicator
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: level['color'],
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 24),
            
            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اختر بصدق حتى نصمم لك برنامج تمارين آمن ومناسب لقدراتك',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : const Color(0xFF1E3A8A),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedLevel != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EquipmentScreen(
                            age: widget.age,
                            weight: widget.weight,
                            height: widget.height,
                            gender: widget.gender,
                            goal: widget.goal,
                            focusAreas: widget.focusAreas,
                            fitnessLevel: _selectedLevel!,
                          ),
                        ),
                      );
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00177E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark 
                    ? Colors.white12 
                    : Colors.grey[300],
                  disabledForegroundColor: isDark 
                    ? Colors.white38 
                    : Colors.grey[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _selectedLevel != null ? 5 : 0,
                ),
                child: const Text(
                  'التالي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int current, int total, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'خطوة $current من $total',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 8,
            backgroundColor: isDark 
              ? Colors.white12 
              : Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF00177E),
            ),
          ),
        ),
      ],
    );
  }
}