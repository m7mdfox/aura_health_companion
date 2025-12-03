// lib/ui/screens/nutrition/slides/goal_selection_slide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalSelectionSlide extends StatefulWidget {
  final String selectedGoalType;
  final String selectedDietType;
  final String selectedIfSchedule;
  final ValueChanged<String> onGoalTypeSelect;
  final ValueChanged<String> onDietTypeSelect;
  final ValueChanged<String> onIfScheduleSelect;
  final VoidCallback onNext;

  const GoalSelectionSlide({
    super.key,
    required this.selectedGoalType,
    required this.selectedDietType,
    required this.selectedIfSchedule,
    required this.onGoalTypeSelect,
    required this.onDietTypeSelect,
    required this.onIfScheduleSelect,
    required this.onNext,
  });

  @override
  State<GoalSelectionSlide> createState() => _GoalSelectionSlideState();
}

class _GoalSelectionSlideState extends State<GoalSelectionSlide> {
  int _step = 1; // 1: Goal Type, 2: Diet Type

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            _step == 1 ? 'ما هو هدفك؟' : 'اختر نظامك الغذائي',
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _step == 1
                ? 'سنساعدك على تحقيق هدفك بخطة مخصصة'
                : 'اختر النظام الذي يناسبك',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: _step == 1 ? _buildGoalTypeOptions() : _buildDietTypeOptions(),
          ),
          Row(
            children: [
              if (_step == 2)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step = 1),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D1B4C),
                      side: const BorderSide(color: Color(0xFF0D1B4C)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('رجوع',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  ),
                ),
              if (_step == 2) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_step == 1 && widget.selectedGoalType.isNotEmpty) {
                      setState(() => _step = 2);
                    } else if (_step == 2 && widget.selectedDietType.isNotEmpty) {
                      widget.onNext();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B4C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _step == 1 ? 'التالي' : 'استمرار',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGoalTypeOptions() {
    final goals = [
      {
        'value': 'lose_weight',
        'title': 'خسارة وزن',
        'subtitle': 'تقليل الدهون والوصول للوزن المثالي',
        'icon': Icons.trending_down,
        'color': Colors.red.shade400,
      },
      {
        'value': 'gain_weight',
        'title': 'زيادة وزن',
        'subtitle': 'بناء كتلة عضلية صحية',
        'icon': Icons.trending_up,
        'color': Colors.green.shade400,
      },
      {
        'value': 'maintain',
        'title': 'تثبيت وزن',
        'subtitle': 'الحفاظ على الوزن الحالي',
        'icon': Icons.linear_scale,
        'color': Colors.blue.shade400,
      },
      {
        'value': 'build_muscle',
        'title': 'بناء عضل',
        'subtitle': 'زيادة القوة والكتلة العضلية',
        'icon': Icons.fitness_center,
        'color': Colors.orange.shade400,
      },
    ];

    return ListView(
      children: goals.map((goal) {
        final bool isSelected = widget.selectedGoalType == goal['value'];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: isSelected ? const Color(0xFF0D1B4C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            elevation: isSelected ? 6 : 2,
            shadowColor: Colors.black.withOpacity(0.1),
            child: InkWell(
              onTap: () => widget.onGoalTypeSelect(goal['value'] as String),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : (goal['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        goal['icon'] as IconData,
                        color: isSelected
                            ? Colors.white
                            : goal['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal['title'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0D1B4C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal['subtitle'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle,
                          color: Colors.white, size: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDietTypeOptions() {
    final diets = [
      {
        'value': 'balanced',
        'title': 'دايت متوازن',
        'subtitle': 'توازن صحي بين البروتين والكارب والدهون',
        'icon': Icons.balance,
      },
      {
        'value': 'keto',
        'title': 'كيتو دايت',
        'subtitle': 'قليل الكربوهيدرات وعالي الدهون',
        'icon': Icons.local_fire_department,
      },
      {
        'value': 'low_carb',
        'title': 'لو كارب',
        'subtitle': 'تقليل الكربوهيدرات بشكل معتدل',
        'icon': Icons.restaurant_menu,
      },
      {
        'value': 'intermittent_fasting',
        'title': 'صيام متقطع',
        'subtitle': 'تنظيم أوقات تناول الطعام',
        'icon': Icons.access_time,
      },
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: diets.map((diet) {
              final bool isSelected = widget.selectedDietType == diet['value'];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 14),
                child: Material(
                  color: isSelected ? const Color(0xFF0D1B4C) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  elevation: isSelected ? 4 : 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: InkWell(
                    onTap: () {
                      widget.onDietTypeSelect(diet['value'] as String);
                      if (diet['value'] != 'intermittent_fasting') {
                        widget.onIfScheduleSelect('');
                      }
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Icon(
                            diet['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0D1B4C),
                            size: 26,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  diet['title'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF0D1B4C),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  diet['subtitle'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (widget.selectedDietType == 'intermittent_fasting') ...[
          const SizedBox(height: 20),
          Text(
            'اختر جدول الصيام',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 12),
          _buildIfScheduleOptions(),
        ],
      ],
    );
  }

  Widget _buildIfScheduleOptions() {
    final schedules = [
      {
        'value': '16_8',
        'title': '16/8',
        'subtitle': '16 ساعة صيام، 8 ساعات أكل'
      },
      {
        'value': '18_6',
        'title': '18/6',
        'subtitle': '18 ساعة صيام، 6 ساعات أكل'
      },
      {'value': 'omad', 'title': 'OMAD', 'subtitle': 'وجبة واحدة في اليوم'},
    ];

    return Column(
      children: schedules.map((schedule) {
        final bool isSelected =
            widget.selectedIfSchedule == schedule['value'];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: isSelected
                ? const Color(0xFF0D1B4C).withOpacity(0.2)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () =>
                  widget.onIfScheduleSelect(schedule['value'] as String),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Text(
                      schedule['title'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1B4C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      schedule['subtitle'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(Icons.check_circle,
                          color: Color(0xFF0D1B4C), size: 22),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}