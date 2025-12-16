import 'package:aura_health_companion/ui/screens/fitness_coach/models/exercise_model.dart';

class WorkoutDayPlan {
  final String dayName; // "اليوم الأول", "اليوم الثاني", etc
  final String focus; // "صدر وترايسبس", "ظهر وبايسبس", etc
  final List<ExerciseModel> exercises;
  final int estimatedDuration; // minutes
  final int estimatedCalories;

  WorkoutDayPlan({
    required this.dayName,
    required this.focus,
    required this.exercises,
    required this.estimatedDuration,
    required this.estimatedCalories,
  });

  Map<String, dynamic> toJson() {
    return {
      'day_name': dayName,
      'focus': focus,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'estimated_duration': estimatedDuration,
      'estimated_calories': estimatedCalories,
    };
  }

  factory WorkoutDayPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutDayPlan(
      dayName: json['day_name'] ?? '',
      focus: json['focus'] ?? '',
      exercises: (json['exercises'] as List?)
          ?.map((e) => ExerciseModel.fromJson(e))
          .toList() ?? [],
      estimatedDuration: json['estimated_duration'] ?? 0,
      estimatedCalories: json['estimated_calories'] ?? 0,
    );
  }
}

class WorkoutPlanModel {
  final String id;
  final String userId;
  final String planName;
  final String goal; // muscle_gain, weight_loss, maintain_fitness
  final String fitnessLevel; // beginner, intermediate, advanced
  final String equipment; // full_gym, basic_equipment, no_equipment
  final List<String> focusAreas;
  final List<WorkoutDayPlan> workoutDays;
  final int daysPerWeek;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  WorkoutPlanModel({
    required this.id,
    required this.userId,
    required this.planName,
    required this.goal,
    required this.fitnessLevel,
    required this.equipment,
    required this.focusAreas,
    required this.workoutDays,
    required this.daysPerWeek,
    required this.createdAt,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_name': planName,
      'goal': goal,
      'fitness_level': fitnessLevel,
      'equipment': equipment,
      'focus_areas': focusAreas,
      'workout_days': workoutDays.map((d) => d.toJson()).toList(),
      'days_per_week': daysPerWeek,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      planName: json['plan_name'] ?? '',
      goal: json['goal'] ?? '',
      fitnessLevel: json['fitness_level'] ?? '',
      equipment: json['equipment'] ?? '',
      focusAreas: List<String>.from(json['focus_areas'] ?? []),
      workoutDays: (json['workout_days'] as List?)
          ?.map((d) => WorkoutDayPlan.fromJson(d))
          .toList() ?? [],
      daysPerWeek: json['days_per_week'] ?? 3,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
      lastUpdated: json['last_updated'] != null 
        ? DateTime.parse(json['last_updated'])
        : null,
    );
  }

  String get goalDisplayName {
    switch (goal) {
      case 'muscle_gain': return 'زيادة العضلات';
      case 'weight_loss': return 'فقدان الوزن';
      case 'maintain_fitness': return 'الحفاظ على اللياقة';
      default: return goal;
    }
  }

  String get levelDisplayName {
    switch (fitnessLevel) {
      case 'beginner': return 'مبتدئ';
      case 'intermediate': return 'متوسط';
      case 'advanced': return 'متقدم';
      default: return fitnessLevel;
    }
  }

  int get totalEstimatedDuration {
    return workoutDays.fold(0, (sum, day) => sum + day.estimatedDuration);
  }

  int get totalEstimatedCalories {
    return workoutDays.fold(0, (sum, day) => sum + day.estimatedCalories);
  }
}