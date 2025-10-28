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

class _MentalReportsScreenState extends State<MentalReportsScreen>
    with TickerProviderStateMixin {
  static final TextStyle _poppins =
      TextStyle(fontFamily: GoogleFonts.poppins().fontFamily);

  // Animation Controllers
  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late List<AnimationController> _glowControllers;
  late List<Animation<double>> _glowAnimations;

  // Data from backend
  Map<String, int> moodData = {};
  List<Map<String, dynamic>> weeklyTrend = [];
  double _allTimeAverage = 0.0;
  double _weeklyAverage = 0.0;
  int _totalEntries = 0;
  int _currentStreak = 0;        // ✅ NEW: Current streak from backend
  bool _isLoading = true;
  String? _error;
  bool _animationsReady = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchSummary();
  }

  void _initAnimations() {
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    const int itemCount = 4;
    final double staggerAmount = itemCount > 1 ? 0.8 / (itemCount - 1) : 0.0;

    _fadeAnimations = [];
    _slideAnimations = [];
    _glowControllers = [];
    _glowAnimations = [];

    for (int i = 0; i < itemCount; i++) {
      final double start = i * staggerAmount;

      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
        ),
      );
      final slide = Tween<Offset>(begin: const Offset(0, 0.7), end: Offset.zero)
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
        setState(() => _animationsReady = true);
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
    print('Fetching summary from: $uri');

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));

      print('STATUS CODE: ${resp.statusCode}');
      print('RESPONSE BODY: ${resp.body}');

      if (!mounted) return;

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        print('PARSED JSON: $json');

        // Mood distribution
        final dist = <String, int>{};
        (json['distribution'] as Map<String, dynamic>?)?.forEach((key, value) {
          final normalized = _normalizeMood(key);
          dist[normalized] = value as int;
        });

        // Weekly trend
        final week = (json['weekly'] as List? ?? [])
            .map((e) => {
                  'day': e['day']?.toString() ?? 'Unknown',
                  'mood': (e['mood'] as num?)?.toDouble() ?? 0.0,
                })
            .toList();

        // Averages and stats
        final allTimeAvg = (json['allTimeAverage'] as num?)?.toDouble() ?? 0.0;
        final weeklyAvg = (json['weeklyAverage'] as num?)?.toDouble() ?? 0.0;
        final total = json['total'] as int? ?? 0;
        final streak = json['currentStreak'] as int? ?? 0;  // ✅ GET STREAK FROM BACKEND

        setState(() {
          moodData = dist;
          weeklyTrend = week;
          _allTimeAverage = allTimeAvg;
          _weeklyAverage = weeklyAvg;
          _totalEntries = total;
          _currentStreak = streak;     // ✅ UPDATE STREAK
          _isLoading = false;
        });

        print('✅ Loaded: Total=$total, Streak=$_currentStreak, Avg=$_allTimeAverage');
      } else {
        setState(() {
          _isLoading = false;
          _error = "Server Error: ${resp.statusCode}\n${resp.body}";
        });
      }
    } catch (e) {
      print('EXCEPTION: $e');
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

  // ✅ NEW: Format streak display
  String _formatStreak(int streak) {
    if (streak == 0) return '0 days';
    if (streak == 1) return '1 day';
    return '$streak days';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildLightAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: _poppins.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchSummary,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildLightAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (_animationsReady) ...[
                _buildAnimatedSection(
                  index: 0,
                  child: _buildPremiumHeader(_allTimeAverage, _weeklyAverage, _totalEntries),
                ),
                const SizedBox(height: 28),
                _buildAnimatedSection(
                  index: 1,
                  child: _buildPieChartCard(_totalEntries),
                ),
                const SizedBox(height: 28),
                _buildAnimatedSection(
                  index: 2,
                  child: _buildLineChartCard(),
                ),
                const SizedBox(height: 28),
                _buildAnimatedSection(
                  index: 3,
                  child: _buildStatsRow(_totalEntries),
                ),
              ] else ...[
                const Center(child: CircularProgressIndicator()),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ... (keep all other methods unchanged: _buildAnimatedSection, _buildLightAppBar, _backButton, _buildPremiumHeader, _buildPieChartCard, _buildLineChartCard)

  Widget _buildStatsRow(int total) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Entries',
            total == 0 ? '0' : '$total',
            Ionicons.pulse,
            const Color(0xFFF59E0B),
            _glowControllers[3],
            _glowAnimations[3],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Current Streak',                           // ✅ Fixed label
            _formatStreak(_currentStreak),              // ✅ Real streak from backend
            Ionicons.flame,
            const Color(0xFFEF4444),
            _glowControllers[3],
            _glowAnimations[3],
          ),
        ),
      ],
    );
  }

  // ... (keep _buildStatCard, _buildGlassCard, PieChartPainter, LineChartPainter unchanged)
  
  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_staggerController, _glowControllers[index]]),
      builder: (context, _) {
        return SlideTransition(
          position: _slideAnimations[index],
          child: FadeTransition(
            opacity: _fadeAnimations[index],
            child: Transform.scale(
              scale: 0.94 + (0.06 * _fadeAnimations[index].value),
              child: Opacity(opacity: _fadeAnimations[index].value, child: child),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildLightAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _backButton(),
        ),
        title: Text(
          'Reports',
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
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: const Icon(Ionicons.arrow_back, color: Color(0xFF475569), size: 22),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(double allTimeAvg, double weeklyAvg, int total) {
    String moodText, emoji;
    if (total == 0) {
      moodText = "No Data Yet";
      emoji = "Neutral";
    } else if (allTimeAvg >= 4.5) {
      moodText = "Excellent";
      emoji = "Very Happy";
    } else if (allTimeAvg >= 3.5) {
      moodText = "Good";
      emoji = "Smile";
    } else if (allTimeAvg >= 2.5) {
      moodText = "Okay";
      emoji = "Neutral";
    } else {
      moodText = "Needs Improvement";
      emoji = "Frowning";
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Weekly Summary',
            style: _poppins.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                  style: _poppins.copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Start logging your mood!'
                : 'Average Mood: ${allTimeAvg.toStringAsFixed(1)} / 5.0',
            style: _poppins.copyWith(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            'This Week: ${weeklyAvg.toStringAsFixed(1)}',
            style: _poppins.copyWith(fontSize: 14, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(int total) {
    if (total == 0) {
      return _buildGlassCard(
        title: 'Mood Distribution',
        color: const Color(0xFF8B5CF6),
        glowController: _glowControllers[1],
        glowAnimation: _glowAnimations[1],
        child: const Center(
          child: Text(
            'No mood entries yet',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return _buildGlassCard(
      title: 'Mood Distribution',
      color: const Color(0xFF8B5CF6),
      glowController: _glowControllers[1],
      glowAnimation: _glowAnimations[1],
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
                    style: _poppins.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'Total Entries',
                    style: _poppins.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
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

  Widget _buildLineChartCard() {
    return _buildGlassCard(
      title: 'Weekly Trend',
      color: const Color(0xFF10B981),
      glowController: _glowControllers[2],
      glowAnimation: _glowAnimations[2],
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: weeklyTrend.isEmpty
            ? const Center(
                child: Text(
                  'No data for this week',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              )
            : CustomPaint(
                painter: LineChartPainter(weeklyTrend),
                size: Size.infinite,
              ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    AnimationController glowController,
    Animation<double> glowAnimation,
  ) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9 - glowAnimation.value * 0.1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25 + glowAnimation.value * 0.3),
                blurRadius: 12 + glowAnimation.value * 12,
                spreadRadius: glowAnimation.value * 4,
                offset: const Offset(0, 3),
              ),
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(value, style: _poppins.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              Text(label, style: _poppins.copyWith(fontSize: 13, color: const Color(0xFF64748B)), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassCard({
    required String title,
    required Widget child,
    required Color color,
    required AnimationController glowController,
    required Animation<double> glowAnimation,
  }) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9 - glowAnimation.value * 0.2),
                Colors.white.withOpacity(0.7 - glowAnimation.value * 0.15),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25 + glowAnimation.value * 0.35),
                blurRadius: 16 + glowAnimation.value * 16,
                spreadRadius: glowAnimation.value * 6,
                offset: const Offset(0, 4),
              ),
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: _poppins.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  const Spacer(),
                  Icon(Icons.show_chart, color: color, size: 22),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        );
      },
    );
  }
}

// PieChartPainter and LineChartPainter remain unchanged...
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
      ..strokeWidth = 4
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
      final y = mood > 0
          ? 20 + (size.height - 40) - mood * dy
          : size.height - 20;
      points.add(Offset(x, y));
    }

    // Fill area
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paint);

    // Dots
    for (final p in points) {
      canvas.drawCircle(p, 7, Paint()..color = const Color(0xFF10B981));
      canvas.drawCircle(p, 4, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}