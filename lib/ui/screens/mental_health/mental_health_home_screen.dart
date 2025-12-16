import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'mood_tracking_screen.dart';
import 'ai_insights_screen.dart';
import 'mindfulness_screen.dart';
import 'mental_reports_screen.dart';
import 'mental_support_screen.dart';

class MentalHealthHomeScreen extends StatelessWidget {
  const MentalHealthHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 24),
              _buildFeatureCard(
                context,
                title: "Mood Tracking",
                subtitle: "Track your emotions daily",
                icon: Ionicons.happy,
                color: const Color(0xFFF97316),
                screen: const MoodTrackingScreen(),
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: "AI Insights",
                subtitle: "Personalized daily notes",
                icon: Ionicons.sparkles,
                color: const Color(0xFF8B5CF6),
                screen: const AIInsightsScreen(),
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: "Mindfulness & Relaxation",
                subtitle: "Meditate, breathe, relax",
                icon: Ionicons.flower,
                color: const Color(0xFF10B981),
                screen: const MindfulnessScreen(),
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: "Mental & Physical Reports",
                subtitle: "Insights into your well-being",
                icon: Ionicons.analytics,
                color: const Color(0xFF3B82F6),
                screen: const MentalReportsScreen(),
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: "Professional Support",
                subtitle: "Connect with experts",
                icon: Ionicons.people,
                color: const Color(0xFFEF4444),
                screen: const MentalSupportScreen(),
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              _buildDailyQuote(isDark),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Ionicons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF475569),
          ),
          onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
        ),
      ),
      title: Text(
        'Mental Health',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      centerTitle: true,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Ionicons.settings_outline,
              color: isDark ? Colors.white : const Color(0xFF475569),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1D2E), const Color(0xFF2D1B69)]
              : [const Color(0xFF00177E), const Color(0xFF1B1E36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF2D1B69) : const Color(0xFF00177E))
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Ionicons.heart, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mental Wellness Hub',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take care of your mind, one step at a time.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Ionicons.chevron_forward,
                  size: 20,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuote(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Ionicons.sparkles,
              color: Color(0xFFFBBF24),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '"Small steps every day lead to big changes."',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}