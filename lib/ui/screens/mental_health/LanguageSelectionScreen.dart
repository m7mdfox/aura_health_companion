// lib/ui/screens/mental_health/language_selection_screen.dart
import 'package:aura_health_companion/ui/screens/mental_health/questions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_health_companion/ui/screens/mental_health/mood_questions_screen.dart';
import 'package:ionicons/ionicons.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final String moodLabel;
  final Color moodColor;

  const LanguageSelectionScreen({
    super.key,
    required this.moodLabel,
    required this.moodColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF475569),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocaleProvider.currentLocale == 'ar' ? 'اختر اللغة' : 'Select Language',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Ionicons.language,
                  color: moodColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Choose your preferred language',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'اختر لغتك المفضلة',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLangButton(context, 'English', '🇺🇸', 'en', isDark),
                  const SizedBox(width: 20),
                  _buildLangButton(context, 'العربية', '🇸🇦', 'ar', isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(
    BuildContext context,
    String label,
    String flag,
    String locale,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          LocaleProvider.currentLocale = locale;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MoodQuestionsScreen(
                moodLabel: moodLabel,
                moodColor: moodColor,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xFF1A1D2E)
              : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: moodColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          elevation: 0,
        ),
        child: Column(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}