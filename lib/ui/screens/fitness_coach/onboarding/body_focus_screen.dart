import 'package:flutter/material.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/onboarding/fitness_level_screen.dart';

class BodyFocusScreen extends StatefulWidget {
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String goal;

  const BodyFocusScreen({
    super.key,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.goal,
  });

  @override
  State<BodyFocusScreen> createState() => _BodyFocusScreenState();
}

class _BodyFocusScreenState extends State<BodyFocusScreen> {
  final Set<String> _selectedAreas = {};

  // ============================================================
  // 🎯 تعريف مناطق الجسم والخطوط
  // ============================================================
  // 'position': الموضع بالنسبة لوسط الصورة
  // 'side': 'left' أو 'right'
  // 'line_length': طول الخط الأفقي (لـ 'side') أو الرأسي (لـ 'vertical')
  // 'line_style': 'side' (افتراضي/أفقي) أو 'vertical' (رأسي)
  // 'layer': 'back' (خلف الصورة) أو 'front' (أمام الصورة)
  // ============================================================

  final Map<String, Map<String, dynamic>> _bodyAreas = {
    'shoulders': {
      'name': 'أكتاف',
      'position': const Offset(0.9, 0.28),
      'side': 'left',
      'line_length': 60.0, // هذا هو طول الخط الرأسي
      'line_style': 'right', // 🟢 خط رأسي متصل من الأسفل
      'layer': 'front',
    },
    'chest': {
      'name': 'صدر',
      'position': const Offset(0.5, 0.36),
      'side': 'left',
      'line_length': 80.0,
      'line_style': 'side', 
      'layer': 'front',
    },
    'back': {
      'name': 'ظهر',
      'position': const Offset(0.5, 0.32),
      'side': 'right',
      'line_length': 60.0,
      'line_style': 'side',
      'layer': 'back', // 🟢 هذا الخط هو الوحيد الذي سيظهر خلف الصورة
    },
    'arms': {
      'name': 'ذراعين',
      'position': const Offset(0.5, 0.45),
      'side': 'left',
      'line_length': 23.0,
      'line_style': 'side',
      'layer': 'front',
    },
    'abs': {
      'name': 'بطن',
      'position': const Offset(0.5, 0.42),
      'side': 'right',
      'line_length': 80.0,
      'line_style': 'side',
      'layer': 'front',
    },
    'legs': {
      'name': 'أرجل',
      'position': const Offset(0.5, 0.60),
      'side': 'right',
      'line_length': 50.0,
      'line_style': 'side',
      'layer': 'front',
    },
    // 'glutes' (مؤخرة) تم حذفها
  };

  void _toggleArea(String area) {
    setState(() {
      if (_selectedAreas.contains(area)) {
        _selectedAreas.remove(area);
      } else {
        _selectedAreas.add(area);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedAreas.length == _bodyAreas.length) {
        _selectedAreas.clear();
      } else {
        _selectedAreas.addAll(_bodyAreas.keys);
      }
    });
  }

