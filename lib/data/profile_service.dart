import 'dart:convert';
import 'package:aura_health_companion/ui/models/user_profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:aura_health_companion/data/auth_service.dart';

class ProfileService {
  static String get _baseUrl => AuthService.baseUrl;

  /// Get current user profile from backend
  static Future<UserProfileModel> getProfile() async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$_baseUrl/api/profile/me');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get Profile Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = UserProfileModel.fromJson(data['profile']);
        
        // Update local session with latest profile
        await AuthService.updateProfileInSession(data['profile']);
        
        return profile;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      print('ProfileService.getProfile error: $e');
      rethrow;
    }
  }

  /// Update user profile
  static Future<UserProfileModel> updateProfile(Map<String, dynamic> updates) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$_baseUrl/api/profile/update');
      print('Updating profile with: $updates');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      print('Update Profile Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = UserProfileModel.fromJson(data['profile']);
        
        // Update local session with latest profile
        await AuthService.updateProfileInSession(data['profile']);
        
        return profile;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('ProfileService.updateProfile error: $e');
      rethrow;
    }
  }

  /// Upload avatar image to server
  static Future<String> uploadAvatar(String filePath) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$_baseUrl/api/profile/upload-avatar');
      
      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      
      // ✅ Add file with explicit content type
      var file = await http.MultipartFile.fromPath(
        'avatar', 
        filePath,
        contentType: MediaType('image', 'jpeg'), // Force JPEG mime type
      );
      request.files.add(file);
      
      print('Uploading avatar from: $filePath');
      
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print('Upload Avatar Response: ${response.statusCode} ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['avatar_url'] as String;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to upload avatar');
      }
    } catch (e) {
      print('ProfileService.uploadAvatar error: $e');
      rethrow;
    }
  }

  /// Delete avatar
  static Future<void> deleteAvatar() async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$_baseUrl/api/profile/delete-avatar');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Avatar Response: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete avatar');
      }
    } catch (e) {
      print('ProfileService.deleteAvatar error: $e');
      rethrow;
    }
  }
}