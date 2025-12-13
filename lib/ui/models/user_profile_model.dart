class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final String? bloodType;
  final List<String> chronicDiseases;
  final DateTime joinDate;
  
  // Stats
  final int streakDays;
  final int totalPoints;
  final int completedChallenges;
  final double waterIntakeGoal;
  final int stepsGoal;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    this.bloodType,
    this.chronicDiseases = const [],
    required this.joinDate,
    this.streakDays = 0,
    this.totalPoints = 0,
    this.completedChallenges = 0,
    this.waterIntakeGoal = 2.5,
    this.stepsGoal = 10000,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numbers
    double safeParseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    int safeParseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Calculate age from birthdate
    int calculateAge(String? birthdate) {
      if (birthdate == null || birthdate.isEmpty) return 0;
      try {
        final birth = DateTime.parse(birthdate);
        final now = DateTime.now();
        int age = now.year - birth.year;
        if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
          age--;
        }
        return age;
      } catch (e) {
        print('Error calculating age: $e');
        return 0;
      }
    }

    // Parse chronic conditions
    List<String> parseChronicConditions(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Parse join date
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing date: $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    print('📦 Parsing profile JSON: $json');

    return UserProfileModel(
      id: json['_id']?.toString() ?? 
          json['auth_id']?.toString() ?? 
          '',
      
      name: json['full_name']?.toString() ?? 
            json['name']?.toString() ?? 
            'Unknown',
      
      email: json['email']?.toString() ?? '',
      
      phone: json['phone']?.toString(),
      
      avatarUrl: json['avatar_url']?.toString(),
      
      age: calculateAge(json['birthdate']?.toString()),
      
      gender: json['gender']?.toString() ?? 'other',
      
      weight: safeParseDouble(json['weight_kg'], 0.0),
      
      height: safeParseDouble(json['height_cm'], 0.0),
      
      bloodType: json['blood_type']?.toString(),
      
      chronicDiseases: parseChronicConditions(json['chronic_conditions']),
      
      joinDate: parseDate(json['created_at']),
      
      // Stats with safe defaults
      streakDays: safeParseInt(json['streakDays'], 0),
      totalPoints: safeParseInt(json['totalPoints'], 0),
      completedChallenges: safeParseInt(json['completedChallenges'], 0),
      waterIntakeGoal: safeParseDouble(json['waterIntakeGoal'], 2.5),
      stepsGoal: safeParseInt(json['stepsGoal'], 10000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'auth_id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'gender': gender,
      'weight_kg': weight,
      'height_cm': height,
      'blood_type': bloodType,
      'chronic_conditions': chronicDiseases,
      'created_at': joinDate.toIso8601String(),
      'streakDays': streakDays,
      'totalPoints': totalPoints,
      'completedChallenges': completedChallenges,
      'waterIntakeGoal': waterIntakeGoal,
      'stepsGoal': stepsGoal,
    };
  }

  /// Convert to update payload (only fields that can be updated)
  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': name,
      'phone': phone,
      'gender': gender,
      'weight_kg': weight,
      'height_cm': height,
      'blood_type': bloodType,
      'chronic_conditions': chronicDiseases,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? bloodType,
    List<String>? chronicDiseases,
    DateTime? joinDate,
    int? streakDays,
    int? totalPoints,
    int? completedChallenges,
    double? waterIntakeGoal,
    int? stepsGoal,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodType: bloodType ?? this.bloodType,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      joinDate: joinDate ?? this.joinDate,
      streakDays: streakDays ?? this.streakDays,
      totalPoints: totalPoints ?? this.totalPoints,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      waterIntakeGoal: waterIntakeGoal ?? this.waterIntakeGoal,
      stepsGoal: stepsGoal ?? this.stepsGoal,
    );
  }

  @override
  String toString() {
    return 'UserProfileModel(name: $name, email: $email, weight: $weight, height: $height, bmi: ${bmi.toStringAsFixed(1)})';
  }
}