// lib/ui/screens/nutrition/slides/eating_relation_slide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final options = [
      {'value': 'آكل عندما أشعر بالتوتر', 'title': 'آكل عندما أشعر بالتوتر'},
      {'value': 'آكل بانتظام لكن بدون خطة', 'title': 'آكل بانتظام لكن بدون خطة'},
      {'value': 'ملتزم بنظام غذائي غالبًا', 'title': 'ملتزم بنظام غذائي غالبًا'},
      {'value': 'أجد صعوبة في مقاومة الحلويات', 'title': 'أجد صعوبة في مقاومة الحلويات'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'كيف تصف علاقتك بالطعام؟',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: options.map((option) {
                final bool isSelected = selected == option['value'];
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
                        onSelect(option['value'] as String);
                        onNext();
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option['title'] as String,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white : const Color(0xFF0D1B4C)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.white, size: 24)
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: isDark ? Colors.white38 : Colors.grey.shade400,
                                size: 24,
                              ),
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