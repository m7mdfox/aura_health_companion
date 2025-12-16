import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aura_health_companion/data/auth_service.dart';
import 'dart:async';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  String? moodLabel;
  Color? moodColor;
  List<String>? notes;
  bool _isLoading = true;
  String? _error;
  Timer? _pollTimer;
  bool _isArabic = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _fetchLatestInsights();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _fetchLatestInsights().then((_) {
        if (notes != null && mounted) {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _fetchLatestInsights() async {
    final userId = AuthService.profile?['auth_id'] ?? AuthService.profile?['user_id'];
    if (userId == null || !mounted) return;

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final res = await http.get(
        Uri.parse('http://10.0.2.2:4000/api/moods/latest-insights/$userId'),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawInsights = data['ai_insights'] as String?;
        final moodType = data['mood_type'] as String?;
        final date = data['date'] as String?;

        if (rawInsights == null || rawInsights.isEmpty || moodType == null) {
          setState(() => _error = 'No insights yet');
          return;
        }

        final today = DateTime.now();
        final serverDate = DateTime.parse(date!);
        if (today.difference(serverDate).inDays.abs() > 1) {
          setState(() => _error = 'No insights for today');
          return;
        }

        try {
          final insightsJson = jsonDecode(rawInsights);
          final List<dynamic> notesList = insightsJson['notes'] ?? [];
          notes = notesList.cast<String>();

          _isArabic = notes!.any((note) => RegExp(r'[\u0600-\u06FF]').hasMatch(note));
        } catch (e) {
          setState(() => _error = 'Invalid insights format');
          return;
        }

        setState(() {
          moodLabel = moodType.toUpperCase();
          moodColor = _getMoodColor(moodType);
          _isLoading = false;
          _error = null;
        });
      } else if (res.statusCode == 404) {
        setState(() {
          _error = 'Analyzing your answers...';
          _isLoading = false;
        });
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection failed';
          _isLoading = false;
        });
      }
    }
  }

  Color _getMoodColor(String type) {
    final map = {
      'happy': const Color(0xFFFBBF24),
      'relaxed': const Color(0xFF10B981),
      'anxious': const Color(0xFF3B82F6),
      'sad': const Color(0xFF6B7280),
      'neutral': const Color(0xFF9E9E9E),
      'angry': const Color(0xFFE57373),
      'tired': const Color(0xFF64B5F6),
      'stressed': const Color(0xFFFFD54F),
    };
    return map[type.toLowerCase()] ?? const Color(0xFF8B5CF6);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: _isLoading
            ? _buildLoading(isDark)
            : _error != null
                ? _buildError(isDark)
                : _buildNotesList(isDark),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: Text(
        moodLabel != null ? 'AI Notes • $moodLabel' : 'AI Notes',
        style: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A1D2E), const Color(0xFF0F1120)]
                : [const Color(0xFF00177E), const Color(0xFF0F1120)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.white : const Color(0xFF00177E),
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Generating your notes...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.cloud_offline_outline,
              size: 80,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchLatestInsights,
              icon: const Icon(Ionicons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00177E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildNoteCard(notes![index], index, isDark),
          ),
          const SizedBox(height: 28),
          _buildHomeButton(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: moodColor != null
              ? [moodColor!, moodColor!.withOpacity(0.85)]
              : isDark
                  ? [const Color(0xFF1A1D2E), const Color(0xFF2D1B69)]
                  : [const Color(0xFF00177E), const Color(0xFF1B1E36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (moodColor ?? const Color(0xFF00177E)).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Ionicons.sparkles, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your AI Notes',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Quick insights for today',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String text, int index, bool isDark) {
    final icons = [
      Ionicons.document_text_outline,
      Ionicons.heart_outline,
      Ionicons.flash_outline,
      Ionicons.walk_outline,
      Ionicons.calendar_outline,
      Ionicons.star_outline,
      Ionicons.warning_outline,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: moodColor != null
              ? moodColor!.withOpacity(0.2)
              : (isDark ? Colors.white12 : Colors.grey.shade200),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: moodColor != null
                  ? moodColor!.withOpacity(0.15)
                  : (isDark ? Colors.white12 : const Color(0xFFE0E7FF)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icons[index % icons.length],
              color: moodColor ?? const Color(0xFF00177E),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.5,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        icon: const Icon(Ionicons.home, size: 20),
        label: Text(
          'Back to Home',
          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: moodColor ?? const Color(0xFF00177E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          shadowColor: (moodColor ?? const Color(0xFF00177E)).withOpacity(0.4),
        ),
      ),
    );
  }
}