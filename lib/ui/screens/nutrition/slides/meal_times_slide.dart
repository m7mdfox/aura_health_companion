// lib/ui/screens/nutrition/slides/meal_times_slide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealTimesSlide extends StatelessWidget {
  final List<String> selectedTimes;
  final void Function(String, bool) onToggle;
  final VoidCallback onNext;

  const MealTimesSlide({
    super.key,
    required this.selectedTimes,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final times = [
      {'key': 'صباحًا مبكرًا', 'title': 'صباحًا مبكرًا'},
      {'key': 'منتصف اليوم', 'title': 'منتصف اليوم'},
      {'key': 'مساءً', 'title': 'مساءً'},
      {'key': 'متنوع حسب اليوم', 'title': 'متنوع حسب اليوم'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'متى تفضل تناول وجباتك؟',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 30),
          ...times.map((t) {
            final key = t['key'] as String;
            final bool isSelected = selectedTimes.contains(key);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: isSelected ? const Color(0xFF0D1B4C) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: isSelected ? 4 : 2,
                shadowColor: Colors.black.withOpacity(0.1),
                child: InkWell(
                  onTap: () => onToggle(key, !isSelected),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Text(
                          t['title'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0D1B4C),
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 22,
                          )
                        else
                          Icon(
                            Icons.circle_outlined,
                            color: Colors.grey.shade400,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          _buildNextButton(onNext),
        ],
      ),
    );
  }

  Widget _buildNextButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: const Color(0xFF0D1B4C),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'التالي',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}