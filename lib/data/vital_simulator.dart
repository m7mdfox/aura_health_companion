import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class VitalSimulator {
  final Random _random = Random();
  List<Map<String, dynamic>> _normalData = [];
  int _currentIndex = 0;

  final double _alertProbability = 0.05;

  final int heartRateLowThreshold = 40;
  final int heartRateHighThreshold = 120;
  final int oxygenLowThreshold = 90;

  // Daily step tracking
  int _dailySteps = 0;
  DateTime _lastResetDate = DateTime.now();

  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  VitalSimulator() {
    _initializeSteps();
    _loadJsonData();
  }

  /// Initialize steps based on current time of day
  void _initializeSteps() {
    final now = DateTime.now();
    _lastResetDate = DateTime(now.year, now.month, now.day);

    // Calculate accumulated steps based on current time
    // Simulate that person has been walking since midnight
    _dailySteps = _calculateStepsSinceMidnight(now);
  }

  /// Calculate how many steps would have accumulated from midnight to now
  int _calculateStepsSinceMidnight(DateTime now) {
    int steps = 0;
    final hourOfDay = now.hour;
    final minuteOfHour = now.minute;

    // Simulate hourly step patterns for a typical person
    // Less active at night, more active during day
    for (int h = 0; h < hourOfDay; h++) {
      steps += _getHourlySteps(h);
    }

    // Add partial hour steps
    final currentHourSteps = _getHourlySteps(hourOfDay);
    steps += (currentHourSteps * minuteOfHour / 60).round();

    return steps;
  }

  /// Get typical steps for a given hour (0-23)
  int _getHourlySteps(int hour) {
    // Sleeping hours (12am-6am): minimal steps
    if (hour >= 0 && hour < 6) {
      return _random.nextInt(20); // 0-20 steps (bathroom, etc.)
    }
    // Early morning (6am-8am): waking up, getting ready
    else if (hour >= 6 && hour < 8) {
      return 200 + _random.nextInt(300); // 200-500 steps
    }
    // Morning commute/work (8am-12pm): moderate activity
    else if (hour >= 8 && hour < 12) {
      return 400 + _random.nextInt(600); // 400-1000 steps
    }
    // Lunch break (12pm-2pm): walking around
    else if (hour >= 12 && hour < 14) {
      return 500 + _random.nextInt(700); // 500-1200 steps
    }
    // Afternoon (2pm-6pm): moderate activity
    else if (hour >= 14 && hour < 18) {
      return 300 + _random.nextInt(500); // 300-800 steps
    }
    // Evening (6pm-9pm): exercise, walking, errands
    else if (hour >= 18 && hour < 21) {
      return 500 + _random.nextInt(1000); // 500-1500 steps
    }
    // Night (9pm-12am): winding down
    else {
      return 100 + _random.nextInt(200); // 100-300 steps
    }
  }

  /// Get random step increment based on current hour (realistic walking)
  int _getStepIncrement() {
    final hour = DateTime.now().hour;

    // Night time (11pm-6am): very few steps
    if (hour >= 23 || hour < 6) {
      return _random.nextDouble() < 0.1 ? _random.nextInt(5) : 0;
    }
    // Active hours: random steps based on activity level
    else if (hour >= 6 && hour < 22) {
      // 70% chance of walking
      if (_random.nextDouble() < 0.7) {
        // Normal walking: 5-30 steps per 10 seconds
        return 5 + _random.nextInt(26);
      } else {
        // Stationary: 0-3 steps
        return _random.nextInt(4);
      }
    }
    // Late evening (10pm-11pm): occasional movement
    else {
      return _random.nextDouble() < 0.3 ? _random.nextInt(10) : 0;
    }
  }

  /// Check if we need to reset steps for a new day
  void _checkMidnightReset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (today.isAfter(_lastResetDate)) {
      // New day - reset steps to 0
      _dailySteps = 0;
      _lastResetDate = today;
      print('🕛 Midnight reset: Steps reset to 0');
    }
  }

  Future<void> _loadJsonData() async {
    final String jsonString =
        await rootBundle.loadString('assets/animations/vitals.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    _normalData = List<Map<String, dynamic>>.from(jsonData['vitalSigns']);
    _startSimulation();
  }

  void _startSimulation() async {
    while (!_controller.isClosed) {
      if (_normalData.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      // Check for midnight reset
      _checkMidnightReset();

      // Increment steps realistically
      _dailySteps += _getStepIncrement();

      Map<String, dynamic> vitalData = Map.from(_normalData[_currentIndex]);

      // Override steps with our simulated daily steps
      vitalData['steps'] = _dailySteps;

      // Calculate calories based on steps (approx 0.04 calories per step)
      vitalData['caloriesBurnt'] = (_dailySteps * 0.04).round();

      // Occasionally push extreme values for heart rate/oxygen
      if (_random.nextDouble() < _alertProbability) {
        if (_random.nextBool()) {
          vitalData['heartRate'] = _random.nextBool()
              ? heartRateHighThreshold + 10 + _random.nextInt(20)
              : heartRateLowThreshold - 5 - _random.nextInt(10);
        } else {
          vitalData['spo2'] = oxygenLowThreshold - 5 - _random.nextInt(5);
        }
      }

      _controller.add(vitalData);

      _currentIndex = (_currentIndex + 1) % _normalData.length;

      await Future.delayed(const Duration(seconds: 10));
    }
  }

  Stream<Map<String, dynamic>> simulateVitals() => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
