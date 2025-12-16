// lib/ui/screens/mental_health/mood_tracking_screen.dart
import 'package:aura_health_companion/ui/screens/mental_health/LanguageSelectionScreen.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  static final TextStyle _poppins =
      TextStyle(fontFamily: GoogleFonts.poppins().fontFamily);

  bool _isLoading = false;
  String? _todayMood;

  @override
  void initState() {
    super.initState();
    _loadTodayMood();
  }

  Future<void> _loadTodayMood() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDateOnly(DateTime.now());
    final savedDate = prefs.getString('last_mood_date');
    final savedMood = prefs.getString('today_mood');
    final savedUserId = prefs.getString('last_mood_user_id');

    final currentUserId = AuthService.profile?['auth_id'] ??
        AuthService.profile?['user_id'];

    if (savedDate != today || savedUserId != currentUserId) {
      await prefs.remove('last_mood_date');
      await prefs.remove('today_mood');
      await prefs.remove('last_mood_user_id');
      if (mounted) {
        setState(() => _todayMood = null);
      }
      return;
    }

    if (savedMood != null && mounted) {
      setState(() => _todayMood = savedMood);
    }
  }

  final List<Map<String, dynamic>> moods = [
    {
      "label": "Happy",
      "emoji": "😊",
      "color": const Color(0xFFFBBF24),
      "icon": Ionicons.happy,
    },
    {
      "label": "Relaxed",
      "emoji": "😌",
      "color": const Color(0xFF10B981),
      "icon": Ionicons.flower,
    },
    {
      "label": "Anxious",
      "emoji": "😰",
      "color": const Color(0xFF3B82F6),
      "icon": Ionicons.cloud,
    },
    {
      "label": "Sad",
      "emoji": "😢",
      "color": const Color(0xFF6B7280),
      "icon": Ionicons.sad,
    },
    {
      "label": "Neutral",
      "emoji": "😐",
      "color": const Color(0xFF9E9E9E),
      "icon": Ionicons.help_circle,
    },
    {
      "label": "Angry",
      "emoji": "😠",
      "color": const Color(0xFFE57373),
      "icon": Ionicons.flash,
    },
    {
      "label": "Tired",
      "emoji": "😴",
      "color": const Color(0xFF64B5F6),
      "icon": Ionicons.bed,
    },
    {
      "label": "Stressed",
      "emoji": "😫",
      "color": const Color(0xFFFFD54F),
      "icon": Ionicons.alert_circle,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final today = _formatDate(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'How are you feeling today?',
                        style: _poppins.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        today,
                        style: _poppins.copyWith(
                          fontSize: 15,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_todayMood != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Logged: $_todayMood',
                                style: _poppins.copyWith(
                                  fontSize: 14,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Tap any mood to update it',
                                        style: _poppins.copyWith(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      backgroundColor: Colors.blue.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.blue.shade300, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Ionicons.pencil,
                                          size: 14, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Edit',
                                        style: _poppins.copyWith(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: moods.length,
                    itemBuilder: (context, index) {
                      final mood = moods[index];
                      final isSelected = _todayMood == mood['label'];
                      return Opacity(
                        opacity: _isLoading ? 0.6 : 1.0,
                        child: AbsorbPointer(
                          absorbing: _isLoading,
                          child: _buildMoodCard(
                            mood: mood,
                            isSelected: isSelected,
                            isDark: isDark,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Color(0xFF10B981)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Updating your mood...',
                          style: _poppins.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
        'Mood Tracking',
        style: _poppins.copyWith(
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
              : Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark 
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.5), 
              width: 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 12,
                offset: const Offset(1, 3),
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

  Widget _buildMoodCard({
    required Map<String, dynamic> mood,
    required bool isSelected,
    required bool isDark,
  }) {
    final Color baseColor = mood['color'] as Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await _logMood(
            mood['label'] as String,
            mood['emoji'] as String,
            baseColor,
            isEdit: _todayMood != null,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? baseColor.withOpacity(0.9)
                  : (isDark 
                    ? Colors.white.withOpacity(0.1)
                    : baseColor.withOpacity(0.2)),
              width: isSelected ? 2.5 : 1.2,
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
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [baseColor, baseColor.withOpacity(0.8)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      mood['emoji'] as String,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  mood['label'] as String,
                  style: _poppins.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Icon(
                  mood['icon'] as IconData,
                  color: baseColor,
                  size: 20,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 6),
                  Icon(
                    Ionicons.checkmark_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logMood(
    String label,
    String emoji,
    Color color, {
    bool isEdit = false,
  }) async {
    final today = _formatDateOnly(DateTime.now());

    setState(() => _isLoading = true);

    final url = Uri.parse('http://10.0.2.2:4000/api/moods');
    final userId = AuthService.profile?['auth_id'] ??
        AuthService.profile?['user_id'];

    if (userId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'auth_id': userId,
          'mood_type': label.toLowerCase(),
          'note': emoji,
          'date': today,
        }),
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_mood_date', today);
        await prefs.setString('today_mood', label);
        await prefs.setString('last_mood_user_id', userId);

        setState(() {
          _isLoading = false;
          _todayMood = label;
        });

        final actionText = isEdit ? 'updated' : 'logged';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text('$emoji  ', style: const TextStyle(fontSize: 20)),
                Text(
                  'Mood $actionText: $label',
                  style: _poppins.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            elevation: 8,
            duration: const Duration(milliseconds: 1800),
          ),
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LanguageSelectionScreen(
                  moodLabel: label,
                  moodColor: color,
                ),
              ),
            );
          }
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? 'Failed to update mood. Try again.'
              : 'Failed to log mood. Check internet.'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _logMood(label, emoji, color, isEdit: isEdit),
          ),
        ),
      );
    }
  }

  String _formatDateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}