import 'package:flutter/material.dart';
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/onboarding/fitness_goal_screen.dart';

class FitnessProfileScreen extends StatefulWidget {
  const FitnessProfileScreen({super.key});

  @override
  State<FitnessProfileScreen> createState() => _FitnessProfileScreenState();
}

class _FitnessProfileScreenState extends State<FitnessProfileScreen> {
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profile = AuthService.profile;
    
    // Calculate age from birthdate if available
    int age = 25; // default
    if (profile != null && profile['birthdate'] != null) {
      try {
        final birthdate = DateTime.parse(profile['birthdate']);
        age = DateTime.now().year - birthdate.year;
      } catch (e) {
        print('Error parsing birthdate: $e');
      }
    }

    _ageController = TextEditingController(
      text: age.toString()
    );
    
    _weightController = TextEditingController(
      text: profile?['weight_kg']?.toString() ?? '70'
    );
    
    _heightController = TextEditingController(
      text: profile?['height_cm']?.toString() ?? '170'
    );
    
    _selectedGender = profile?['gender'] ?? 'male';
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('بياناتك الشخصية'),
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
            _buildProgressIndicator(1, 5, isDark),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              'لنتعرف عليك أكثر',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F1120),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'راجع بياناتك وعدّل إذا لزم الأمر',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Profile Data Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Age Field
                  _buildTextField(
                    controller: _ageController,
                    label: 'العمر',
                    icon: Icons.cake,
                    suffix: 'سنة',
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Weight Field
                  _buildTextField(
                    controller: _weightController,
                    label: 'الوزن',
                    icon: Icons.monitor_weight,
                    suffix: 'كجم',
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Height Field
                  _buildTextField(
                    controller: _heightController,
                    label: 'الطول',
                    icon: Icons.height,
                    suffix: 'سم',
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Gender Selection
                  _buildGenderSelector(isDark),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FitnessGoalScreen(
                        age: int.tryParse(_ageController.text) ?? 25,
                        weight: double.tryParse(_weightController.text) ?? 70,
                        height: double.tryParse(_heightController.text) ?? 170,
                        gender: _selectedGender ?? 'male',
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.grey[600],
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF00177E),
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.grey[600],
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F1120) : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00177E),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الجنس',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                'male',
                'ذكر',
                Icons.male,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(
                'female',
                'أنثى',
                Icons.female,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    String value,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedGender == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
            ? const Color(0xFF00177E).withOpacity(0.1)
            : (isDark ? const Color(0xFF0F1120) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
              ? const Color(0xFF00177E)
              : (isDark ? Colors.white12 : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                ? const Color(0xFF00177E)
                : (isDark ? Colors.white60 : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                  ? const Color(0xFF00177E)
                  : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}