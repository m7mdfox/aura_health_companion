import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_health_companion/data/vital_simulator.dart';

class WatchDataScreen extends StatefulWidget {
  const WatchDataScreen({super.key});

  @override
  State<WatchDataScreen> createState() => _WatchDataScreenState();
}

class _WatchDataScreenState extends State<WatchDataScreen>
    with TickerProviderStateMixin {
  final VitalSimulator _simulator = VitalSimulator();
  StreamSubscription? _subscription;

  // Current values
  int _heartRate = 72;
  int _spo2 = 98;
  int _steps = 0;
  int _calories = 0;

  // Heart rate history for graph
  final List<int> _heartRateHistory = [];
  static const int _maxHistorySize = 20;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Initialize with some history
    for (int i = 0; i < 10; i++) {
      _heartRateHistory.add(70 + Random().nextInt(10));
    }

    _subscription = _simulator.simulateVitals().listen((data) {
      if (mounted) {
        setState(() {
          _heartRate = data['heartRate'] ?? 72;
          _spo2 = data['spo2'] ?? 98;
          _steps = data['steps'] ?? 0;
          _calories = data['caloriesBurnt'] ?? 0;

          // Add to history
          _heartRateHistory.add(_heartRate);
          if (_heartRateHistory.length > _maxHistorySize) {
            _heartRateHistory.removeAt(0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    _simulator.dispose();
    super.dispose();
  }

  String _getHeartRateStatus() {
    if (_heartRate < 60) return 'Low';
    if (_heartRate > 100) return 'High';
    return 'Normal';
  }

  Color _getHeartRateColor() {
    if (_heartRate < 60) return const Color(0xFF3B82F6);
    if (_heartRate > 100) return const Color(0xFFEF4444);
    return const Color(0xFF10B981);
  }

  String _getHealthInsight() {
    if (_heartRate > 100) {
      return "💓 Your heart rate is elevated. Consider taking a few deep breaths and relaxing.";
    } else if (_heartRate < 60) {
      return "💙 Your heart rate is lower than usual. This is normal if you're resting or athletic.";
    } else if (_spo2 < 95) {
      return "🫁 Your blood oxygen is slightly low. Try some deep breathing exercises.";
    } else if (_steps > 8000) {
      return "🏆 Amazing! You've exceeded 8,000 steps today. Keep up the great work!";
    } else if (_steps > 5000) {
      return "🚶 Great progress! You're more than halfway to your 10,000 step goal.";
    } else {
      return "✨ Your vitals look healthy! Keep moving and staying active.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Heart Rate Display
                    _buildHeartRateCard(isDark),
                    const SizedBox(height: 16),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                          icon: Icons.local_fire_department,
                          value: _calories.toString(),
                          label: 'Calories',
                          color: const Color(0xFFFF6B6B),
                          isDark: isDark,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildStatCard(
                          icon: Icons.water_drop,
                          value: '$_spo2%',
                          label: 'SpO2',
                          color: const Color(0xFF00B4DB),
                          isDark: isDark,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Steps Card
                    _buildStepsCard(isDark),
                    const SizedBox(height: 16),

                    // Heart Rate Graph
                    _buildHeartRateGraph(isDark),
                    const SizedBox(height: 16),

                    // AI Insight Card
                    _buildInsightCard(isDark),
                    const SizedBox(height: 16),

                    // Quick Stats
                    _buildQuickStats(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor:
          isDark ? const Color(0xFF1A1D2E) : const Color(0xFF00158B),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1D2E), const Color(0xFF3B82F6)]
                  : [const Color(0xFF00158B), const Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                right: -30,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.watch,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Watch Data',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Real-time health monitoring',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeartRateCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getHeartRateColor(), _getHeartRateColor().withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getHeartRateColor().withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Heart Icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.15),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          // Heart Rate Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heart Rate',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_heartRate',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'BPM',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getHeartRateStatus(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getHeartRateColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(bool isDark) {
    final progress = _steps / 10000; // Goal: 10,000 steps
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_walk,
                        color: Color(0xFF8B5CF6), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Steps',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$_steps',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress.clamp(0, 1),
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
                    ),
                    Text(
                      '$percentage%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${10000 - _steps > 0 ? 10000 - _steps : 0} steps to reach your goal',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateGraph(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Heart Rate Trend',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: HeartRateGraphPainter(
                data: _heartRateHistory,
                lineColor: const Color(0xFFEF4444),
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGraphStat(
                  'Min',
                  '${_heartRateHistory.isNotEmpty ? _heartRateHistory.reduce((a, b) => a < b ? a : b) : 0}',
                  isDark),
              _buildGraphStat(
                  'Avg',
                  '${_heartRateHistory.isNotEmpty ? (_heartRateHistory.reduce((a, b) => a + b) / _heartRateHistory.length).round() : 0}',
                  isDark),
              _buildGraphStat(
                  'Max',
                  '${_heartRateHistory.isNotEmpty ? _heartRateHistory.reduce((a, b) => a > b ? a : b) : 0}',
                  isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraphStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Color(0xFF6366F1), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Insight',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getHealthInsight(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Summary',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildQuickStatItem(Icons.timer, 'Active', '2h 15m',
                    const Color(0xFF10B981), isDark)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildQuickStatItem(
                    Icons.nightlight,
                    'Resting',
                    '${(_heartRateHistory.where((h) => h < 70).length / _heartRateHistory.length * 100).round()}%',
                    const Color(0xFF3B82F6),
                    isDark)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildQuickStatItem(
                    Icons.bolt,
                    'Peak',
                    '${_heartRateHistory.isNotEmpty ? _heartRateHistory.reduce((a, b) => a > b ? a : b) : 0} BPM',
                    const Color(0xFFF59E0B),
                    isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatItem(
      IconData icon, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for heart rate graph
class HeartRateGraphPainter extends CustomPainter {
  final List<int> data;
  final Color lineColor;
  final bool isDark;

  HeartRateGraphPainter({
    required this.data,
    required this.lineColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final minValue = data.reduce((a, b) => a < b ? a : b) - 10;
    final maxValue = data.reduce((a, b) => a > b ? a : b) + 10;
    final valueRange = maxValue - minValue;

    final path = Path();
    final gradientPath = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i] - minValue) / valueRange;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }

    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    canvas.drawPath(gradientPath, gradientPaint);
    canvas.drawPath(path, paint);

    // Draw current point
    if (data.isNotEmpty) {
      final lastX = (data.length - 1) * stepX;
      final lastY =
          size.height - ((data.last - minValue) / valueRange * size.height);
      canvas.drawCircle(
        Offset(lastX, lastY),
        6,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        Offset(lastX, lastY),
        3,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
