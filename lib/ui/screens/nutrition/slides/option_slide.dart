// lib/ui/screens/nutrition/widgets/option_slide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionSlide extends StatelessWidget {
  final String title;
  final List<Map<String, Object>> options;
  final String selectedValue;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final bool useIcon;
  final bool hasSubtitle;

  const OptionSlide({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
    required this.onNext,
    this.useIcon = true,
    this.hasSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 30),
          ...options.map((opt) {
            final String value = opt['value'] as String;
            final bool isSelected = selectedValue == value;
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
                  onTap: () => onSelect(value),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (useIcon && opt['icon'] != null) ...[
                          Icon(
                            opt['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white60 : Colors.grey),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['title'] as String,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  height: 1.4,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white : const Color(0xFF0D1B4C)),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (hasSubtitle && opt['subtitle'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  opt['subtitle'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: isSelected
                                        ? Colors.white70
                                        : (isDark ? Colors.white60 : Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          _buildNextButton(onNext, isDark),
        ],
      ),
    );
  }

  Widget _buildNextButton(VoidCallback onPressed, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
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