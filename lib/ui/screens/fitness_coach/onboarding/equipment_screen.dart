import 'package:flutter/material.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/models/fitness_profile_model.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/screens/workout_plan_screen.dart';

class EquipmentScreen extends StatefulWidget {
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String goal;
  final List<String> focusAreas;
  final String fitnessLevel;

  const EquipmentScreen({
    super.key,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.goal,
    required this.focusAreas,
    required this.fitnessLevel,
  });

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  String? _selectedEquipment;

  final List<Map<String, dynamic>> _equipmentOptions = [
    {
      'id': 'full_gym',
      'title': 'جميع المعدات',
      'subtitle': 'لدي عضوية جيم أو معدات كاملة في المنزل',
      'description': 'الوصول لجميع الأجهزة والمعدات والأوزان الحرة',
      'icon': Icons.fitness_center,
      'color': const Color(0xFFEF4444),
      'examples': ['باربل', 'دامبل', 'أجهزة', 'كابل', 'سميث'],
    },
    {
      'id': 'basic_equipment',
      'title': 'معدات أساسية',
      'subtitle': 'دامبل، مقاومة، أو بعض المعدات البسيطة',
      'description': 'معدات منزلية بسيطة تكفي لتمارين فعالة',
      'icon': Icons.sports_gymnastics,
      'color': const Color(0xFFF59E0B),
      'examples': ['دامبل', 'أحبال مقاومة', 'كرة تمرين', 'بار'],
    },
    {
      'id': 'no_equipment',
      'title': 'بدون معدات',
      'subtitle': 'تمارين باستخدام وزن الجسم فقط',
      'description': 'تمارين فعالة يمكن ممارستها في أي مكان',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF10B981),
      'examples': ['ضغط', 'عقلة', 'سكوات', 'بلانك', 'لونجز'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('المعدات المتاحة'),
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
            _buildProgressIndicator(5, 5, isDark),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              'ما هي المعدات المتاحة لديك؟',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F1120),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'سنصمم تمارين مناسبة للمعدات المتاحة لديك',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Equipment Options
            ...List.generate(_equipmentOptions.length, (index) {
              final equipment = _equipmentOptions[index];
              final isSelected = _selectedEquipment == equipment['id'];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEquipment = equipment['id'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                          ? equipment['color']
                          : (isDark ? Colors.white12 : Colors.grey[300]!),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                            ? equipment['color'].withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                          blurRadius: isSelected ? 15 : 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: equipment['color'].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                equipment['icon'],
                                size: 28,
                                color: equipment['color'],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Title & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    equipment['title'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F1120),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    equipment['subtitle'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : Colors.grey[600],
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
                                color: equipment['color'],
                                size: 28,
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description
                        Text(
                          equipment['description'],
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Examples
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (equipment['examples'] as List<String>).map((example) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: equipment['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: equipment['color'].withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                example,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : equipment['color'],
                                ),
                              ),
                            );
                          }).toList(),
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
                    Icons.tips_and_updates,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'يمكنك تغيير هذا الاختيار لاحقاً إذا توفرت لديك معدات جديدة',
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
            
            // Finish Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedEquipment != null
                  ? () {
                      _navigateToWorkoutPlan(context, isDark);
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
                  elevation: _selectedEquipment != null ? 5 : 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'إنهاء الإعداد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle_outline, size: 24),
                  ],
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

  void _navigateToWorkoutPlan(BuildContext context, bool isDark) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'رائع! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F1120),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري إعداد برنامج تمارين مخصص لك بناءً على اختياراتك...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00177E)),
            ),
          ],
        ),
      ),
    );

    // Create fitness profile
    final profile = FitnessProfileModel(
      age: widget.age,
      weight: widget.weight,
      height: widget.height,
      gender: widget.gender,
      goal: widget.goal,
      focusAreas: widget.focusAreas,
      fitnessLevel: widget.fitnessLevel,
      equipment: _selectedEquipment!,
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    // Simulate processing and navigate
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog
      
      // Navigate to workout plan screen with profile
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WorkoutPlanScreen(profile: profile),
        ),
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ تم إعداد برنامجك التدريبي بنجاح!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}