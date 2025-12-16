import 'package:flutter/material.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/models/workout_plan_model.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/models/fitness_profile_model.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/data/workout_plan_generator.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/screens/workout_day_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutPlanScreen extends StatefulWidget {
  final FitnessProfileModel profile;

  const WorkoutPlanScreen({
    super.key,
    required this.profile,
  });

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  late WorkoutPlanModel _workoutPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateWorkoutPlan();
  }

  void _generateWorkoutPlan() {
    setState(() {
      _isLoading = true;
    });

    // Simulate plan generation delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _workoutPlan = WorkoutPlanGenerator.generateWorkoutPlan(widget.profile);
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('خطة التمارين'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateWorkoutPlan,
            tooltip: 'إعادة توليد الخطة',
          ),
        ],
      ),
      body: _isLoading
        ? _buildLoadingView(isDark)
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Header Card
                _buildPlanHeaderCard(isDark),
                
                const SizedBox(height: 24),
                
                // Plan Stats
                _buildPlanStats(isDark),
                
                const SizedBox(height: 24),
                
                // Profile Summary
                _buildProfileSummary(isDark),
                
                const SizedBox(height: 32),
                
                // Workout Days Section
                Text(
                  'أيام التمرين',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F1120),
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Workout Days List
                ..._workoutPlan.workoutDays.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildWorkoutDayCard(day, index, isDark),
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Tips Card
                _buildTipsCard(isDark),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00177E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00177E)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري إعداد خطتك التدريبية...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F1120),
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سنقوم بإنشاء برنامج مخصص يناسب احتياجاتك',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeaderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [const Color(0xFF2D1B69), const Color(0xFF6B46C1)]
            : [const Color(0xFF00177E), const Color(0xFF1B1E36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF6B46C1) : const Color(0xFF00177E))
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _workoutPlan.planName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_workoutPlan.daysPerWeek} أيام في الأسبوع',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderStat(
                  'الهدف',
                  _workoutPlan.goalDisplayName,
                  Icons.flag,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                ),
                _buildHeaderStat(
                  'المستوى',
                  _workoutPlan.levelDisplayName,
                  Icons.trending_up,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanStats(bool isDark) {
    final stats = WorkoutPlanGenerator.calculatePlanStats(_workoutPlan);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'إجمالي التمارين',
            stats['total_exercises'].toString(),
            Icons.fitness_center,
            const Color(0xFF3B82F6),
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'مجموعات',
            stats['total_sets'].toString(),
            Icons.repeat,
            const Color(0xFF10B981),
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'سعرات/يوم',
            '~${stats['avg_calories_per_day']}',
            Icons.local_fire_department,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F1120),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص بياناتك',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F1120),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildProfileChip(
                'المعدات: ${widget.profile.equipmentDisplayName}',
                Icons.fitness_center,
                isDark,
              ),
              ...widget.profile.focusAreas.map((area) {
                final areaName = _getAreaDisplayName(area);
                return _buildProfileChip(
                  areaName,
                  Icons.circle,
                  isDark,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  String _getAreaDisplayName(String area) {
    switch (area) {
      case 'chest': return 'صدر';
      case 'shoulders': return 'أكتاف';
      case 'back': return 'ظهر';
      case 'arms': return 'ذراعين';
      case 'abs': return 'بطن';
      case 'legs': return 'أرجل';
      case 'glutes': return 'مؤخرة';
      default: return area;
    }
  }

  Widget _buildProfileChip(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00177E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00177E).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF00177E),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF00177E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutDayCard(WorkoutDayPlan day, int index, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDayScreen(
              workoutDay: day,
              dayNumber: index + 1,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00177E),
                          const Color(0xFF00177E).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.dayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F1120),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.focus,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF00177E),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: isDark ? Colors.white12 : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDayStatItem(
                    Icons.fitness_center,
                    '${day.exercises.length}',
                    'تمارين',
                    isDark,
                  ),
                  _buildDayStatItem(
                    Icons.timer,
                    '~${day.estimatedDuration}',
                    'دقيقة',
                    isDark,
                  ),
                  _buildDayStatItem(
                    Icons.local_fire_department,
                    '~${day.estimatedCalories}',
                    'سعرة',
                    isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayStatItem(
    IconData icon,
    String value,
    String label,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: const Color(0xFF00177E),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F1120),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'نصائح مهمة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F1120),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('استرح يوم واحد على الأقل بين كل تمرين', isDark),
          _buildTipItem('اشرب كمية كافية من الماء قبل وبعد التمرين', isDark),
          _buildTipItem('احرص على تنفيذ التمارين بالشكل الصحيح', isDark),
          _buildTipItem('يمكنك تعديل الأوزان والتكرارات حسب قدرتك', isDark),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Color(0xFF3B82F6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF1E3A8A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}