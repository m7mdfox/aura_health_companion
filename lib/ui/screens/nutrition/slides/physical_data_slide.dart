// lib/ui/screens/nutrition/slides/physical_data_slide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/update_body_dialog.dart';

class PhysicalDataSlide extends StatelessWidget {
  final double height;
  final double weight;
  final int age;
  final String gender;
  final Function(double, double) onEdit;
  final VoidCallback onNext;
  final bool isLoading;

  const PhysicalDataSlide({
    super.key,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.onEdit,
    required this.onNext,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'بياناتك البدنية',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 40),
          isLoading
              ? const CircularProgressIndicator(color: Color(0xFF0D1B4C))
              : Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDataRow(
                        Icons.height,
                        '${height.toInt()} سم',
                        'الطول',
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 20),
                      _buildDataRow(
                        Icons.fitness_center,
                        '${weight.toInt()} كجم',
                        'الوزن',
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 20),
                      _buildDataRow(
                        Icons.cake,
                        '$age سنة',
                        'العمر',
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 20),
                      _buildDataRow(
                        gender == 'male' ? Icons.male : Icons.female,
                        gender == 'male' ? 'ذكر' : 'أنثى',
                        'الجنس',
                      ),
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final result = await showDialog<Map<String, double>>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => UpdateBodyDialog(
                              currentHeight: height,
                              currentWeight: weight,
                            ),
                          );
                          if (result != null) {
                            onEdit(result['height']!, result['weight']!);
                          }
                        },
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: Text(
                          'تعديل الطول والوزن',
                          style: GoogleFonts.cairo(),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D1B4C),
                          side: const BorderSide(color: Color(0xFF0D1B4C)),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          const Spacer(),
          _buildNextButton(onNext),
        ],
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B4C).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: const Color(0xFF0D1B4C)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.mulish(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D1B4C),
              ),
            ),
          ],
        ),
      ],
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