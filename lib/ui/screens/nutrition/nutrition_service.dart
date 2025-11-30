import 'dart:convert';
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:http/http.dart' as http;
// import 'package:your_app/ui/services/auth_service.dart'; // path may vary

class NutritionService {
  static const String _base = 'http://10.0.2.2:4000'; // update to your BASE_URL

  /// Submit onboarding data -> returns decoded json or throws
  static Future<Map<String, dynamic>?> submitOnboarding(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_base/api/nutrition/onboarding');
    final token = AuthService.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.post(uri, headers: headers, body: jsonEncode(payload));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      throw Exception('Server error ${resp.statusCode}: ${body['error'] ?? resp.body}');
    }
  }

  /// You can add other methods:
  /// - getPlan(userId)
  /// - analyzeFood(text)
  /// - recommendNow(userId, context)
}
