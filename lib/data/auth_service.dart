import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _base = 'http://192.168.1.7:4000'; // Android emulator; use 'http://localhost:4000' for iOS/desktop
  static String? _token;
  static Map<String, dynamic>? _profile;

  static String? get token => _token;
  static Map<String, dynamic>? get profile => _profile;
  static bool get isLoggedIn => _token != null;

  // Initialize AuthService by loading stored session data
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final profileJson = prefs.getString('profile');
    if (profileJson != null) {
      _profile = jsonDecode(profileJson);
    }
  }

  // Save session data to SharedPreferences
  static Future<void> _saveSession(String token, Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('profile', jsonEncode(profile));
    _token = token;
    _profile = profile;
  }

  // Clear session data
  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('profile');
    _token = null;
    _profile = null;
  }

  static Future<void> sendOTP(String email) async {
    final url = Uri.parse('$_base/api/auth/send-otp');
    final body = jsonEncode({"email": email});
    print("Sending OTP request: $body"); // Debug
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);
    print("Send OTP response: ${resp.statusCode} ${resp.body}"); // Debug

    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to send OTP');
    }
  }

  static Future<void> verifyOTP({
    required String email,
    required String otp,
    required Map<String, dynamic> userData,
  }) async {
    final url = Uri.parse('$_base/api/auth/verify-otp');
    final body = jsonEncode({
      "email": email,
      "otp": otp,
      ...userData,
    });
    print("Sending OTP verification request: $body"); // Debug
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);
    print("Verify OTP response: ${resp.statusCode} ${resp.body}"); // Debug

    final data = jsonDecode(resp.body);
    if (resp.statusCode == 201) {
      await _saveSession(data['token'], data['profile']);
    } else {
      throw Exception(data['error'] ?? 'OTP verification failed');
    }
  }

  static Future<void> login(String email, String password) async {
    final url = Uri.parse('$_base/api/auth/login');
    final body = jsonEncode({"email": email, "password": password});
    print("Sending login request: $body"); // Debug
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);
    print("Login response: ${resp.statusCode} ${resp.body}"); // Debug

    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200) {
      await _saveSession(data['token'], data['profile']);
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  static Future<void> logout() async {
    await _clearSession();
  }

  // Optional: Validate token with backend
  static Future<bool> validateToken() async {
    if (_token == null) return false;
    final url = Uri.parse('$_base/api/auth/validate-token');
    try {
      final resp = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      return resp.statusCode == 200;
    } catch (e) {
      print("Token validation error: $e");
      return false;
    }
  }
  static String get baseUrl => _base;
}
