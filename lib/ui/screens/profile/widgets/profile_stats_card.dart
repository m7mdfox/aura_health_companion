import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final int streakDays;
  final int totalPoints;
  final int completedChallenges;

  const ProfileStatsCard({
    super.key,
    required this.streakDays,
    required this.totalPoints,
    required this.completedChallenges,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: Icons.local_fire_department,
            value: streakDays.toString(),
            label: 'Day Streak',
            color: const Color(0xFFFF6B6B),
          ),
          _buildDivider(isDark),
          _buildStatItem(
            context,
            icon: Icons.stars,
            value: totalPoints.toString(),
            label: 'Points',
            color: const Color(0xFFFFD93D),
          ),
          _buildDivider(isDark),
          _buildStatItem(
            context,
            icon: Icons.emoji_events,
            value: completedChallenges.toString(),
            label: 'Challenges',
            color: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 50,
      width: 1,
      color: isDark ? Colors.white12 : Colors.grey[300],
    );
  }
}