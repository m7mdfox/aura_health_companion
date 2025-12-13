// lib/ui/screens/nutrition/slides/improvement_goal_slide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImprovementGoalSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback? onNext;
  final bool isLoading;

  const ImprovementGoalSlide({
    super.key,
    required this.selected,
    required this.onSelect,
    this.onNext,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final goals = [
      {'value': 'طاقتي اليومية', 'title': 'طاقتي اليومية', 'icon': Icons.bolt},
      {'value': 'شكل جسمي', 'title': 'شكل جسمي', 'icon': Icons.fitness_center},
      {'value': 'جودة نومي', 'title': 'جودة نومي', 'icon': Icons.bedtime},
      {'value': 'عاداتي الغذائية', 'title': 'عاداتي الغذائية', 'icon': Icons.restaurant},
      {'value': 'لياقتي العامة', 'title': 'لياقتي العامة', 'icon': Icons.monitor_heart},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'ما الذي تريد تحسينه؟',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: goals.map((g) {
                final bool isSelected = selected == g['value'];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: isSelected
                        ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C))
                        : (isDark ? const Color(0xFF1A1D2E) : Colors.white),
                    borderRadius: BorderRadius.circular(18),
                    elevation: isSelected ? 4 : 2,
                    shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    child: InkWell(
                      onTap: () => onSelect(g['value'] as String),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              g['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white60 : Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              g['title'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : const Color(0xFF0D1B4C)),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'اعرض خطتي',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}