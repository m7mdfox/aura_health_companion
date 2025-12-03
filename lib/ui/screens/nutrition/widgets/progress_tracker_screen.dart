// lib/ui/screens/nutrition/widgets/progress_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aura_health_companion/data/auth_service.dart';

class ProgressTrackerScreen extends StatefulWidget {
  final int targetCalories;

  const ProgressTrackerScreen({
    super.key,
    required this.targetCalories,
  });

  @override
  State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  int _todayCalories = 0;
  int _todayWater = 0;
  double? _todayWeight;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/nutrition/progress-history?days=30'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _history = List<Map<String, dynamic>>.from(data['data'] ?? []);
          
          // Get today's data if exists
          final today = DateTime.now();
          final todayData = _history.firstWhere(
            (item) {
              final date = DateTime.parse(item['date']);
              return date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
            },
            orElse: () => {},
          );

          if (todayData.isNotEmpty) {
            _todayCalories = todayData['caloriesConsumed'] ?? 0;
            _todayWater = todayData['waterIntake'] ?? 0;
            _todayWeight = todayData['weight']?.toDouble();
          }
        });
      }
    } catch (e) {
      print('Error fetching history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logProgress() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _LogProgressDialog(
        currentCalories: _todayCalories,
        currentWater: _todayWater,
        currentWeight: _todayWeight,
      ),
    );

    if (result != null) {
      try {
        final response = await http.post(
          Uri.parse('${AuthService.baseUrl}/api/nutrition/log-progress'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          body: jsonEncode({
            'date': DateTime.now().toIso8601String(),
            'caloriesConsumed': result['calories'],
            'waterIntake': result['water'],
            'weight': result['weight'],
            'notes': result['notes'] ?? '',
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ التقدم', style: GoogleFonts.cairo()),
              backgroundColor: Colors.green,
            ),
          );
          _fetchHistory();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحفظ', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0D1B4C)),
      );
    }

    final caloriesPercent = (_todayCalories / widget.targetCalories).clamp(0.0, 1.0);
    final waterPercent = (_todayWater / 8).clamp(0.0, 1.0); // 8 glasses target

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayCard(caloriesPercent, waterPercent),
          const SizedBox(height: 24),
          _buildWeightProgress(),
          const SizedBox(height: 24),
          _buildCaloriesChart(),
          const SizedBox(height: 24),
          _buildAchievements(),
        ],
      ),
    );
  }

  Widget _buildTodayCard(double caloriesPercent, double waterPercent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D1B4C),
            const Color(0xFF1a2d6e),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B4C).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اليوم',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _logProgress,
                icon: const Icon(Icons.add, size: 18),
                label: Text('تسجيل', style: GoogleFonts.cairo(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0D1B4C),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildCircularProgress(
                  'السعرات',
                  _todayCalories,
                  widget.targetCalories,
                  caloriesPercent,
                  Icons.local_fire_department,
                  Colors.orange.shade400,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildCircularProgress(
                  'الماء',
                  _todayWater,
                  8,
                  waterPercent,
                  Icons.water_drop,
                  Colors.blue.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(
    String label,
    int current,
    int target,
    double percent,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 8,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Icon(icon, color: Colors.white, size: 32),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$current / $target',
          style: GoogleFonts.mulish(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightProgress() {
    if (_history.isEmpty) {
      return _buildEmptyCard('لا توجد بيانات للوزن');
    }

    final weights = _history
        .where((item) => item['weight'] != null)
        .map((item) => item['weight'].toDouble())
        .toList()
        .reversed
        .toList();

    if (weights.isEmpty) {
      return _buildEmptyCard('لا توجد بيانات للوزن');
    }

    final firstWeight = weights.first;
    final lastWeight = weights.last;
    final diff = lastWeight - firstWeight;
    final isLoss = diff < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.trending_down, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(
                'تطور الوزن',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeightStat('البداية', firstWeight, Icons.flag),
              _buildWeightStat('الحالي', lastWeight, Icons.person),
              _buildWeightStat(
                'الفرق',
                diff.abs(),
                isLoss ? Icons.arrow_downward : Icons.arrow_upward,
                color: isLoss ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStat(String label, double value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey.shade600, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)} كجم',
          style: GoogleFonts.mulish(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF0D1B4C),
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesChart() {
    if (_history.isEmpty) {
      return _buildEmptyCard('لا توجد بيانات للسعرات');
    }

    final last7Days = _history.take(7).toList().reversed.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                'السعرات الأسبوعية',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: last7Days.map((day) {
                final calories = day['caloriesConsumed'] ?? 0;
                final percent = (calories / widget.targetCalories).clamp(0.0, 1.0);
                final date = DateTime.parse(day['date']);
                final dayName = _getDayName(date.weekday);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      height: (120 * percent).toDouble(),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.orange.shade600,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayName,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              Text(
                'الإنجازات',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAchievementItem('🔥', 'أسبوع كامل من الالتزام', true),
          _buildAchievementItem('💪', 'خسارة 1 كجم', true),
          _buildAchievementItem('🎯', 'التزمت بـ 30 يوم', false),
          _buildAchievementItem('⭐', 'وصلت للوزن المثالي', false),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String emoji, String title, bool achieved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achieved ? Colors.amber.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achieved ? Colors.amber.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: achieved ? FontWeight.bold : FontWeight.normal,
                color: achieved ? const Color(0xFF0D1B4C) : Colors.grey.shade600,
              ),
            ),
          ),
          if (achieved)
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return days[weekday - 1];
  }
}

// ==================== LOG PROGRESS DIALOG ====================
class _LogProgressDialog extends StatefulWidget {
  final int currentCalories;
  final int currentWater;
  final double? currentWeight;

  const _LogProgressDialog({
    required this.currentCalories,
    required this.currentWater,
    this.currentWeight,
  });

  @override
  State<_LogProgressDialog> createState() => _LogProgressDialogState();
}

class _LogProgressDialogState extends State<_LogProgressDialog> {
  late TextEditingController _caloriesCtrl;
  late TextEditingController _waterCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _caloriesCtrl = TextEditingController(text: widget.currentCalories.toString());
    _waterCtrl = TextEditingController(text: widget.currentWater.toString());
    _weightCtrl = TextEditingController(
      text: widget.currentWeight?.toStringAsFixed(1) ?? '',
    );
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _caloriesCtrl.dispose();
    _waterCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تسجيل التقدم',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D1B4C),
              ),
            ),
            const SizedBox(height: 20),
            _buildField('السعرات المستهلكة', _caloriesCtrl, Icons.local_fire_department),
            const SizedBox(height: 12),
            _buildField('أكواب الماء', _waterCtrl, Icons.water_drop),
            const SizedBox(height: 12),
            _buildField('الوزن (كجم)', _weightCtrl, Icons.scale),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: 'ملاحظات',
                labelStyle: GoogleFonts.cairo(),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.cairo(),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('إلغاء', style: GoogleFonts.cairo()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'calories': int.tryParse(_caloriesCtrl.text) ?? 0,
                        'water': int.tryParse(_waterCtrl.text) ?? 0,
                        'weight': double.tryParse(_weightCtrl.text),
                        'notes': _notesCtrl.text,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B4C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('حفظ', style: GoogleFonts.cairo()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: GoogleFonts.mulish(fontWeight: FontWeight.w600),
    );
  }
}