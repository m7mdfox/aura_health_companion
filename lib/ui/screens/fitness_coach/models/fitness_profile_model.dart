class FitnessProfileModel {
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String goal;
  final List<String> focusAreas;
  final String fitnessLevel;
  final String equipment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FitnessProfileModel({
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.goal,
    required this.focusAreas,
    required this.fitnessLevel,
    required this.equipment,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'goal': goal,
      'focus_areas': focusAreas,
      'fitness_level': fitnessLevel,
      'equipment': equipment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON response
  factory FitnessProfileModel.fromJson(Map<String, dynamic> json) {
    return FitnessProfileModel(
      age: json['age'] ?? 0,
      weight: (json['weight'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      gender: json['gender'] ?? 'male',
      goal: json['goal'] ?? '',
      focusAreas: List<String>.from(json['focus_areas'] ?? []),
      fitnessLevel: json['fitness_level'] ?? '',
      equipment: json['equipment'] ?? '',
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at'])
        : null,
    );
  }

  // Create a copy with updated fields
  FitnessProfileModel copyWith({
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? goal,
    List<String>? focusAreas,
    String? fitnessLevel,
    String? equipment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FitnessProfileModel(
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      focusAreas: focusAreas ?? this.focusAreas,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      equipment: equipment ?? this.equipment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate BMI
  double get bmi {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'نحيف';
    if (bmiValue < 25) return 'طبيعي';
    if (bmiValue < 30) return 'وزن زائد';
    return 'سمنة';
  }

  // Get goal display name in Arabic
  String get goalDisplayName {
    switch (goal) {
      case 'muscle_gain':
        return 'زيادة العضلات';
      case 'weight_loss':
        return 'فقدان الوزن';
      case 'maintain_fitness':
        return 'الحفاظ على اللياقة';
      case 'increase_endurance':
        return 'زيادة القدرة على التحمل';
      case 'flexibility':
        return 'زيادة المرونة';
      case 'general_health':
        return 'تحسين الصحة العامة';
      default:
        return goal;
    }
  }

  // Get fitness level display name in Arabic
  String get fitnessLevelDisplayName {
    switch (fitnessLevel) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      default:
        return fitnessLevel;
    }
  }

  // Get equipment display name in Arabic
  String get equipmentDisplayName {
    switch (equipment) {
      case 'full_gym':
        return 'جميع المعدات';
      case 'basic_equipment':
        return 'معدات أساسية';
      case 'no_equipment':
        return 'بدون معدات';
      default:
        return equipment;
    }
  }

  @override
  String toString() {
    return 'FitnessProfileModel(age: $age, weight: $weight, height: $height, '
        'gender: $gender, goal: $goal, focusAreas: $focusAreas, '
        'fitnessLevel: $fitnessLevel, equipment: $equipment)';
  }
}