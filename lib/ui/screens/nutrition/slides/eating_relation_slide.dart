// lib/ui/screens/nutrition/slides/eating_relation_slide.dart
import 'package:flutter/material.dart';
import '../widgets/option_slide.dart';

class EatingRelationSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const EatingRelationSlide({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'value': 'آكل عندما أشعر بالتوتر',
        'title': 'آكل عندما أشعر بالتوتر',
      },
      {
        'value': 'آكل بانتظام لكن بدون خطة',
        'title': 'آكل بانتظام لكن بدون خطة',
      },
      {
        'value': 'ملتزم بنظام غذائي غالبًا',
        'title': 'ملتزم بنظام غذائي غالبًا',
      },
      {
        'value': 'أجد صعوبة في مقاومة الحلويات',
        'title': 'أجد صعوبة في مقاومة الحلويات',
      },
    ];

    return OptionSlide(
      title: 'كيف تصف علاقتك بالطعام؟',
      options: options,
      selectedValue: selected,
      onSelect: (v) {
        onSelect(v);
        onNext();
      },
      onNext: onNext,
      useIcon: false,
    );
  }
}