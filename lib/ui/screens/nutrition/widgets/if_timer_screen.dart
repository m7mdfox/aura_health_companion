// ============================================================================
// lib/ui/screens/nutrition/widgets/if_timer_screen.dart (DARK MODE ADDED)
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class IFTimerScreen extends StatefulWidget {
  const IFTimerScreen({super.key});

  @override
  State<IFTimerScreen> createState() => _IFTimerScreenState();
}

class _IFTimerScreenState extends State<IFTimerScreen> {
  bool _isFasting = false;
  DateTime? _fastingStartTime;
  Duration _fastingDuration = const Duration(hours: 16);
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String _selectedPlan = '16:8';

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final isFasting = prefs.getBool('if_is_fasting') ?? false;
    final startTimeStr = prefs.getString('if_start_time');
    final plan = prefs.getString('if_plan') ?? '16:8';

    if (isFasting && startTimeStr != null) {
      final startTime = DateTime.parse(startTimeStr);
      setState(() {
        _isFasting = true;
        _fastingStartTime = startTime;
        _selectedPlan = plan;
        _fastingDuration = _getDurationFromPlan(plan);
        _elapsed = DateTime.now().difference(startTime);
      });
      _startTimer();
    } else {
      setState(() {
        _selectedPlan = plan;
        _fastingDuration = _getDurationFromPlan(plan);
      });
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('if_is_fasting', _isFasting);
    if (_fastingStartTime != null) {
      await prefs.setString('if_start_time', _fastingStartTime!.toIso8601String());
    } else {
      await prefs.remove('if_start_time');
    }
    await prefs.setString('if_plan', _selectedPlan);
  }

