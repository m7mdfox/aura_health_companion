// lib/ui/screens/nutrition/slides/activity_level_slide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/option_slide.dart';

class ActivityLevelSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const ActivityLevelSlide({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      {
        'value': 'sedentary',
        'title': 'قليل النشاط',
        'subtitle': 'أجلس معظم اليوم، لا أمارس رياضة',
        'icon': Icons.chair,
      },
      {
        'value': 'lightly_active',
        'title': 'نشاط خفيف',
        'subtitle': 'رياضة خفيفة 1-3 أيام/أسبوع',
        'icon': Icons.directions_walk,
      },
      {
        'value': 'moderately_active',
        'title': 'نشاط متوسط',
        'subtitle': 'رياضة متوسطة 3-5 أيام/أسبوع',
        'icon': Icons.directions_run,
      },
      {
        'value': 'very_active',
        'title': 'نشاط عالي',
        'subtitle': 'رياضة قوية 6-7 أيام/أسبوع',
        'icon': Icons.fitness_center,
      },
      {
        'value': 'extra_active',
        'title': 'نشاط مكثف جدًا',
        'subtitle': 'رياضة قوية يوميًا + عمل بدني',
        'icon': Icons.local_fire_department,
      },
    ];

    return OptionSlide(
      title: 'ما مستوى نشاطك البدني؟',
      options: levels,
      selectedValue: selected,
      onSelect: (v) {
        onSelect(v);
        onNext();
      },
      onNext: onNext,
      hasSubtitle: true,
    );
  }
}