  // ============================================================
  // 🏷️ Widget الـ Label نفسه
  // ============================================================
  Widget _buildLabel(
    String text,
    bool isSelected,
    Color primaryColor,
    Color cardColor,
    bool isDark,
    VoidCallback onTap, {
    bool isVerticalStyle = false, // 🆕 لتعديل شكل الحواف للخط الرأسي
  }) {
    // 🟢 لنمط 'vertical'، نزيل الحافة السفلية لتبدو متصلة بالخط الرأسي.
    final double borderBottomWidth = isVerticalStyle ? 0 : 2; 

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border(
            top: BorderSide(
              color: isSelected ? primaryColor : (isDark ? Colors.white24 : Colors.grey[300]!),
              width: 2,
            ),
            left: BorderSide(
              color: isSelected ? primaryColor : (isDark ? Colors.white24 : Colors.grey[300]!),
              width: 2,
            ),
            right: BorderSide(
              color: isSelected ? primaryColor : (isDark ? Colors.white24 : Colors.grey[300]!),
              width: 2,
            ),
            bottom: BorderSide(
              color: isSelected ? primaryColor : (isDark ? Colors.white24 : Colors.grey[300]!),
              width: borderBottomWidth, // 0 إذا كان 'vertical'
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryColor.withOpacity(0.4)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 12,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ➖ Widget الخط الرأسي (Vertical Line)
  // ============================================================
  Widget _buildVerticalLine(
      double lineLength, bool isSelected, Color primaryColor, bool isDark) {
    return Container(
      width: 2, // عرض الخط
      height: lineLength, // طول الخط
      margin: const EdgeInsets.symmetric(horizontal: 10), // لتوسيطه أسفل الـ Label
      color: isSelected ? primaryColor : (isDark ? Colors.white24 : Colors.grey[400]!),
    );
  }

  // ============================================================
  // ➖ Widget الخط الأفقي (Side Line)
  // ============================================================
  Widget _buildSideLine(
      double lineLength, bool isSelected, Color primaryColor, bool isDark) {
    return Container(
      width: lineLength,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [primaryColor, primaryColor.withOpacity(0.3)]
              : [
                  isDark ? Colors.white24 : Colors.grey[300]!,
                  (isDark ? Colors.white24 : Colors.grey[300]!)
                      .withOpacity(0.2),
                ],
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 دالة بناء الـ Labels والخطوط
  // ============================================================
  List<Widget> _buildAreaLabels({required String requiredLayer}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF00177E);
    final cardColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;

    return _bodyAreas.entries
        .where((entry) => entry.value['layer'] == requiredLayer)
        .map((entry) {
      final area = entry.key;
      final data = entry.value;
      final isSelected = _selectedAreas.contains(area);
      final position = data['position'] as Offset;
      final side = data['side'] as String;
      final lineLength = data['line_length'] as double;
      final lineStyle = data['line_style'] ?? 'side';

      // ============================================================
      // 📐 حساب الموضع الفعلي على الشاشة
      // ============================================================
      double labelY = 500 * position.dy;
      double labelX = 0; // لنمط vertical

      if (lineStyle == 'vertical') {
        labelY -= 30; // رفع الـ label لإعطاء مساحة للخط الرأسي
        // لـ 'vertical' نعتمد على الموضع الأفقي لـ Positioned
        if (side == 'left') {
           labelX = 0;
        } else {
           labelX = 500;
        }

      } else { // side line
        labelY -= 20; // الموضع العادي للـ side label
      }

      // ============================================================
      // 🎨 رسم الـ Label مع الخط
      // ============================================================
      return Positioned(
        left: side == 'left' ? labelX : null,
        right: side == 'right' ? labelX : null,
        top: labelY,
        child: lineStyle == 'vertical'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الـ Label
                  _buildLabel(
                    data['name'],
                    isSelected,
                    primaryColor,
                    cardColor,
                    isDark,
                    () => _toggleArea(area),
                    isVerticalStyle: true, // 🟢 تم تمرير هذا المؤشر للخط الرأسي
                  ),
                  // ⬇️ الخط الرأسي
                  _buildVerticalLine(
                      lineLength, isSelected, primaryColor, isDark),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // إذا الـ label على الشمال
                  if (side == 'left') ...[
                    _buildLabel(
                      data['name'],
                      isSelected,
                      primaryColor,
                      cardColor,
                      isDark,
                      () => _toggleArea(area),
                    ),
                    _buildSideLine(lineLength, isSelected, primaryColor, isDark),
                  ],

                  // إذا الـ label على اليمين
                  if (side == 'right') ...[
                    _buildSideLine(lineLength, isSelected, primaryColor, isDark),
                    _buildLabel(
                      data['name'],
                      isSelected,
                      primaryColor,
                      cardColor,
                      isDark,
                      () => _toggleArea(area),
                    ),
                  ],
                ],
              ),
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF00177E);
    final backgroundColor =
        isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('مناطق التركيز'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1D2E), const Color(0xFF0F1120)]
                  : [const Color(0xFF00177E), const Color(0xFF0022A0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(3, 5, isDark),
              const SizedBox(height: 32),
              Text(
                'حدد المناطق التي تريد التركيز عليها',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F1120),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يمكنك اختيار أكثر من منطقة لتحقيق أفضل النتائج',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ============================================================
                    // 📏 حجم الـ Container اللي فيه الصورة والـ Labels
                    // ============================================================
                    SizedBox(
                      height: 500, // 🔧 مساحة الـ Stack
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // ============================================================
                          // 1. 🏷️ الخطوط الخلفية (layer: 'back') - فقط "ظهر"
                          // ============================================================
                          ..._buildAreaLabels(requiredLayer: 'back'),

                          // ============================================================
                          // 2. 🖼️ الصورة في المنتصف
                          // ============================================================
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/fitness.WEBP',
                              height: 500,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 500,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.fitness_center,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // ============================================================
                          // 3. 🏷️ الخطوط الأمامية (layer: 'front') - باقي المناطق
                          // ============================================================
                          ..._buildAreaLabels(requiredLayer: 'front'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _selectAll,
                        icon: Icon(
                          _selectedAreas.length == _bodyAreas.length
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked,
                          size: 22,
                        ),
                        label: Text(
                          _selectedAreas.length == _bodyAreas.length
                              ? 'إلغاء تحديد الكل'
                              : 'تحديد الجسم بالكامل',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_selectedAreas.isNotEmpty) ...[
                Text(
                  'المناطق المختارة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F1120),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selectedAreas.map((area) {
                    return Chip(
                      label: Text(
                        _bodyAreas[area]!['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      deleteIcon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      onDeleted: () => _toggleArea(area),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
              ],
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _selectedAreas.isNotEmpty
                      ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FitnessLevelScreen(
                                  age: widget.age,
                                  weight: widget.weight,
                                  height: widget.height,
                                  gender: widget.gender,
                                  goal: widget.goal,
                                  focusAreas: _selectedAreas.toList(),
                                ),
                              ),
                            );
                          }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor:
                        isDark ? Colors.white12 : Colors.grey[300],
                    disabledForegroundColor:
                        isDark ? Colors.white38 : Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.4),
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
              const SizedBox(height: 20),
            ],
          ),
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 10,
            backgroundColor: isDark ? Colors.white12 : Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF00177E),
            ),
          ),
        ),
      ],
    );
  }
}