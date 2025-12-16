import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/auth_service.dart';

/// Model for points award response
class PointsAward {
  final int points;
  final String action;
  final String message;
  final int newTotal;

  PointsAward({
    required this.points,
    required this.action,
    required this.message,
    required this.newTotal,
  });

  factory PointsAward.fromJson(Map<String, dynamic> json) {
    return PointsAward(
      points: json['points'] ?? 0,
      action: json['action'] ?? '',
      message: json['message'] ?? '',
      newTotal: json['newTotal'] ?? 0,
    );
  }
}

/// Model for points history entry
class PointsHistoryEntry {
  final String id;
  final int points;
  final String actionType;
  final String description;
  final DateTime createdAt;

  PointsHistoryEntry({
    required this.id,
    required this.points,
    required this.actionType,
    required this.description,
    required this.createdAt,
  });

  factory PointsHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PointsHistoryEntry(
      id: json['_id'] ?? '',
      points: json['points'] ?? 0,
      actionType: json['action_type'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Model for points summary
class PointsSummary {
  final int totalPoints;
  final int rank;
  final int totalUsers;
  final Map<String, dynamic> breakdown;

  PointsSummary({
    required this.totalPoints,
    required this.rank,
    required this.totalUsers,
    required this.breakdown,
  });

  factory PointsSummary.fromJson(Map<String, dynamic> json) {
    return PointsSummary(
      totalPoints: json['totalPoints'] ?? 0,
      rank: json['rank'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      breakdown: json['breakdown'] ?? {},
    );
  }
}

/// Model for leaderboard entry
class LeaderboardEntry {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final int totalPoints;
  final int streakDays;
  final int completedChallenges;

  LeaderboardEntry({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.totalPoints,
    required this.streakDays,
    required this.completedChallenges,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['_id'] ?? '',
      fullName: json['full_name'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      totalPoints: json['totalPoints'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      completedChallenges: json['completedChallenges'] ?? 0,
    );
  }
}

/// Service for health points gamification system
class PointsService {
  static String get _baseUrl => AuthService.baseUrl;

  /// Get user's points history
  static Future<List<PointsHistoryEntry>> getHistory({int limit = 50}) async {
    try {
      final authId = AuthService.profile?['auth_id'];
      if (authId == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse(
          '$_baseUrl/api/points/history?auth_id=$authId&limit=$limit');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> historyJson = data['data'] ?? [];
        return historyJson.map((e) => PointsHistoryEntry.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch points history');
      }
    } catch (e) {
      print('PointsService.getHistory error: $e');
      rethrow;
    }
  }

  /// Get user's points summary with rank
  static Future<PointsSummary> getSummary() async {
    try {
      final authId = AuthService.profile?['auth_id'];
      if (authId == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$_baseUrl/api/points/summary?auth_id=$authId');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PointsSummary.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch points summary');
      }
    } catch (e) {
      print('PointsService.getSummary error: $e');
      rethrow;
    }
  }

  /// Get leaderboard
  static Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    try {
      final url = Uri.parse('$_baseUrl/api/points/leaderboard?limit=$limit');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> leaderboardJson = data['data'] ?? [];
        return leaderboardJson
            .map((e) => LeaderboardEntry.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to fetch leaderboard');
      }
    } catch (e) {
      print('PointsService.getLeaderboard error: $e');
      rethrow;
    }
  }

  /// Claim daily login bonus
  static Future<PointsAward?> claimDailyLogin() async {
    try {
      final authId = AuthService.profile?['auth_id'];
      if (authId == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$_baseUrl/api/points/daily-login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'auth_id': authId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data']['transaction'] != null) {
          return PointsAward(
            points: data['data']['transaction']['points'] ?? 5,
            action: 'daily_login',
            message: '+5 points for daily login! 🌟',
            newTotal: data['data']['newTotal'] ?? 0,
          );
        }
        return null; // Already claimed today
      } else {
        return null;
      }
    } catch (e) {
      print('PointsService.claimDailyLogin error: $e');
      return null;
    }
  }

  /// Parse points award from API response
  static PointsAward? parsePointsFromResponse(
      Map<String, dynamic>? pointsData) {
    if (pointsData == null) return null;
    return PointsAward.fromJson(pointsData);
  }
}
