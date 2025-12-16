import 'package:flutter/material.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/models/exercise_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTimerRunning = false;
  int _currentSet = 1;
  int _restTimeRemaining = 0;
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    setState(() {
      _isTimerRunning = true;
      _restTimeRemaining = widget.exercise.restSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTimeRemaining > 0) {
        setState(() {
          _restTimeRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerRunning = false;
          if (_currentSet < widget.exercise.sets) {
            _currentSet++;
          }
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
        title: Text(widget.exercise.nameAr),
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
      ),
      body: Column(
        children: [
          // Exercise Header
          _buildExerciseHeader(isDark),
          
          // Tabs
          Container(
            color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00177E),
              unselectedLabelColor: isDark ? Colors.white60 : Colors.grey,
              indicatorColor: const Color(0xFF00177E),
              tabs: const [
                Tab(text: 'التعليمات'),
                Tab(text: 'التفاصيل'),
                Tab(text: 'نصائح'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInstructionsTab(isDark),
                _buildDetailsTab(isDark),
                _buildTipsTab(isDark),
              ],
            ),
          ),
          
          // Bottom Action Area
          _buildBottomActionArea(isDark),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Exercise Image Placeholder
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: isDark 
                ? const Color(0xFF0F1120) 
                : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                Icons.fitness_center,
                size: 80,
                color: isDark ? Colors.white24 : Colors.grey[400],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Exercise Name
          Text(
            widget.exercise.nameAr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F1120),
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.exercise.nameEn,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Exercise Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBadge(
                '${widget.exercise.sets} مجموعات',
                Icons.repeat,
                const Color(0xFF3B82F6),
                isDark,
              ),
              _buildStatBadge(
                widget.exercise.reps,
                Icons.fitness_center,
                const Color(0xFF10B981),
                isDark,
              ),
              _buildStatBadge(
                '${widget.exercise.restSeconds}ث راحة',
                Icons.timer,
                const Color(0xFFF59E0B),
                isDark,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Muscles & Difficulty
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(widget.exercise.difficulty)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getDifficultyColor(widget.exercise.difficulty)
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.exercise.difficultyDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getDifficultyColor(widget.exercise.difficulty),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00177E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00177E).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.exercise.musclesDisplayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00177E),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String text, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return const Color(0xFF10B981);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'advanced':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Widget _buildInstructionsTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.exercise.instructions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exercise.description,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'خطوات التنفيذ:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F1120),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
        
        final instruction = widget.exercise.instructions[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF00177E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  instruction,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDetailCard(
          'السعرات الحرارية',
          '${widget.exercise.totalCalories} سعرة',
          Icons.local_fire_department,
          Colors.orange,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          'العضلات المستهدفة',
          widget.exercise.musclesDisplayName,
          Icons.accessibility_new,
          const Color(0xFF3B82F6),
          isDark,
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          'المعدات المطلوبة',
          _getEquipmentName(widget.exercise.equipment),
          Icons.fitness_center,
          const Color(0xFF10B981),
          isDark,
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          'المستوى',
          widget.exercise.difficultyDisplayName,
          Icons.signal_cellular_alt,
          _getDifficultyColor(widget.exercise.difficulty),
          isDark,
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          'الأهداف',
          widget.exercise.goals.map(_getGoalName).join(' • '),
          Icons.flag,
          const Color(0xFFF59E0B),
          isDark,
        ),
      ],
    );
  }

  String _getEquipmentName(String equipment) {
    switch (equipment) {
      case 'full_gym': return 'جميع المعدات';
      case 'basic_equipment': return 'معدات أساسية';
      case 'no_equipment': return 'بدون معدات';
      default: return equipment;
    }
  }

  String _getGoalName(String goal) {
    switch (goal) {
      case 'muscle_gain': return 'زيادة العضلات';
      case 'weight_loss': return 'فقدان الوزن';
      case 'maintain_fitness': return 'الحفاظ على اللياقة';
      case 'increase_endurance': return 'زيادة التحمل';
      case 'flexibility': return 'مرونة';
      default: return goal;
    }
  }

  Widget _buildDetailCard(
    String title,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.exercise.tips.length,
      itemBuilder: (context, index) {
        final tip = widget.exercise.tips[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF065F46),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Set Counter & Rest Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Current Set
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00177E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'المجموعة',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_currentSet / ${widget.exercise.sets}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF00177E),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Rest Timer
              if (_isTimerRunning)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'راحة',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_restTimeRemaining ث',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              if (!_isTimerRunning && _currentSet <= widget.exercise.sets)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startRestTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('بدء الراحة'),
                  ),
                ),
              
              if (_isTimerRunning) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _restTimer?.cancel();
                      setState(() {
                        _isTimerRunning = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
              ],
              
              const SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentSet >= widget.exercise.sets
                    ? () => Navigator.pop(context, true)
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark 
                      ? Colors.white12 
                      : Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('إنهاء التمرين'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}