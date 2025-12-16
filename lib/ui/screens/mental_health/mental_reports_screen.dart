import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class MentalReportsScreen extends StatefulWidget {
  const MentalReportsScreen({super.key});

  @override
  State<MentalReportsScreen> createState() => _MentalReportsScreenState();
}

class _MentalReportsScreenState extends State<MentalReportsScreen> {
  Map<String, int> moodData = {};
  List<Map<String, dynamic>> weeklyTrend = [];
  double _allTimeAverage = 0.0;
  double _weeklyAverage = 0.0;
  int _totalEntries = 0;
  int _currentStreak = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userId = AuthService.profile?['auth_id'] ?? AuthService.profile?['user_id'];
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'User not logged in. Please login again.';
        });
      }
      return;
    }

    final uri = Uri.parse('http://10.0.2.2:4000/api/moods/summary/$userId');

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);

        final dist = <String, int>{};
        (json['distribution'] as Map<String, dynamic>?)?.forEach((key, value) {
          final normalized = _normalizeMood(key);
          dist[normalized] = value as int;
        });

        final week = (json['weekly'] as List? ?? [])
            .map((e) => {
                  'day': e['day']?.toString() ?? 'Unknown',
                  'mood': (e['mood'] as num?)?.toDouble() ?? 0.0,
                })
            .toList();

        final allTimeAvg = (json['allTimeAverage'] as num?)?.toDouble() ?? 0.0;
        final weeklyAvg = (json['weeklyAverage'] as num?)?.toDouble() ?? 0.0;
        final total = json['total'] as int? ?? 0;
        final streak = json['currentStreak'] as int? ?? 0;

        setState(() {
          moodData = dist;
          weeklyTrend = week;
          _allTimeAverage = allTimeAvg;
          _weeklyAverage = weeklyAvg;
          _totalEntries = total;
          _currentStreak = streak;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = "Server Error: ${resp.statusCode}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Network Error: $e";
        });
      }
    }
  }

  String _normalizeMood(String key) {
    final lower = key.toLowerCase();
    return lower == 'happy'
        ? 'Happy'
        : lower == 'relaxed'
            ? 'Relaxed'
            : lower == 'anxious'
                ? 'Anxious'
                : lower == 'sad'
                    ? 'Sad'
                    : lower == 'neutral'
                        ? 'Neutral'
                        : lower == 'angry'
                            ? 'Angry'
                            : lower == 'tired'
                                ? 'Tired'
                                : lower == 'stressed'
                                    ? 'Stressed'
                                    : key;
  }

  String _formatStreak(int streak) {
    if (streak == 0) return '0 days';
    if (streak == 1) return '1 day';
    return '$streak days';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? Colors.white : const Color(0xFF00177E),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
        appBar: _buildAppBar(isDark),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Ionicons.alert_circle,
                size: 64,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00177E),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(_allTimeAverage, _weeklyAverage, _totalEntries, isDark),
              const SizedBox(height: 20),
              _buildPieChartCard(_totalEntries, isDark),
              const SizedBox(height: 20),
              _buildLineChartCard(isDark),
              const SizedBox(height: 20),
              _buildStatsRow(_totalEntries, isDark),
              const SizedBox(height: 20),
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
      leading: IconButton(
        icon: Icon(
          Ionicons.arrow_back,
          color: isDark ? Colors.white : const Color(0xFF475569),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Reports',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader(double allTimeAvg, double weeklyAvg, int total, bool isDark) {
    String moodText, emoji;
    if (total == 0) {
      moodText = "No Data Yet";
      emoji = "😐";
    } else if (allTimeAvg >= 4.5) {
      moodText = "Excellent";
      emoji = "😄";
    } else if (allTimeAvg >= 3.5) {
      moodText = "Good";
      emoji = "😊";
    } else if (allTimeAvg >= 2.5) {
      moodText = "Okay";
      emoji = "😐";
    } else {
      moodText = "Needs Improvement";
      emoji = "😔";
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1D2E), const Color(0xFF2D1B69)]
              : [const Color(0xFF00177E), const Color(0xFF1B1E36)],
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
      child: Column(
        children: [
          Text(
            'Your Weekly Summary',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  moodText,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Start logging your mood!'
                : 'Average Mood: ${allTimeAvg.toStringAsFixed(1)} / 5.0',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This Week: ${weeklyAvg.toStringAsFixed(1)}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(int total, bool isDark) {
    if (total == 0) {
      return _buildCard(
        title: 'Mood Distribution',
        icon: Ionicons.pie_chart,
        isDark: isDark,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              'No mood entries yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      );
    }

    return _buildCard(
      title: 'Mood Distribution',
      icon: Ionicons.pie_chart,
      isDark: isDark,
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          children: [
            CustomPaint(
              painter: PieChartPainter(moodData, total),
              size: Size.infinite,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'Total Entries',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartCard(bool isDark) {
    return _buildCard(
      title: 'Weekly Trend',
      icon: Ionicons.trending_up,
      isDark: isDark,
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: weeklyTrend.isEmpty
            ? Center(
                child: Text(
                  'No data for this week',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              )
            : CustomPaint(
                painter: LineChartPainter(weeklyTrend),
                size: Size.infinite,
              ),
      ),
    );
  }

  Widget _buildStatsRow(int total, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Entries',
            total == 0 ? '0' : '$total',
            Ionicons.pulse,
            const Color(0xFFF59E0B),
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Current Streak',
            _formatStreak(_currentStreak),
            Ionicons.flame,
            const Color(0xFFEF4444),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final int total;

  PieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.7;
    double startAngle = -math.pi / 2;

    final colors = {
      'Happy': const Color(0xFFFBBF24),
      'Relaxed': const Color(0xFF10B981),
      'Anxious': const Color(0xFF3B82F6),
      'Sad': const Color(0xFF6B7280),
      'Neutral': const Color(0xFF9E9E9E),
      'Angry': const Color(0xFFE57373),
      'Tired': const Color(0xFF64B5F6),
      'Stressed': const Color(0xFFFFD54F),
    };

    data.forEach((mood, count) {
      final sweepAngle = (count / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[mood] ?? Colors.grey
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    });

    canvas.drawCircle(center, radius * 0.55, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    final double dx = size.width / (data.length - 1);
    const double maxY = 5.0;
    final double dy = (size.height - 40) / maxY;

    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final mood = data[i]['mood'] as num;
      final y = mood > 0 ? 20 + (size.height - 40) - mood * dy : size.height - 20;
      points.add(Offset(x, y));
    }

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paint);

    for (final p in points) {
      canvas.drawCircle(p, 6, Paint()..color = const Color(0xFF10B981));
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}