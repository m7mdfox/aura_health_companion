import 'package:aura_health_companion/ui/screens/fitness_coach/models/exercise_model.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/models/fitness_profile_model.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/models/workout_plan_model.dart';
import 'package:aura_health_companion/ui/screens/fitness_coach/data/exercises_database.dart';

class WorkoutPlanGenerator {
  // توليد خطة تمارين مخصصة بناءً على البروفايل
  static WorkoutPlanModel generateWorkoutPlan(FitnessProfileModel profile) {
    // تحديد عدد أيام التمرين بناءً على المستوى
    int daysPerWeek = _getDaysPerWeek(profile.fitnessLevel);
    
    // فلترة التمارين المناسبة
    List<ExerciseModel> availableExercises = _filterExercises(
      profile.equipment,
      profile.goal,
      profile.fitnessLevel,
      profile.focusAreas,
    );
    
    // إنشاء أيام التمرين
    List<WorkoutDayPlan> workoutDays = _createWorkoutDays(
      daysPerWeek,
      availableExercises,
      profile.focusAreas,
      profile.goal,
      profile.fitnessLevel,
    );
    
    return WorkoutPlanModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '', // سيتم ملؤها من AuthService
      planName: _generatePlanName(profile.goal, profile.fitnessLevel),
      goal: profile.goal,
      fitnessLevel: profile.fitnessLevel,
      equipment: profile.equipment,
      focusAreas: profile.focusAreas,
      workoutDays: workoutDays,
      daysPerWeek: daysPerWeek,
      createdAt: DateTime.now(),
    );
  }

  // تحديد عدد أيام التمرين حسب المستوى
  static int _getDaysPerWeek(String fitnessLevel) {
    switch (fitnessLevel) {
      case 'beginner':
        return 3; // 3 أيام في الأسبوع للمبتدئين
      case 'intermediate':
        return 4; // 4 أيام للمتوسطين
      case 'advanced':
        return 5; // 5 أيام للمتقدمين
      default:
        return 3;
    }
  }

  // فلترة التمارين المناسبة
  static List<ExerciseModel> _filterExercises(
    String equipment,
    String goal,
    String fitnessLevel,
    List<String> focusAreas,
  ) {
    return ExercisesDatabase.allExercises.where((exercise) {
      // فلترة حسب المعدات
      bool equipmentMatch = exercise.equipment == equipment;
      
      // فلترة حسب الهدف
      bool goalMatch = exercise.goals.contains(goal);
      
      // فلترة حسب مستوى الصعوبة
      bool difficultyMatch = _isDifficultyAppropriate(
        exercise.difficulty,
        fitnessLevel,
      );
      
      // فلترة حسب مناطق التركيز
      bool focusMatch = exercise.targetMuscles.any(
        (muscle) => focusAreas.contains(muscle),
      );
      
      return equipmentMatch && goalMatch && difficultyMatch && focusMatch;
    }).toList();
  }

  // التحقق من مناسبة مستوى الصعوبة
  static bool _isDifficultyAppropriate(
    String exerciseDifficulty,
    String userLevel,
  ) {
    const difficultyLevels = {
      'beginner': 1,
      'intermediate': 2,
      'advanced': 3,
    };
    
    int exerciseLevel = difficultyLevels[exerciseDifficulty] ?? 1;
    int userLevelNum = difficultyLevels[userLevel] ?? 1;
    
    // يمكن للمستخدم أداء تمارين بنفس مستواه أو أقل
    // ويمكنه تجربة التمارين الأعلى بمستوى واحد
    return exerciseLevel <= userLevelNum + 1;
  }

  // إنشاء أيام التمرين
  static List<WorkoutDayPlan> _createWorkoutDays(
    int daysPerWeek,
    List<ExerciseModel> availableExercises,
    List<String> focusAreas,
    String goal,
    String fitnessLevel,
  ) {
    List<WorkoutDayPlan> days = [];
    
    // تقسيم التمارين حسب المجموعات العضلية
    if (daysPerWeek == 3) {
      // برنامج Full Body 3 أيام
      days = _createFullBodySplit(availableExercises, focusAreas);
    } else if (daysPerWeek == 4) {
      // برنامج Upper/Lower 4 أيام
      days = _createUpperLowerSplit(availableExercises, focusAreas);
    } else if (daysPerWeek == 5) {
      // برنامج Bro Split 5 أيام
      days = _createBroSplit(availableExercises, focusAreas);
    }
    
    return days;
  }

  // برنامج Full Body (3 أيام)
  static List<WorkoutDayPlan> _createFullBodySplit(
    List<ExerciseModel> exercises,
    List<String> focusAreas,
  ) {
    List<WorkoutDayPlan> days = [];
    
    for (int i = 0; i < 3; i++) {
      List<ExerciseModel> dayExercises = [];
      int totalDuration = 0;
      int totalCalories = 0;
      
      // اختيار تمارين متنوعة لكل مجموعة عضلية
      for (String area in focusAreas) {
        var areaExercises = exercises
            .where((e) => e.targetMuscles.contains(area))
            .toList();
        
        if (areaExercises.isNotEmpty) {
          // اختيار تمرين واحد أو اثنين لكل منطقة
          int count = (i == 0 || areaExercises.length <= 2) ? 1 : 2;
          for (int j = 0; j < count && j < areaExercises.length; j++) {
            var exercise = areaExercises[j];
            dayExercises.add(exercise);
            totalDuration += _calculateExerciseDuration(exercise);
            totalCalories += exercise.totalCalories;
          }
        }
      }
      
      // إضافة تمارين الكارديو للأيام 2 و 3
      if (i > 0) {
        var cardioExercises = exercises
            .where((e) => e.targetMuscles.contains('cardio'))
            .toList();
        if (cardioExercises.isNotEmpty) {
          dayExercises.add(cardioExercises.first);
          totalDuration += _calculateExerciseDuration(cardioExercises.first);
          totalCalories += cardioExercises.first.totalCalories;
        }
      }
      
      days.add(WorkoutDayPlan(
        dayName: 'اليوم ${_arabicNumber(i + 1)}',
        focus: 'تمرين الجسم كامل',
        exercises: dayExercises,
        estimatedDuration: totalDuration,
        estimatedCalories: totalCalories,
      ));
    }
    
    return days;
  }

  // برنامج Upper/Lower (4 أيام)
  static List<WorkoutDayPlan> _createUpperLowerSplit(
    List<ExerciseModel> exercises,
    List<String> focusAreas,
  ) {
    List<WorkoutDayPlan> days = [];
    
    // Upper Body muscles
    List<String> upperMuscles = ['chest', 'back', 'shoulders', 'arms'];
    // Lower Body muscles
    List<String> lowerMuscles = ['legs', 'glutes'];
    
    for (int i = 0; i < 4; i++) {
      bool isUpperDay = i % 2 == 0;
      List<String> targetMuscles = isUpperDay ? upperMuscles : lowerMuscles;
      
      List<ExerciseModel> dayExercises = [];
      int totalDuration = 0;
      int totalCalories = 0;
      
      for (String muscle in targetMuscles) {
        if (focusAreas.contains(muscle)) {
          var muscleExercises = exercises
              .where((e) => e.targetMuscles.contains(muscle))
              .toList();
          
          if (muscleExercises.isNotEmpty) {
            // اختيار 2-3 تمارين لكل مجموعة
            int count = muscleExercises.length > 3 ? 2 : 1;
            for (int j = 0; j < count && j < muscleExercises.length; j++) {
              var exercise = muscleExercises[j];
              dayExercises.add(exercise);
              totalDuration += _calculateExerciseDuration(exercise);
              totalCalories += exercise.totalCalories;
            }
          }
        }
      }
      
      days.add(WorkoutDayPlan(
        dayName: 'اليوم ${_arabicNumber(i + 1)}',
        focus: isUpperDay ? 'الجزء العلوي' : 'الجزء السفلي',
        exercises: dayExercises,
        estimatedDuration: totalDuration,
        estimatedCalories: totalCalories,
      ));
    }
    
    return days;
  }

  // برنامج Bro Split (5 أيام)
  static List<WorkoutDayPlan> _createBroSplit(
    List<ExerciseModel> exercises,
    List<String> focusAreas,
  ) {
    List<WorkoutDayPlan> days = [];
    
    // تقسيم كلاسيكي: صدر، ظهر، أرجل، أكتاف، ذراعين
    List<Map<String, dynamic>> splits = [
      {'name': 'صدر', 'muscles': ['chest']},
      {'name': 'ظهر', 'muscles': ['back']},
      {'name': 'أرجل ومؤخرة', 'muscles': ['legs', 'glutes']},
      {'name': 'أكتاف', 'muscles': ['shoulders']},
      {'name': 'ذراعين', 'muscles': ['arms']},
    ];
    
    int dayCount = 0;
    for (var split in splits) {
      List<String> targetMuscles = List<String>.from(split['muscles']);
      
      // تحقق إذا كان المستخدم يريد التركيز على هذه المجموعة
      bool hasFocus = targetMuscles.any((m) => focusAreas.contains(m));
      if (!hasFocus) continue;
      
      List<ExerciseModel> dayExercises = [];
      int totalDuration = 0;
      int totalCalories = 0;
      
      for (String muscle in targetMuscles) {
        var muscleExercises = exercises
            .where((e) => e.targetMuscles.contains(muscle))
            .toList();
        
        if (muscleExercises.isNotEmpty) {
          // اختيار 3-4 تمارين لكل مجموعة
          int count = muscleExercises.length > 4 ? 4 : muscleExercises.length;
          for (int j = 0; j < count; j++) {
            var exercise = muscleExercises[j];
            dayExercises.add(exercise);
            totalDuration += _calculateExerciseDuration(exercise);
            totalCalories += exercise.totalCalories;
          }
        }
      }
      
      if (dayExercises.isNotEmpty) {
        dayCount++;
        days.add(WorkoutDayPlan(
          dayName: 'اليوم ${_arabicNumber(dayCount)}',
          focus: split['name'],
          exercises: dayExercises,
          estimatedDuration: totalDuration,
          estimatedCalories: totalCalories,
        ));
      }
    }
    
    return days;
  }

  // حساب مدة التمرين (بالدقائق)
  static int _calculateExerciseDuration(ExerciseModel exercise) {
    // كل مجموعة تأخذ حوالي دقيقة، + وقت الراحة
    int setDuration = 60; // ثانية
    int totalSeconds = (setDuration + exercise.restSeconds) * exercise.sets;
    return (totalSeconds / 60).ceil();
  }

  // تحويل الأرقام للعربية
  static String _arabicNumber(int number) {
    const arabicNumbers = {
      1: 'الأول',
      2: 'الثاني',
      3: 'الثالث',
      4: 'الرابع',
      5: 'الخامس',
      6: 'السادس',
      7: 'السابع',
    };
    return arabicNumbers[number] ?? number.toString();
  }

  // توليد اسم الخطة
  static String _generatePlanName(String goal, String fitnessLevel) {
    String goalName = '';
    switch (goal) {
      case 'muscle_gain':
        goalName = 'بناء العضلات';
        break;
      case 'weight_loss':
        goalName = 'خسارة الوزن';
        break;
      case 'maintain_fitness':
        goalName = 'الحفاظ على اللياقة';
        break;
      default:
        goalName = 'تحسين اللياقة';
    }
    
    String levelName = '';
    switch (fitnessLevel) {
      case 'beginner':
        levelName = 'مبتدئ';
        break;
      case 'intermediate':
        levelName = 'متوسط';
        break;
      case 'advanced':
        levelName = 'متقدم';
        break;
      default:
        levelName = '';
    }
    
    return 'خطة $goalName - $levelName';
  }

  // تحديث خطة موجودة (للتطور والتقدم)
  static WorkoutPlanModel progressWorkoutPlan(
    WorkoutPlanModel currentPlan,
    FitnessProfileModel profile,
  ) {
    // زيادة الصعوبة تدريجياً
    List<WorkoutDayPlan> updatedDays = currentPlan.workoutDays.map((day) {
      List<ExerciseModel> updatedExercises = day.exercises.map((exercise) {
        // زيادة العدات أو المجموعات
        int newSets = exercise.sets;
        String newReps = exercise.reps;
        
        // زيادة تدريجية
        if (exercise.reps.contains('-')) {
          var parts = exercise.reps.split('-');
          int maxReps = int.tryParse(parts[1]) ?? 12;
          newReps = '${maxReps - 2}-${maxReps + 2}';
        }
        
        if (newSets < 5) {
          newSets += 1;
        }
        
        return ExerciseModel(
          id: exercise.id,
          nameAr: exercise.nameAr,
          nameEn: exercise.nameEn,
          description: exercise.description,
          targetMuscles: exercise.targetMuscles,
          equipment: exercise.equipment,
          difficulty: exercise.difficulty,
          goals: exercise.goals,
          sets: newSets,
          reps: newReps,
          restSeconds: exercise.restSeconds,
          caloriesPerSet: exercise.caloriesPerSet,
          videoUrl: exercise.videoUrl,
          imageUrl: exercise.imageUrl,
          instructions: exercise.instructions,
          tips: exercise.tips,
        );
      }).toList();
      
      return WorkoutDayPlan(
        dayName: day.dayName,
        focus: day.focus,
        exercises: updatedExercises,
        estimatedDuration: day.estimatedDuration,
        estimatedCalories: day.estimatedCalories,
      );
    }).toList();
    
    return WorkoutPlanModel(
      id: currentPlan.id,
      userId: currentPlan.userId,
      planName: currentPlan.planName,
      goal: currentPlan.goal,
      fitnessLevel: currentPlan.fitnessLevel,
      equipment: currentPlan.equipment,
      focusAreas: currentPlan.focusAreas,
      workoutDays: updatedDays,
      daysPerWeek: currentPlan.daysPerWeek,
      createdAt: currentPlan.createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  // الحصول على تمارين بديلة
  static List<ExerciseModel> getAlternativeExercises(
    ExerciseModel exercise,
    String equipment,
  ) {
    return ExercisesDatabase.allExercises.where((e) {
      bool sameEquipment = e.equipment == equipment;
      bool sameMuscles = e.targetMuscles.any(
        (m) => exercise.targetMuscles.contains(m),
      );
      bool differentExercise = e.id != exercise.id;
      
      return sameEquipment && sameMuscles && differentExercise;
    }).toList();
  }

  // حساب إحصائيات الخطة
  static Map<String, dynamic> calculatePlanStats(WorkoutPlanModel plan) {
    int totalExercises = 0;
    int totalSets = 0;
    int totalDuration = 0;
    int totalCalories = 0;
    
    for (var day in plan.workoutDays) {
      totalExercises += day.exercises.length;
      totalDuration += day.estimatedDuration;
      totalCalories += day.estimatedCalories;
      
      for (var exercise in day.exercises) {
        totalSets += exercise.sets;
      }
    }
    
    return {
      'total_exercises': totalExercises,
      'total_sets': totalSets,
      'total_duration': totalDuration,
      'total_calories': totalCalories,
      'avg_duration_per_day': (totalDuration / plan.workoutDays.length).round(),
      'avg_calories_per_day': (totalCalories / plan.workoutDays.length).round(),
    };
  }
}