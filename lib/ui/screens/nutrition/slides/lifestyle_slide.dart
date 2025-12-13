// lib/ui/screens/nutrition/slides/lifestyle_slide.dart
import 'package:flutter/material.dart';
import '../widgets/option_slide.dart';

class LifestyleSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const LifestyleSlide({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'value': 'أجلس فترات طويلة\n(عمل مكتبي)',
        'title': 'أجلس فترات طويلة\n(عمل مكتبي)',
        'icon': Icons.chair,
      },
      {
        'value': 'أتحرك على فترات متقطعة',
        'title': 'أتحرك على فترات متقطعة',
        'icon': Icons.directions_walk,
      },
      {
        'value': 'يومي نشيط',
        'title': 'يومي نشيط',
        'icon': Icons.local_fire_department,
      },
      {
        'value': 'نشاط بدني عالي',
        'title': 'نشاط بدني عالي',
        'icon': Icons.directions_run,
      },
    ];

    return OptionSlide(
      title: 'صف يومك النموذجي',
      options: options,
      selectedValue: selected,
      onSelect: (v) {
        onSelect(v);
        onNext();
      },
      onNext: onNext,
    );
  }
}
