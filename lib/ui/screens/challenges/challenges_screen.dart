import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:aura_health_companion/data/auth_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allChallenges = [];
  List<Map<String, dynamic>> _activeChallenges = [];
  List<Map<String, dynamic>> _completedChallenges = [];
  String _selectedCategory = 'all';
  late TabController _tabController;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'all',
      'label': 'All',
      'icon': Icons.apps,
      'color': const Color(0xFF6366F1)
    },
    {
      'id': 'medication',
      'label': 'Medicine',
      'icon': Icons.medication,
      'color': const Color(0xFF10B981)
    },
    {
      'id': 'wellness',
      'label': 'Wellness',
      'icon': Icons.psychology,
      'color': const Color(0xFFFBBF24)
    },
    {
      'id': 'hydration',
      'label': 'Hydration',
      'icon': Icons.water_drop,
      'color': const Color(0xFF00B4DB)
    },
    {
      'id': 'fitness',
      'label': 'Fitness',
      'icon': Icons.fitness_center,
      'color': const Color(0xFFEF4444)
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final authId = AuthService.profile?['auth_id'];
      if (authId == null) return;

      // Fetch all challenges
      final challengesUrl = Uri.parse('${AuthService.baseUrl}/api/challenges');
      final challengesResponse = await http.get(challengesUrl);

      if (challengesResponse.statusCode == 200) {
        final data = jsonDecode(challengesResponse.body);
        setState(() {
          _allChallenges = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
      }

      // Fetch user's challenge progress
      final userChallengesUrl = Uri.parse(
          '${AuthService.baseUrl}/api/challenges/user?auth_id=$authId');
      final userChallengesResponse = await http.get(userChallengesUrl);

      if (userChallengesResponse.statusCode == 200) {
        final data = jsonDecode(userChallengesResponse.body);
        setState(() {
          _activeChallenges =
              List<Map<String, dynamic>>.from(data['data']?['active'] ?? []);
          _completedChallenges =
              List<Map<String, dynamic>>.from(data['data']?['completed'] ?? []);
        });
      }

      setState(() => _isLoading = false);
      _animationController.forward();
    } catch (e) {
      print('Error loading challenges: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startChallenge(String challengeId) async {
    try {
      final authId = AuthService.profile?['auth_id'];
      if (authId == null) return;

      final url =
          Uri.parse('${AuthService.baseUrl}/api/challenges/$challengeId/start');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'auth_id': authId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎯 Challenge started! Good luck!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadData(); // Refresh
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to start';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error starting challenge: $e');
    }
  }

  List<Map<String, dynamic>> _getFilteredChallenges() {
    if (_selectedCategory == 'all') return _allChallenges;
    return _allChallenges
        .where((c) => c['category'] == _selectedCategory)
        .toList();
  }

  bool _isChallengeActive(String challengeId) {
    return _activeChallenges
        .any((c) => c['challenge_id']?['_id'] == challengeId);
  }

  bool _isChallengeCompleted(String challengeId) {
    return _completedChallenges
        .any((c) => c['challenge_id']?['_id'] == challengeId);
  }

  Map<String, dynamic>? _getActiveProgress(String challengeId) {
    try {
      return _activeChallenges.firstWhere(
        (c) => c['challenge_id']?['_id'] == challengeId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _buildAppBar(isDark),
                SliverToBoxAdapter(child: _buildCategoryChips(isDark)),
                SliverToBoxAdapter(child: _buildTabBar(isDark)),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvailableTab(isDark),
                  _buildMyProgressTab(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 180,
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
                  ? [const Color(0xFF1A1D2E), const Color(0xFF6B46C1)]
                  : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -50,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: 20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.flag_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Health Challenges',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Complete challenges & earn points! 🏆',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 46,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isSelected = _selectedCategory == cat['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cat['color']
                        : (isDark ? const Color(0xFF1A1D2E) : Colors.white),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? cat['color']
                          : (isDark ? Colors.white24 : Colors.grey[300]!),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (cat['color'] as Color).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cat['icon'],
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.grey[700]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat['label'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.white60 : Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: [
          Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.list_alt_rounded, size: 18),
                const SizedBox(width: 8),
                Text('Available', style: GoogleFonts.poppins()),
              ],
            ),
          ),
          Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up_rounded, size: 18),
                const SizedBox(width: 8),
                Text('My Progress', style: GoogleFonts.poppins()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTab(bool isDark) {
    final challenges = _getFilteredChallenges();

    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: isDark ? Colors.white30 : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No challenges in this category',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return _buildChallengeCard(challenges[index], isDark, index);
      },
    );
  }

  Widget _buildChallengeCard(
      Map<String, dynamic> challenge, bool isDark, int index) {
    final challengeId = challenge['_id'];
    final isActive = _isChallengeActive(challengeId);
    final isCompleted = _isChallengeCompleted(challengeId);
    final activeProgress = _getActiveProgress(challengeId);

    final category = challenge['category'] ?? 'wellness';
    final categoryInfo = _categories.firstWhere(
      (c) => c['id'] == category,
      orElse: () => _categories[0],
    );
    final color = categoryInfo['color'] as Color;
    final difficulty = challenge['difficulty'] ?? 'easy';

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? Border.all(color: color, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? color.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        challenge['icon'] ?? '🏆',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title & Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge['title'] ?? 'Challenge',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge['description'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status/Difficulty badge
                  Column(
                    children: [
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF10B981), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Done',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        _buildDifficultyBadge(difficulty, isDark),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD93D).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars,
                                color: Color(0xFFFFD93D), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '+${challenge['points_reward'] ?? 0}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress bar (if active)
            if (isActive && activeProgress != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${activeProgress['progress'] ?? 0}/${activeProgress['target'] ?? 0}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (activeProgress['progress'] ?? 0) /
                            (activeProgress['target'] ?? 1),
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action button
            if (!isCompleted)
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isActive ? null : () => _startChallenge(challengeId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.grey[400] : color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isActive ? 0 : 4,
                    ),
                    child: Text(
                      isActive ? '⏳ In Progress...' : '🚀 Start Challenge',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty, bool isDark) {
    Color badgeColor;
    String label;

    switch (difficulty) {
      case 'hard':
        badgeColor = const Color(0xFFEF4444);
        label = '🔥 Hard';
        break;
      case 'medium':
        badgeColor = const Color(0xFFF59E0B);
        label = '⚡ Medium';
        break;
      default:
        badgeColor = const Color(0xFF10B981);
        label = '✨ Easy';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildMyProgressTab(bool isDark) {
    final all = [..._activeChallenges, ..._completedChallenges];

    if (all.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rocket_launch,
                size: 60,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No challenges started yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a challenge to begin your journey!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_activeChallenges.isNotEmpty) ...[
          _buildSectionHeader(
              '🎯 Active Challenges', _activeChallenges.length, isDark),
          const SizedBox(height: 12),
          ..._activeChallenges.map((uc) {
            final challenge = uc['challenge_id'];
            if (challenge == null) return const SizedBox();
            return _buildProgressCard(uc, challenge, isDark, false);
          }),
          const SizedBox(height: 24),
        ],
        if (_completedChallenges.isNotEmpty) ...[
          _buildSectionHeader(
              '🏆 Completed', _completedChallenges.length, isDark),
          const SizedBox(height: 12),
          ..._completedChallenges.map((uc) {
            final challenge = uc['challenge_id'];
            if (challenge == null) return const SizedBox();
            return _buildProgressCard(uc, challenge, isDark, true);
          }),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isDark) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD97706),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    Map<String, dynamic> userChallenge,
    Map<String, dynamic> challenge,
    bool isDark,
    bool isCompleted,
  ) {
    final progress = userChallenge['progress'] ?? 0;
    final target = userChallenge['target'] ?? 1;
    final percentage = (progress / target * 100).clamp(0, 100).toInt();

    final category = challenge['category'] ?? 'wellness';
    final categoryInfo = _categories.firstWhere(
      (c) => c['id'] == category,
      orElse: () => _categories[0],
    );
    final color =
        isCompleted ? const Color(0xFF10B981) : categoryInfo['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(
                color: const Color(0xFF10B981).withOpacity(0.5), width: 1)
            : null,
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
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                challenge['icon'] ?? '🏆',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'] ?? 'Challenge',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress / target,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$progress / $target ($percentage%)',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Points badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981).withOpacity(0.15)
                  : const Color(0xFFFFD93D).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.stars,
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : const Color(0xFFFFD93D),
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  '+${challenge['points_reward'] ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
