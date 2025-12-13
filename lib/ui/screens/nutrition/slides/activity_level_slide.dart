// lib/ui/screens/nutrition/slides/activity_level_slide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'ما مستوى نشاطك البدني؟',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: levels.map((level) {
                final bool isSelected = selected == level['value'];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Material(
                    color: isSelected
                        ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C))
                        : (isDark ? const Color(0xFF1A1D2E) : Colors.white),
                    borderRadius: BorderRadius.circular(18),
                    elevation: isSelected ? 4 : 2,
                    shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    child: InkWell(
                      onTap: () {
                        onSelect(level['value'] as String);
                        onNext();
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Icon(
                              level['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C)),
                              size: 26,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level['title'] as String,
                                    style: GoogleFonts.cairo(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? Colors.white : const Color(0xFF0D1B4C)),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    level['subtitle'] as String,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white70
                                          : (isDark ? Colors.white60 : Colors.grey.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.white, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                'التالي',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
