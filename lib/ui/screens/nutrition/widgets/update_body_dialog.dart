// lib/ui/screens/nutrition/widgets/update_body_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateBodyDialog extends StatefulWidget {
  final double currentHeight;
  final double currentWeight;

  const UpdateBodyDialog({
    super.key,
    required this.currentHeight,
    required this.currentWeight,
  });

  @override
  State<UpdateBodyDialog> createState() => _UpdateBodyDialogState();
}

class _UpdateBodyDialogState extends State<UpdateBodyDialog> {
  late TextEditingController heightCtrl;
  late TextEditingController weightCtrl;

  @override
  void initState() {
    super.initState();
    heightCtrl = TextEditingController(
      text: widget.currentHeight.toInt().toString(),
    );
    weightCtrl = TextEditingController(
      text: widget.currentWeight.toInt().toString(),
    );
  }

  @override
  void dispose() {
    heightCtrl.dispose();
    weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تعديل الطول والوزن',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInputField(
                controller: heightCtrl,
                label: 'الطول (سم)',
                prefixIcon: Icons.height,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: weightCtrl,
                label: 'الوزن (كجم)',
                prefixIcon: Icons.fitness_center,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final h = double.tryParse(heightCtrl.text);
                        final w = double.tryParse(weightCtrl.text);
                        if (h != null &&
                            w != null &&
                            h >= 100 &&
                            h <= 250 &&
                            w >= 30 &&
                            w <= 300) {
                          Navigator.pop(context, {'height': h, 'weight': w});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'يرجى إدخال قيم صحيحة',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: Colors.red.shade400,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'حفظ',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.mulish(
        color: isDark ? Colors.white : const Color(0xFF0D1B4C),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(
          color: isDark ? Colors.white60 : Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF252838) : Colors.grey.shade50,
        prefixIcon: Icon(
          prefixIcon,
          color: isDark ? Colors.white60 : Colors.grey,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
            width: 2,
          ),
        ),
      ),
    );
  }
}