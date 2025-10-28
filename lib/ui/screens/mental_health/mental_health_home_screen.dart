import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'mood_tracking_screen.dart';
import 'ai_insights_screen.dart';
import 'mindfulness_screen.dart';
import 'mental_reports_screen.dart';
import 'mental_support_screen.dart';

class MentalHealthHomeScreen extends StatefulWidget {
  const MentalHealthHomeScreen({super.key});

  @override
  State<MentalHealthHomeScreen> createState() => _MentalHealthHomeScreenState();
}

class _MentalHealthHomeScreenState extends State<MentalHealthHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _animations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _animations = [];
    _slideAnimations = [];

    // Create staggered fade + scale + slide animations
    for (int i = 0; i < 5; i++) {
      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.15, 1.0, curve: Curves.easeOutCubic),
        ),
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.6),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.15, 1.0, curve: Curves.easeOutCubic),
        ),
      );

      _animations.add(fadeAnimation);
      _slideAnimations.add(slideAnimation);
    }

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light background
      appBar: _buildLightAppBar(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildLightHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Feature Cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildAnimatedFeatureCard(
                      index: index,
                      fadeAnimation: _animations[index],
                      slideAnimation: _slideAnimations[index],
                    );
                  },
                  childCount: 5,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomSheet: _buildDailyQuoteCard(), // Light quote card at bottom
    );
  }

  // === Light AppBar ===
  PreferredSizeWidget _buildLightAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: const Icon(Ionicons.arrow_back, color: Color(0xFF475569), size: 22),
              ),
            ),
          ),
        ),
        title: Text(
          'Mental Health',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Ionicons.settings_outline, color: Color(0xFF475569), size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Light Header ===
  Widget _buildLightHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Ionicons.heart, color: Color(0xFF3B82F6), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mental Wellness Hub',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take care of your mind, one step at a time.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === Animated Feature Card ===
  Widget _buildAnimatedFeatureCard({
    required int index,
    required Animation<double> fadeAnimation,
    required Animation<Offset> slideAnimation,
  }) {
    final features = [
      {
        "title": "Mood Tracking",
        "subtitle": "Track your emotions daily",
        "icon": Ionicons.happy,
        "color": const Color(0xFFF97316),
        "screen": const MoodTrackingScreen(),
      },
      {
  "title": "AI Insights",
  "subtitle": "Personalized daily notes",
  "icon": Ionicons.sparkles,
  "color": const Color(0xFF8B5CF6), 
  "screen": const AIInsightsScreen(),
},
      {
        "title": "Mindfulness & Relaxation",
        "subtitle": "Meditate, breathe, relax",
        "icon": Ionicons.flower,
        "color": const Color(0xFF10B981),
        "screen": const MindfulnessScreen(),
      },
      {
        "title": "Mental & Physical Reports",
        "subtitle": "Insights into your well-being",
        "icon": Ionicons.analytics,
        "color": const Color(0xFF8B5CF6),
        "screen": const MentalReportsScreen(),
      },
      {
        "title": "Professional Support",
        "subtitle": "Connect with experts",
        "icon": Ionicons.people,
        "color": const Color(0xFFEF4444),
        "screen": const MentalSupportScreen(),
      },
    ];

    final feature = features[index];

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: fadeAnimation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          ),
        );
      },
      child: _buildFeatureCard(
        title: feature["title"] as String,
        subtitle: feature["subtitle"] as String,
        icon: feature["icon"] as IconData,
        color: feature["color"] as Color,
        screen: feature["screen"] as Widget,
      ),
    );
  }

  // === Feature Card (Light Theme) ===
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder: (_, __, ___) => screen,
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Daily Quote Card (Light & Floating) ===
  Widget _buildDailyQuoteCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFBBF24),
              shape: BoxShape.circle,
            ),
            child: const Icon(Ionicons.sparkles, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '"Small steps every day lead to big changes."',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF475569),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}