  Duration _getDurationFromPlan(String plan) {
    switch (plan) {
      case '16:8':
        return const Duration(hours: 16);
      case '18:6':
        return const Duration(hours: 18);
      case '20:4':
        return const Duration(hours: 20);
      case 'OMAD':
        return const Duration(hours: 23);
      default:
        return const Duration(hours: 16);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_fastingStartTime != null) {
        setState(() {
          _elapsed = DateTime.now().difference(_fastingStartTime!);
        });

        if (_elapsed >= _fastingDuration) {
          _completeFasting();
        }
      }
    });
  }

  void _startFasting() {
    setState(() {
      _isFasting = true;
      _fastingStartTime = DateTime.now();
      _elapsed = Duration.zero;
    });
    _startTimer();
    _saveState();
    _showNotification('بدأ الصيام', 'حظاً موفقاً! 💪');
  }

  void _stopFasting() {
    setState(() {
      _isFasting = false;
      _fastingStartTime = null;
      _elapsed = Duration.zero;
    });
    _timer?.cancel();
    _saveState();
    _showNotification('توقف الصيام', 'تم إيقاف العداد');
  }

  void _completeFasting() {
    _timer?.cancel();
    setState(() {
      _isFasting = false;
      _fastingStartTime = null;
      _elapsed = Duration.zero;
    });
    _saveState();
    _showNotification('🎉 مبروك!', 'أكملت فترة الصيام بنجاح');
  }

  void _showNotification(String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(message, style: GoogleFonts.cairo()),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _elapsed.inSeconds / _fastingDuration.inSeconds;
    final remainingDuration = _fastingDuration - _elapsed;
    final isComplete = progress >= 1.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPlanSelector(isDark),
          const SizedBox(height: 24),
          _buildTimerCard(progress, remainingDuration, isComplete, isDark),
          const SizedBox(height: 24),
          _buildControlButtons(isDark),
          const SizedBox(height: 24),
          _buildPhaseIndicator(progress, isDark),
          const SizedBox(height: 24),
          _buildWeeklyProgress(isDark),
        ],
      ),
    );
  }

  Widget _buildPlanSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: isDark ? const Color(0xFFBB86FC) : Colors.purple.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'خطة الصيام',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['16:8', '18:6', '20:4', 'OMAD'].map((plan) {
              final isSelected = _selectedPlan == plan;
              return ChoiceChip(
                label: Text(
                  plan,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0D1B4C)),
                  ),
                ),
                selected: isSelected,
                onSelected: !_isFasting
                    ? (selected) {
                        setState(() {
                          _selectedPlan = plan;
                          _fastingDuration = _getDurationFromPlan(plan);
                        });
                        _saveState();
                      }
                    : null,
                selectedColor: isDark ? const Color(0xFFBB86FC) : Colors.purple.shade600,
                backgroundColor: isDark ? const Color(0xFF252838) : Colors.grey.shade100,
                elevation: isSelected ? 4 : 0,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(double progress, Duration remaining, bool isComplete, bool isDark) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFFBB86FC), const Color(0xFF9C6FDB)]
              : [Colors.purple.shade700, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFFBB86FC) : Colors.purple).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _isFasting ? 'جاري الصيام' : 'جاهز للبدء',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _isFasting ? progress.clamp(0.0, 1.0) : 0.0,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(
                    isComplete ? Colors.green.shade300 : Colors.white,
                  ),
                ),
              ),
              Column(
                children: [
                  if (_isFasting && !isComplete) ...[
                    Text(
                      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: GoogleFonts.mulish(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'متبقي',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ] else if (isComplete) ...[
                    const Icon(Icons.check_circle, color: Colors.white, size: 60),
                    const SizedBox(height: 8),
                    Text(
                      'مكتمل!',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 60),
                    const SizedBox(height: 8),
                    Text(
                      _selectedPlan,
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isFasting
                  ? 'بدأت في ${_formatTime(_fastingStartTime!)}'
                  : 'اختر وقت البدء',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(bool isDark) {
    return Row(
      children: [
        if (_isFasting) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _stopFasting,
              icon: const Icon(Icons.stop),
              label: Text('إيقاف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _startFasting,
              icon: const Icon(Icons.play_arrow),
              label: Text('بدء الصيام', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhaseIndicator(double progress, bool isDark) {
    String phase;
    Color phaseColor;
    IconData phaseIcon;

    if (progress < 0.25) {
      phase = 'بداية الصيام';
      phaseColor = isDark ? const Color(0xFF64B5F6) : Colors.blue.shade600;
      phaseIcon = Icons.wb_twilight;
    } else if (progress < 0.5) {
      phase = 'حرق السكر';
      phaseColor = isDark ? const Color(0xFFFFB74D) : Colors.orange.shade600;
      phaseIcon = Icons.local_fire_department;
    } else if (progress < 0.75) {
      phase = 'حرق الدهون';
      phaseColor = isDark ? const Color(0xFFEF5350) : Colors.red.shade600;
      phaseIcon = Icons.whatshot;
    } else {
      phase = 'مرحلة متقدمة';
      phaseColor = isDark ? const Color(0xFFBB86FC) : Colors.purple.shade600;
      phaseIcon = Icons.rocket_launch;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(phaseIcon, color: phaseColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المرحلة الحالية',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      phase,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPhaseTimeline(progress, isDark),
        ],
      ),
    );
  }

  Widget _buildPhaseTimeline(double progress, bool isDark) {
    return Row(
      children: [
        _buildPhaseStep('بداية', progress > 0, progress >= 0.25, isDark),
        _buildPhaseConnection(progress >= 0.25, isDark),
        _buildPhaseStep('سكر', progress >= 0.25, progress >= 0.5, isDark),
        _buildPhaseConnection(progress >= 0.5, isDark),
        _buildPhaseStep('دهون', progress >= 0.5, progress >= 0.75, isDark),
        _buildPhaseConnection(progress >= 0.75, isDark),
        _buildPhaseStep('متقدم', progress >= 0.75, progress >= 1.0, isDark),
      ],
    );
  }

  Widget _buildPhaseStep(String label, bool isActive, bool isComplete, bool isDark) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isComplete
                ? Colors.green.shade500
                : isActive
                    ? (isDark ? const Color(0xFFBB86FC) : Colors.purple.shade600)
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isComplete ? Icons.check : Icons.circle,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10,
            color: isActive
                ? (isDark ? Colors.white : const Color(0xFF0D1B4C))
                : (isDark ? Colors.white60 : Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseConnection(bool isActive, bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive
            ? (isDark ? const Color(0xFFBB86FC) : Colors.purple.shade600)
            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
    );
  }

  Widget _buildWeeklyProgress(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: isDark ? const Color(0xFF64B5F6) : Colors.blue.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'الأسبوع الحالي',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final day = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'][index];
              final isCompleted = index < 3;
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.shade500
                          : (isDark ? const Color(0xFF252838) : Colors.grey.shade200),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        day,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.white
                              : (isDark ? Colors.white60 : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(height: 4),
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}