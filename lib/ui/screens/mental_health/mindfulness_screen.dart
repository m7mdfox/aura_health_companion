import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class MindfulnessScreen extends StatefulWidget {
  const MindfulnessScreen({super.key});

  @override
  State<MindfulnessScreen> createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends State<MindfulnessScreen> {
  final List<Map<String, dynamic>> activities = [
    {
      "title": "Breathing Exercises",
      "subtitle": "Deep breathing for instant calm.",
      "icon": Ionicons.create_outline,
      "color": const Color(0xFF10B981),
      "screen": const BreathingExerciseScreen(),
    },
    {
      "title": "Sleep Meditation",
      "subtitle": "Peaceful mind before sleep.",
      "icon": Ionicons.moon,
      "color": const Color(0xFF6366F1),
      "screen": const SleepMeditationScreen(),
    },
    {
      "title": "Healing Music",
      "subtitle": "Sounds to balance your mood.",
      "icon": Ionicons.musical_notes,
      "color": const Color(0xFFF59E0B),
      "screen": const HealingMusicScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Mindfulness & Relaxation',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find your inner peace, one breath at a time.',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return _buildActivityCard(
                    activity: activities[index],
                    isDark: isDark,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: _backButton(isDark),
      ),
      title: Text(
        'Mindfulness',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _backButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark 
              ? const Color(0xFF0F1120).withOpacity(0.7)
              : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark 
                ? Colors.white.withOpacity(0.1) 
                : const Color(0xFFE2E8F0), 
              width: 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 8,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Icon(
            Ionicons.arrow_back, 
            color: isDark ? Colors.white70 : const Color(0xFF475569), 
            size: 22
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required Map<String, dynamic> activity,
    required bool isDark,
  }) {
    final Color baseColor = activity['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => activity['screen'] as Widget,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                ? const Color(0xFF1A1D2E) 
                : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : baseColor.withOpacity(0.2), 
                width: 1.2
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [baseColor, baseColor.withOpacity(0.8)]
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['subtitle'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: baseColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder Screens
class BreathingExerciseScreen extends StatelessWidget {
  const BreathingExerciseScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Breathing Exercise'))
  );
}

class SleepMeditationScreen extends StatelessWidget {
  const SleepMeditationScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Sleep Meditation'))
  );
}

class HealingMusicScreen extends StatelessWidget {
  const HealingMusicScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Healing Music'))
  );
}