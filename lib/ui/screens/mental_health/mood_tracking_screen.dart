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

class _MoodTrackingScreenState extends State<MoodTrackingScreen>
    with TickerProviderStateMixin {
  // ────── Font shortcut ──────
  static final TextStyle _poppins =
      TextStyle(fontFamily: GoogleFonts.poppins().fontFamily);

  // ────── Animation Controllers ──────
  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late List<AnimationController> _glowControllers;
  late List<Animation<double>> _glowAnimations;

  // ────── UI State ──────
  bool _isLoading = false;
  String? _todayMood;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadTodayMood();
    _initAnimations();
  }

  void _initAnimations() {
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    final int moodCount = moods.length;
    final double staggerAmount = moodCount > 1 ? 0.8 / (moodCount - 1) : 0.0;

    _fadeAnimations = [];
    _slideAnimations = [];
    _glowControllers = [];
    _glowAnimations = [];

    for (int i = 0; i < moodCount; i++) {
      final double start = i * staggerAmount;

      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
        ),
      );
      final slide = Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero)
          .animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
        ),
      );
      _fadeAnimations.add(fade);
      _slideAnimations.add(slide);

      final glowCtrl = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      final glow = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: glowCtrl, curve: Curves.easeOut),
      );
      _glowControllers.add(glowCtrl);
      _glowAnimations.add(glow);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _animationsInitialized = true);
        _staggerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    for (var c in _glowControllers) c.dispose();
    super.dispose();
  }

  // Load saved mood for today (with user check)
  Future<void> _loadTodayMood() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDateOnly(DateTime.now());
    final savedDate = prefs.getString('last_mood_date');
    final savedMood = prefs.getString('today_mood');
    final savedUserId = prefs.getString('last_mood_user_id');

    final currentUserId = AuthService.profile?['auth_id'] ??
        AuthService.profile?['user_id'];

    // If user changed or date changed → clear old data
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

  // Mood data
  final List<Map<String, dynamic>> moods = [
    {
      "label": "Happy",
      "emoji": "Smile",
      "color": const Color(0xFFFBBF24),
      "icon": Ionicons.happy,
    },
    {
      "label": "Relaxed",
      "emoji": "Relaxed",
      "color": const Color(0xFF10B981),
      "icon": Ionicons.flower,
    },
    {
      "label": "Anxious",
      "emoji": "Anxious",
      "color": const Color(0xFF3B82F6),
      "icon": Ionicons.cloud,
    },
    {
      "label": "Sad",
      "emoji": "Sad",
      "color": const Color(0xFF6B7280),
      "icon": Ionicons.sad,
    },
    {
      "label": "Neutral",
      "emoji": "Neutral",
      "color": const Color(0xFF9E9E9E),
      "icon": Ionicons.help_circle,
    },
    {
      "label": "Angry",
      "emoji": "Angry",
      "color": const Color(0xFFE57373),
      "icon": Ionicons.flash,
    },
    {
      "label": "Tired",
      "emoji": "Tired",
      "color": const Color(0xFF64B5F6),
      "icon": Ionicons.bed,
    },
    {
      "label": "Stressed",
      "emoji": "Stressed",
      "color": const Color(0xFFFFD54F),
      "icon": Ionicons.alert_circle,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final today = _formatDate(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildPremiumAppBar(),
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
                          color: const Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        today,
                        style: _poppins.copyWith(
                          fontSize: 15,
                          color: const Color(0xFF64748B),
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
                              // Edit Mood Button
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
                  child: _animationsInitialized
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: moods.length,
                          itemBuilder: (context, index) {
                            final mood = moods[index];
                            final isSelected = _todayMood == mood['label'];
                            return Opacity(
                              opacity: _isLoading ? 0.6 : 1.0,
                              child: AbsorbPointer(
                                absorbing: _isLoading,
                                child: _buildPremiumMoodCard(
                                  index: index,
                                  mood: mood,
                                  fadeAnimation: _fadeAnimations[index],
                                  slideAnimation: _slideAnimations[index],
                                  glowAnimation: _glowAnimations[index],
                                  glowController: _glowControllers[index],
                                  isSelected: isSelected,
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: CircularProgressIndicator()),
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
                      color: Colors.white,
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
                            color: const Color(0xFF1E293B),
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

  PreferredSizeWidget _buildPremiumAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _backButton(),
        ),
        title: Text(
          'Mood Tracking',
          style: _poppins.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _backButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
            border:
                Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(1, 3),
              ),
            ],
          ),
          child: const Icon(Ionicons.arrow_back,
              color: Color(0xFF475569), size: 22),
        ),
      ),
    );
  }

  Widget _buildPremiumMoodCard({
    required int index,
    required Map<String, dynamic> mood,
    required Animation<double> fadeAnimation,
    required Animation<Offset> slideAnimation,
    required Animation<double> glowAnimation,
    required AnimationController glowController,
    required bool isSelected,
  }) {
    final Color baseColor = mood['color'] as Color;

    return AnimatedBuilder(
      animation: Listenable.merge([_staggerController, glowController]),
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Transform.scale(
              scale: 0.94 + (0.06 * fadeAnimation.value),
              child: Opacity(
                opacity: fadeAnimation.value,
                child: _buildGlassCard(
                  mood: mood,
                  baseColor: baseColor,
                  glowValue: glowAnimation.value,
                  isSelected: isSelected,
                  onTap: () async {
                    // Allow editing even if mood is already logged
                    await _logMood(
                      mood['label'] as String,
                      mood['emoji'] as String,
                      baseColor,
                      isEdit: _todayMood != null,
                    );
                    glowController.forward().then((_) => glowController.reset());
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassCard({
    required Map<String, dynamic> mood,
    required Color baseColor,
    required double glowValue,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        splashColor: baseColor.withOpacity(0.3),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9 - glowValue * 0.2),
                Colors.white.withOpacity(0.7 - glowValue * 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isSelected
                  ? baseColor.withOpacity(0.9)
                  : Colors.white.withOpacity(0.6),
              width: isSelected ? 2.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.25 + glowValue * 0.35),
                blurRadius: 16 + glowValue * 16,
                spreadRadius: glowValue * 6,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mood['label'] as String,
                  style: _poppins.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Icon(
                  mood['icon'] as IconData,
                  color: baseColor,
                  size: 20,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Ionicons.checkmark_circle,
                    color: Colors.green.shade600,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Log or update mood – allows editing on the same day
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

        // ────── NAVIGATE TO LANGUAGE SELECTION SCREEN ──────
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return LanguageSelectionScreen(
                    moodLabel: label,
                    moodColor: color,
                  );
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  );
                  return FadeTransition(opacity: fadeTween, child: child);
                },
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