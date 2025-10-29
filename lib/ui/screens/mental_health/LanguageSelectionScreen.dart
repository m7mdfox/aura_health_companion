// lib/ui/screens/mental_health/language_selection_screen.dart
import 'package:aura_health_companion/ui/screens/mental_health/questions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_health_companion/ui/screens/mental_health/mood_questions_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final String moodLabel;
  final Color moodColor;

  const LanguageSelectionScreen({
    super.key,
    required this.moodLabel,
    required this.moodColor,
  });

  static final TextStyle _poppins =
      TextStyle(fontFamily: GoogleFonts.poppins().fontFamily);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF475569)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocaleProvider.currentLocale == 'ar' ? 'اختر اللغة' : 'Select Language',
          style: _poppins.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose your preferred language',
              style: _poppins.copyWith(fontSize: 18, color: const Color(0xFF475569)),
              textAlign: TextAlign.center,
            ),
            Text(
              'اختر لغتك المفضلة',
              style: _poppins.copyWith(fontSize: 18, color: const Color(0xFF475569)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLangButton(context, 'English', 'US', 'en'),
                const SizedBox(width: 20),
                _buildLangButton(context, 'العربية', 'SA', 'ar'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String label, String flag, String locale) {
    return ElevatedButton(
      onPressed: () {
        LocaleProvider.currentLocale = locale;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MoodQuestionsScreen(moodLabel: moodLabel, moodColor: moodColor),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: moodColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(label, style: _poppins.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}