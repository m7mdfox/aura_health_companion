import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class MentalSupportScreen extends StatelessWidget {
  const MentalSupportScreen({super.key});

  void _showSnackBar(BuildContext context, String message, Color color) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final supportOptions = [
      {
        "title": "Book a Session with a Therapist",
        "subtitle": "One-on-one professional support",
        "icon": Ionicons.person,
        "color": const Color(0xFFEF4444),
        "buttonText": "Book Now",
        "onTap": () => _showSnackBar(
          context,
          "Booking therapist session...",
          const Color(0xFFEF4444),
        ),
      },
      {
        "title": "Call Emergency Support Line",
        "subtitle": "24/7 immediate help",
        "icon": Ionicons.call,
        "color": const Color(0xFF3B82F6),
        "buttonText": "Call Now",
        "onTap": () => _showSnackBar(
          context,
          "Connecting to support line...",
          const Color(0xFF3B82F6),
        ),
      },
      {
        "title": "Join Support Groups",
        "subtitle": "Connect with others who understand",
        "icon": Ionicons.people,
        "color": const Color(0xFF10B981),
        "buttonText": "Join Group",
        "onTap": () => _showSnackBar(
          context,
          "Opening support groups...",
          const Color(0xFF10B981),
        ),
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Professional Support',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are not alone. Help is just a tap away.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: supportOptions.length,
                itemBuilder: (context, index) {
                  final option = supportOptions[index];
                  return _buildSupportCard(
                    context,
                    option: option,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Ionicons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF475569),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Support',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSupportCard(
    BuildContext context, {
    required Map<String, dynamic> option,
    required bool isDark,
  }) {
    final Color baseColor = option['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: option['onTap'] as void Function(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [baseColor, baseColor.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    option['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['subtitle'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [baseColor, baseColor.withOpacity(0.9)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    option['buttonText'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
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
    );
  }
}