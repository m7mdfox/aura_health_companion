import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String _base = 'http://10.0.2.2:4000'; // Android emulator; use 'http://localhost:4000' for iOS/desktop

  static String? _token;
  static Map<String, dynamic>? _profile;

  static String? get token => _token;
  static Map<String, dynamic>? get profile => _profile;
  static bool get isLoggedIn => _token != null;

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
      _token = data['token'];
      _profile = data['profile'];
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
      _token = data['token'];
      _profile = data['profile'];
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  static void logout() {
    _token = null;
    _profile = null;
  }
}