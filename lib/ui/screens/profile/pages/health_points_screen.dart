import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:aura_health_companion/data/auth_service.dart';

class HealthPointsScreen extends StatefulWidget {
  const HealthPointsScreen({super.key});

  @override
  State<HealthPointsScreen> createState() => _HealthPointsScreenState();
}

class _HealthPointsScreenState extends State<HealthPointsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  int _totalPoints = 0;
  int _rank = 0;
  int _totalUsers = 0;
  List<Map<String, dynamic>> _recentAchievements = [];
  List<Map<String, dynamic>> _leaderboard = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final authId = AuthService.profile?['auth_id'];
      if (authId == null) return;

      // Fetch summary
      final summaryUrl = Uri.parse(
          '${AuthService.baseUrl}/api/points/summary?auth_id=$authId');
      final summaryResponse = await http.get(summaryUrl);

      if (summaryResponse.statusCode == 200) {
        final data = jsonDecode(summaryResponse.body);
        setState(() {
          _totalPoints = data['data']['totalPoints'] ?? 0;
          _rank = data['data']['rank'] ?? 0;
          _totalUsers = data['data']['totalUsers'] ?? 0;
        });
      }

      // Fetch history
      final historyUrl = Uri.parse(
          '${AuthService.baseUrl}/api/points/history?auth_id=$authId&limit=3');
      final historyResponse = await http.get(historyUrl);

      if (historyResponse.statusCode == 200) {
        final data = jsonDecode(historyResponse.body);
        setState(() {
          _recentAchievements =
              List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
      }

      // Fetch leaderboard
      final leaderboardUrl =
          Uri.parse('${AuthService.baseUrl}/api/points/leaderboard?limit=3');
      final leaderboardResponse = await http.get(leaderboardUrl);

      if (leaderboardResponse.statusCode == 200) {
        final data = jsonDecode(leaderboardResponse.body);
        setState(() {
          _leaderboard = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
      }

      setState(() => _isLoading = false);
      _animationController.forward();
    } catch (e) {
      print('Error loading points data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = AuthService.profile?['full_name'] ?? 'User';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(isDark, userName),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildStatsCard(isDark),
                        const SizedBox(height: 20),
                        _buildRecentAchievements(isDark),
                        const SizedBox(height: 20),
                        _buildLeaderboard(isDark),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar(bool isDark, String userName) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor:
          isDark ? const Color(0xFF1A1D2E) : const Color(0xFF00177E),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1D2E), const Color(0xFF2D1B69)]
                  : [const Color(0xFF00177E), const Color(0xFF0F1120)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Avatar with glow effect
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD93D).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00177E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Health Champion',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00177E), Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00177E).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.stars,
            value: _totalPoints.toString(),
            label: 'HPS',
            color: const Color(0xFFFFD93D),
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          _buildStatItem(
            icon: Icons.public,
            value: '#$_rank',
            label: 'WORLD RANK',
            color: Colors.white,
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          _buildStatItem(
            icon: Icons.people,
            value: '$_totalUsers',
            label: 'PLAYERS',
            color: const Color(0xFF00B4DB),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAchievements(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.emoji_events,
                    color: Color(0xFFFFD93D), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Recent Achievements',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (_recentAchievements.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Start earning points to see achievements!',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...List.generate(_recentAchievements.length, (index) {
              final achievement = _recentAchievements[index];
              return _buildAchievementTile(achievement, isDark, index);
            }),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(
      Map<String, dynamic> achievement, bool isDark, int index) {
    final actionType = achievement['action_type'] ?? '';
    final points = achievement['points'] ?? 0;
    final description = achievement['description'] ?? '';

    final iconData = _getAchievementIcon(actionType);
    final color = _getAchievementColor(actionType);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatActionType(actionType),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+$points',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.leaderboard,
                    color: Color(0xFF00B4DB), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Leaderboard',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _leaderboard.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No players yet. Be the first!',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                        ),
                      ),
                    ]
                  : List.generate(_leaderboard.length, (index) {
                      final user = _leaderboard[index];
                      return _buildLeaderboardItem(user, index, isDark);
                    }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
      Map<String, dynamic> user, int index, bool isDark) {
    final isFirst = index == 0;
    final isSecond = index == 1;
    final isThird = index == 2;

    Color? medalColor;
    if (isFirst) medalColor = const Color(0xFFFFD700);
    if (isSecond) medalColor = const Color(0xFFC0C0C0);
    if (isThird) medalColor = const Color(0xFFCD7F32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: index < _leaderboard.length - 1
            ? Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey[200]!,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  medalColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: medalColor != null
                  ? Icon(Icons.emoji_events, color: medalColor, size: 18)
                  : Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF00177E).withOpacity(0.2),
            child: Text(
              (user['full_name'] ?? 'U')[0].toUpperCase(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00177E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              user['full_name'] ?? 'Unknown',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Points
          Row(
            children: [
              const Icon(Icons.stars, color: Color(0xFFFFD93D), size: 16),
              const SizedBox(width: 4),
              Text(
                '${user['totalPoints'] ?? 0}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getAchievementIcon(String actionType) {
    switch (actionType) {
      case 'medicine_taken':
        return Icons.medication;
      case 'mood_log':
        return Icons.sentiment_satisfied_alt;
      case 'daily_login':
        return Icons.login;
      case 'exercise':
        return Icons.fitness_center;
      case 'water_goal':
        return Icons.water_drop;
      case 'challenge_complete':
        return Icons.emoji_events;
      case 'streak_bonus':
        return Icons.local_fire_department;
      default:
        return Icons.star;
    }
  }

  Color _getAchievementColor(String actionType) {
    switch (actionType) {
      case 'medicine_taken':
        return const Color(0xFF10B981);
      case 'mood_log':
        return const Color(0xFFFBBF24);
      case 'daily_login':
        return const Color(0xFF3B82F6);
      case 'exercise':
        return const Color(0xFFEF4444);
      case 'water_goal':
        return const Color(0xFF00B4DB);
      case 'challenge_complete':
        return const Color(0xFF8B5CF6);
      case 'streak_bonus':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _formatActionType(String actionType) {
    switch (actionType) {
      case 'medicine_taken':
        return '💊 Medicine Taken';
      case 'mood_log':
        return '😊 Mood Logged';
      case 'daily_login':
        return '🌟 Daily Login';
      case 'exercise':
        return '🏋️ Exercise Complete';
      case 'water_goal':
        return '💧 Water Goal Met';
      case 'challenge_complete':
        return '🏆 Challenge Complete';
      case 'streak_bonus':
        return '🔥 Streak Bonus';
      default:
        return '⭐ Achievement';
    }
  }
}
