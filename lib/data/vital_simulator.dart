import 'dart:async';
import 'dart:math';

enum ActivityState {
  resting,
  walking,
  running
}

class VitalSimulator {
  int _steps = 1000;
  double _caloriesBurnt = 100;
  ActivityState _currentActivity = ActivityState.resting;
  final Random _random = Random();
  Timer? _activityTimer;
  DateTime _lastBPCheck = DateTime.now();
  
  // Base vital ranges for different activities
  final Map<ActivityState, Map<String, List<int>>> _vitalRanges = {
    ActivityState.resting: {
      'heartRate': [60, 80],
      'steps': [0, 5],
      'caloriesPerMinute': [1, 2],
    },
    ActivityState.walking: {
      'heartRate': [75, 100],
      'steps': [80, 120],
      'caloriesPerMinute': [3, 5],
    },
    ActivityState.running: {
      'heartRate': [120, 150],
      'steps': [140, 180],
      'caloriesPerMinute': [8, 12],
    },
  };

  VitalSimulator() {
    _startActivitySimulation();
  }

  void _startActivitySimulation() {
    _activityTimer?.cancel();
    _activityTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      // Randomly change activity every 5 minutes
      _updateActivity();
    });
  }

  void _updateActivity() {
    final rand = _random.nextDouble();
    if (rand < 0.6) {
      _currentActivity = ActivityState.resting;
    } else if (rand < 0.9) {
      _currentActivity = ActivityState.walking;
    } else {
      _currentActivity = ActivityState.running;
    }
  }

  int _generateHeartRate() {
    final range = _vitalRanges[_currentActivity]!['heartRate']!;
    return range[0] + _random.nextInt(range[1] - range[0]);
  }

  int _generateSteps() {
    if (_steps >= 10000) return 10000; // Max steps cap
    final range = _vitalRanges[_currentActivity]!['steps']!;
    // Adjust for 20-second intervals (1/3 of a minute)
    final newSteps = (range[0] + _random.nextInt(range[1] - range[0])) ~/ 3;
    _steps += newSteps;
    return _steps;
  }

  double _generateCalories() {
    if (_caloriesBurnt >= 1000) return 1000; // Max calories cap
    final range = _vitalRanges[_currentActivity]!['caloriesPerMinute']!;
    // Adjust for 20-second intervals (1/3 of a minute)
    final newCalories = (range[0] + _random.nextDouble() * (range[1] - range[0])) / 3;
    _caloriesBurnt += newCalories;
    return _caloriesBurnt;
  }

  Map<String, dynamic> _generateBloodPressure() {
    // Simulate BP variations based on activity
    int systolicBase = _currentActivity == ActivityState.running ? 140 : 120;
    int diastolicBase = _currentActivity == ActivityState.running ? 90 : 80;
    
    return {
      'systolic': systolicBase + _random.nextInt(10) - 5,
      'diastolic': diastolicBase + _random.nextInt(10) - 5,
    };
  }

  int _generateSpO2() {
    // SpO2 typically stays between 95-99%
    return 95 + _random.nextInt(5);
  }

  Stream<Map<String, dynamic>> simulateVitals() async* {
    while (true) {
      final now = DateTime.now();
      Map<String, dynamic> vitalData = {
        'time': now.toIso8601String(),
        'heartRate': _generateHeartRate(),
        'steps': _generateSteps(),
        'caloriesBurnt': _generateCalories().round(),
        'spo2': _generateSpO2(),
        'activityState': _currentActivity.toString().split('.').last,
      };

      // Add BP measurements every 30 minutes
      if (now.difference(_lastBPCheck).inMinutes >= 30) {
        final bp = _generateBloodPressure();
        vitalData['bpSystolic'] = bp['systolic'];
        vitalData['bpDiastolic'] = bp['diastolic'];
        _lastBPCheck = now;
      }

      yield vitalData;
      await Future.delayed(const Duration(seconds: 20)); // Update every 20 seconds
    }
  }

  void dispose() {
    _activityTimer?.cancel();
  }
}
