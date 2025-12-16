class WorkoutPreferencesModel {
  final int workoutDaysPerWeek;
  final int workoutDurationMinutes;
  final String preferredTimeOfDay; // morning, afternoon, evening, night
  final List<String> preferredWorkoutTypes; // cardio, strength, flexibility, hiit
  final bool includeWarmup;
  final bool includeCooldown;
  final bool includeStretching;
  final String restDayPreference; // specific_days, flexible
  final List<int> restDays; // 1-7 (Monday-Sunday)
  final bool enableNotifications;
  final String notificationTime; // HH:mm format
  final bool trackProgress;
  final String difficultyProgression; // gradual, moderate, aggressive

  WorkoutPreferencesModel({
    this.workoutDaysPerWeek = 3,
    this.workoutDurationMinutes = 45,
    this.preferredTimeOfDay = 'morning',
    this.preferredWorkoutTypes = const ['strength', 'cardio'],
    this.includeWarmup = true,
    this.includeCooldown = true,
    this.includeStretching = true,
    this.restDayPreference = 'flexible',
    this.restDays = const [],
    this.enableNotifications = true,
    this.notificationTime = '07:00',
    this.trackProgress = true,
    this.difficultyProgression = 'gradual',
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'workout_days_per_week': workoutDaysPerWeek,
      'workout_duration_minutes': workoutDurationMinutes,
      'preferred_time_of_day': preferredTimeOfDay,
      'preferred_workout_types': preferredWorkoutTypes,
      'include_warmup': includeWarmup,
      'include_cooldown': includeCooldown,
      'include_stretching': includeStretching,
      'rest_day_preference': restDayPreference,
      'rest_days': restDays,
      'enable_notifications': enableNotifications,
      'notification_time': notificationTime,
      'track_progress': trackProgress,
      'difficulty_progression': difficultyProgression,
    };
  }

  // Create from JSON
  factory WorkoutPreferencesModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPreferencesModel(
      workoutDaysPerWeek: json['workout_days_per_week'] ?? 3,
      workoutDurationMinutes: json['workout_duration_minutes'] ?? 45,
      preferredTimeOfDay: json['preferred_time_of_day'] ?? 'morning',
      preferredWorkoutTypes: List<String>.from(
        json['preferred_workout_types'] ?? ['strength', 'cardio'],
      ),
      includeWarmup: json['include_warmup'] ?? true,
      includeCooldown: json['include_cooldown'] ?? true,
      includeStretching: json['include_stretching'] ?? true,
      restDayPreference: json['rest_day_preference'] ?? 'flexible',
      restDays: List<int>.from(json['rest_days'] ?? []),
      enableNotifications: json['enable_notifications'] ?? true,
      notificationTime: json['notification_time'] ?? '07:00',
      trackProgress: json['track_progress'] ?? true,
      difficultyProgression: json['difficulty_progression'] ?? 'gradual',
    );
  }

  // Copy with updated fields
  WorkoutPreferencesModel copyWith({
    int? workoutDaysPerWeek,
    int? workoutDurationMinutes,
    String? preferredTimeOfDay,
    List<String>? preferredWorkoutTypes,
    bool? includeWarmup,
    bool? includeCooldown,
    bool? includeStretching,
    String? restDayPreference,
    List<int>? restDays,
    bool? enableNotifications,
    String? notificationTime,
    bool? trackProgress,
    String? difficultyProgression,
  }) {
    return WorkoutPreferencesModel(
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      workoutDurationMinutes: workoutDurationMinutes ?? this.workoutDurationMinutes,
      preferredTimeOfDay: preferredTimeOfDay ?? this.preferredTimeOfDay,
      preferredWorkoutTypes: preferredWorkoutTypes ?? this.preferredWorkoutTypes,
      includeWarmup: includeWarmup ?? this.includeWarmup,
      includeCooldown: includeCooldown ?? this.includeCooldown,
      includeStretching: includeStretching ?? this.includeStretching,
      restDayPreference: restDayPreference ?? this.restDayPreference,
      restDays: restDays ?? this.restDays,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      notificationTime: notificationTime ?? this.notificationTime,
      trackProgress: trackProgress ?? this.trackProgress,
      difficultyProgression: difficultyProgression ?? this.difficultyProgression,
    );
  }

  // Get time of day display name
  String get timeOfDayDisplayName {
    switch (preferredTimeOfDay) {
      case 'morning':
        return 'صباحاً';
      case 'afternoon':
        return 'ظهراً';
      case 'evening':
        return 'مساءً';
      case 'night':
        return 'ليلاً';
      default:
        return preferredTimeOfDay;
    }
  }

  // Get progression display name
  String get progressionDisplayName {
    switch (difficultyProgression) {
      case 'gradual':
        return 'تدريجي';
      case 'moderate':
        return 'متوسط';
      case 'aggressive':
        return 'سريع';
      default:
        return difficultyProgression;
    }
  }

  // Get workout types display names
  List<String> get workoutTypesDisplayNames {
    return preferredWorkoutTypes.map((type) {
      switch (type) {
        case 'cardio':
          return 'كارديو';
        case 'strength':
          return 'قوة';
        case 'flexibility':
          return 'مرونة';
        case 'hiit':
          return 'HIIT';
        default:
          return type;
      }
    }).toList();
  }

  @override
  String toString() {
    return 'WorkoutPreferencesModel(workoutDaysPerWeek: $workoutDaysPerWeek, '
        'workoutDurationMinutes: $workoutDurationMinutes, '
        'preferredTimeOfDay: $preferredTimeOfDay, '
        'preferredWorkoutTypes: $preferredWorkoutTypes)';
  }
}