class ExerciseModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String description;
  final List<String> targetMuscles; // chest, shoulders, back, arms, abs, legs, glutes
  final String equipment; // full_gym, basic_equipment, no_equipment
  final String difficulty; // beginner, intermediate, advanced
  final List<String> goals; // muscle_gain, weight_loss, maintain_fitness
  final int sets;
  final String reps; // "10-12" or "30 seconds" or "AMRAP"
  final int restSeconds;
  final int caloriesPerSet;
  final String? videoUrl;
  final String? imageUrl;
  final List<String> instructions;
  final List<String> tips;

  ExerciseModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.description,
    required this.targetMuscles,
    required this.equipment,
    required this.difficulty,
    required this.goals,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.caloriesPerSet,
    this.videoUrl,
    this.imageUrl,
    required this.instructions,
    required this.tips,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description': description,
      'target_muscles': targetMuscles,
      'equipment': equipment,
      'difficulty': difficulty,
      'goals': goals,
      'sets': sets,
      'reps': reps,
      'rest_seconds': restSeconds,
      'calories_per_set': caloriesPerSet,
      'video_url': videoUrl,
      'image_url': imageUrl,
      'instructions': instructions,
      'tips': tips,
    };
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      description: json['description'] ?? '',
      targetMuscles: List<String>.from(json['target_muscles'] ?? []),
      equipment: json['equipment'] ?? '',
      difficulty: json['difficulty'] ?? '',
      goals: List<String>.from(json['goals'] ?? []),
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? '10-12',
      restSeconds: json['rest_seconds'] ?? 60,
      caloriesPerSet: json['calories_per_set'] ?? 10,
      videoUrl: json['video_url'],
      imageUrl: json['image_url'],
      instructions: List<String>.from(json['instructions'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
    );
  }

  String get musclesDisplayName {
    return targetMuscles.map((muscle) {
      switch (muscle) {
        case 'chest': return 'صدر';
        case 'shoulders': return 'أكتاف';
        case 'back': return 'ظهر';
        case 'arms': return 'ذراعين';
        case 'abs': return 'بطن';
        case 'legs': return 'أرجل';
        case 'glutes': return 'مؤخرة';
        default: return muscle;
      }
    }).join(' • ');
  }

  String get difficultyDisplayName {
    switch (difficulty) {
      case 'beginner': return 'مبتدئ';
      case 'intermediate': return 'متوسط';
      case 'advanced': return 'متقدم';
      default: return difficulty;
    }
  }

  int get totalCalories => caloriesPerSet * sets;
}