import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class VitalSimulator {
  final Random _random = Random();
  List<Map<String, dynamic>> _normalData = [];
  int _currentIndex = 0;

  final double _alertProbability = 0.3;

  final int heartRateLowThreshold = 40;
  final int heartRateHighThreshold = 120;
  final int oxygenLowThreshold = 90;

  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();

  VitalSimulator() {
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    final String jsonString = await rootBundle.loadString('assets/animations/vitals.json');
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

      Map<String, dynamic> vitalData = Map.from(_normalData[_currentIndex]);

      // Occasionally push extreme values
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
