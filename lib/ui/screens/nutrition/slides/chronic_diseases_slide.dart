// lib/ui/screens/nutrition/slides/chronic_diseases_slide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChronicDiseasesSlide extends StatelessWidget {
  final List<String> selectedDiseases;
  final void Function(String, bool) onToggle;
  final VoidCallback onNext;

  const ChronicDiseasesSlide({
    super.key,
    required this.selectedDiseases,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final diseases = [
      {'key': 'diabetes', 'title': 'السكري', 'icon': Icons.medical_services},
      {
        'key': 'hypertension',
        'title': 'ضغط الدم المرتفع',
        'icon': Icons.favorite
      },
      {
        'key': 'high_cholesterol',
        'title': 'الكوليسترول المرتفع',
        'icon': Icons.bloodtype
      },
      {
        'key': 'kidney_disease',
        'title': 'مشاكل في الكلى',
        'icon': Icons.water_drop
      },
      {
        'key': 'heart_disease',
        'title': 'أمراض القلب',
        'icon': Icons.monitor_heart
      },
      {
        'key': 'thyroid',
        'title': 'مشاكل في الغدة الدرقية',
        'icon': Icons.health_and_safety
      },
      {
        'key': 'none',
        'title': 'لا أعاني من أي مرض',
        'icon': Icons.check_circle_outline
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'هل تعاني من أمراض مزمنة؟',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سنأخذ ذلك بعين الاعتبار في خطتك الغذائية',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: diseases.map((disease) {
                final key = disease['key'] as String;
                final bool isSelected = selectedDiseases.contains(key);
                final bool isNoneSelected = selectedDiseases.contains('none');
                final bool isDisabled = isNoneSelected && key != 'none';

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: isDisabled ? 0.4 : 1.0,
                    child: Material(
                      color: isSelected
                          ? const Color(0xFF0D1B4C)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: isSelected ? 4 : 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: InkWell(
                        onTap: isDisabled
                            ? null
                            : () {
                                if (key == 'none' && !isSelected) {
                                  for (var d in diseases) {
                                    if (selectedDiseases
                                        .contains(d['key'])) {
                                      onToggle(d['key'] as String, false);
                                    }
                                  }
                                  onToggle(key, true);
                                } else if (key == 'none' && isSelected) {
                                  onToggle(key, false);
                                } else if (key != 'none' && !isSelected) {
                                  if (selectedDiseases.contains('none')) {
                                    onToggle('none', false);
                                  }
                                  onToggle(key, true);
                                } else {
                                  onToggle(key, !isSelected);
                                }
                              },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : const Color(0xFF0D1B4C)
                                          .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  disease['icon'] as IconData,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF0D1B4C),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  disease['title'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF0D1B4C),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 24,
                                )
                              else
                                Icon(
                                  Icons.circle_outlined,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                            ],
                          ),
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
                backgroundColor: const Color(0xFF0D1B4C),
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