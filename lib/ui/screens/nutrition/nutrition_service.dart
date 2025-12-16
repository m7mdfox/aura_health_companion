// lib/data/nutrition_service.dart
import 'dart:convert';
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:http/http.dart' as http;

class NutritionService {
  static String get baseUrl => AuthService.baseUrl;

  /// Submit onboarding data
  static Future<Map<String, dynamic>?> submitOnboarding(
      Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/nutrition/onboarding');
    final token = AuthService.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp =
        await http.post(uri, headers: headers, body: jsonEncode(payload));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      throw Exception(
          'Server error ${resp.statusCode}: ${body['error'] ?? resp.body}');
    }
  }

  /// Get onboarding data
  static Future<Map<String, dynamic>?> getOnboarding() async {
    final uri = Uri.parse('$baseUrl/api/nutrition/onboarding');
    final token = AuthService.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else if (resp.statusCode == 404) {
      return null;
    } else {
      final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      throw Exception(
          'Server error ${resp.statusCode}: ${body['error'] ?? resp.body}');
    }
  }

  /// Get complete nutrition data
  static Future<Map<String, dynamic>?> getCompleteData() async {
    final uri = Uri.parse('$baseUrl/api/nutrition/complete-data');
    final token = AuthService.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else if (resp.statusCode == 404) {
      return null;
    } else {
      final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      throw Exception(
          'Server error ${resp.statusCode}: ${body['error'] ?? resp.body}');
    }
  }

  /// Generate nutrition plan
  static Future<Map<String, dynamic>?> generatePlan() async {
    final uri = Uri.parse('$baseUrl/api/nutrition/generate-plan');
    final token = AuthService.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.post(uri, headers: headers);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      throw Exception(
          'Server error ${resp.statusCode}: ${body['error'] ?? resp.body}');
    }
  }

  /// NEW: Get saved nutrition plan
  static Future<Map<String, dynamic>?> getSavedPlan() async {
    final uri = Uri.parse('$baseUrl/api/nutrition/saved-plan');
    final token = AuthService.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final resp = await http.get(uri, headers: headers);
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['hasPlan'] == true) {
          return data;
        }
        return null;
      } else if (resp.statusCode == 404) {
        return null;
      } else {
        final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        throw Exception(
            'Server error ${resp.statusCode}: ${body['error'] ?? resp.body}');
      }
    } catch (e) {
      print('Error getting saved plan: $e');
      return null;
    }
  }

  /// NEW: Delete current nutrition plan
  static Future<bool> deletePlan() async {
    final uri = Uri.parse('$baseUrl/api/nutrition/delete-plan');
    final token = AuthService.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final resp = await http.delete(uri, headers: headers);
      
      if (resp.statusCode == 200) {
        return true;
      } else {
        final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        throw Exception(
            'Server error ${resp.statusCode}: ${body['error'] ?? resp.body}');
      }
    } catch (e) {
      print('Error deleting plan: $e');
      return false;
    }
  }

  /// Check if user has a saved plan
  static Future<bool> hasSavedPlan() async {
    final plan = await getSavedPlan();
    return plan != null && plan['hasPlan'] == true;
  }
}