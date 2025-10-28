import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class MentalSupportScreen extends StatefulWidget {
  const MentalSupportScreen({super.key});

  @override
  State<MentalSupportScreen> createState() => _MentalSupportScreenState();
}

class _MentalSupportScreenState extends State<MentalSupportScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late List<AnimationController> _glowControllers;
  late List<Animation<double>> _glowAnimations;

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimations = [];
    _slideAnimations = [];
    _glowControllers = [];
    _glowAnimations = [];

    for (int i = 0; i < 3; i++) {
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.18, 1.0, curve: Curves.easeOutCubic),
        ),
      );

      final slide = Tween<Offset>(begin: const Offset(0, 0.7), end: Offset.zero)
          .animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.18, 1.0, curve: Curves.easeOutCubic),
        ),
      );

      _fadeAnimations.add(fade);
      _slideAnimations.add(slide);

      final glowController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      final glow = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: glowController, curve: Curves.easeOut),
      );

      _glowControllers.add(glowController);
      _glowAnimations.add(glow);
    }

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    for (var controller in _glowControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Support Options
  List<Map<String, dynamic>> get supportOptions => [
    {
      "title": "Book a Session with a Therapist",
      "subtitle": "One-on-one professional support",
      "icon": Ionicons.person,
      "color": const Color(0xFFEF4444), // Red
      "buttonText": "Book Now",
      "onTap": () => _showSnackBar("Booking therapist session...", const Color(0xFFEF4444)),
    },
    {
      "title": "Call Emergency Support Line",
      "subtitle": "24/7 immediate help",
      "icon": Ionicons.call,
      "color": const Color(0xFF3B82F6), // Blue
      "buttonText": "Call Now",
      "onTap": () => _showSnackBar("Connecting to support line...", const Color(0xFF3B82F6)),
    },
    {
      "title": "Join Support Groups",
      "subtitle": "Connect with others who understand",
      "icon": Ionicons.people,
      "color": const Color(0xFF10B981), // Green
      "buttonText": "Join Group",
      "onTap": () => _showSnackBar("Opening support groups...", const Color(0xFF10B981)),
    },
  ];

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Ionicons.checkmark_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              message,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildLightAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Professional Support',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are not alone. Help is just a tap away.',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: const Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Support Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: supportOptions.length,
                itemBuilder: (context, index) {
                  return _buildPremiumSupportCard(
                    index: index,
                    option: supportOptions[index],
                    fadeAnimation: _fadeAnimations[index],
                    slideAnimation: _slideAnimations[index],
                    glowAnimation: _glowAnimations[index],
                    glowController: _glowControllers[index],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
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
        shadowColor: Colors.black.withOpacity(0.06),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _backButton(),
        ),
        title: Text(
          'Support',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  // === Glass Back Button ===
  Widget _backButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => Navigator.pop(context),
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
    );
  }

  // === Premium Support Card with Glow + Animation ===
  Widget _buildPremiumSupportCard({
    required int index,
    required Map<String, dynamic> option,
    required Animation<double> fadeAnimation,
    required Animation<Offset> slideAnimation,
    required Animation<double> glowAnimation,
    required AnimationController glowController,
  }) {
    final Color baseColor = option['color'] as Color;

    return AnimatedBuilder(
      animation: Listenable.merge([_staggerController, glowController]),
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Transform.scale(
              scale: 0.94 + (0.06 * fadeAnimation.value),
              child: Opacity(
                opacity: fadeAnimation.value,
                child: _buildGlassSupportCard(
                  option: option,
                  baseColor: baseColor,
                  glowValue: glowAnimation.value,
                  onTap: () {
                    glowController.forward().then((_) => glowController.reset());
                    option['onTap'] as void Function();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // === Glassmorphic Support Card ===
  Widget _buildGlassSupportCard({
    required Map<String, dynamic> option,
    required Color baseColor,
    required double glowValue,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          splashColor: baseColor.withOpacity(0.3),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9 - glowValue * 0.2),
                  Colors.white.withOpacity(0.7 - glowValue * 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.25 + glowValue * 0.35),
                  blurRadius: 16 + glowValue * 16,
                  spreadRadius: glowValue * 6,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon Circle
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [baseColor, baseColor.withOpacity(0.8)]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      option['icon'] as IconData,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option['subtitle'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          baseColor,
                          baseColor.withOpacity(0.9 - glowValue * 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(0.4 + glowValue * 0.3),
                          blurRadius: 12 + glowValue * 8,
                          spreadRadius: glowValue * 3,
                        ),
                      ],
                    ),
                    child: Text(
                      option['buttonText'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}