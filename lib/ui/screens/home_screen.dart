import 'package:aura_health_companion/data/supabase_service.dart';
import 'package:aura_health_companion/ui/screens/chatbot_screen.dart';
import 'package:aura_health_companion/ui/screens/login_screen.dart';
import 'package:aura_health_companion/ui/screens/profile_screen.dart';
import 'package:aura_health_companion/ui/screens/services_screen.dart';
import 'package:aura_health_companion/ui/widgets/navigation_bar.dart';
import 'package:aura_health_companion/ui/widgets/soon_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 🔹 Widget Helper لبناء كروت الإحصائيات
  Widget _buildStatCard(String title, String value, String unit, Color bgColor,
      {Color textColor = Colors.black, bool isLarge = false, required IconData icon, required Color iconColor}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(3, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isLarge
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          isLarge
              ? Text(
                  "$value – You’re healthier than 95% people",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  // 🩵 Home Screen Layout
  Widget _buildHomeScreen(String userEmail) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Aura Premium Card
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 2, 17, 128), Color(0xFF1B1E36)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Aura Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Unlock AURA premium to unlock \nall features.',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (context.mounted) {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return SoonAnimation(
                                  message: 'Aura Premium is coming soon!',
                                  onComplete: () {},
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Upgrade'),
                      ),
                    ],
                  ),
                  Positioned(
                    right: -20,
                    top: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.asset(
                        'assets/animations/logo.png',
                        height: 170,
                        width: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Today’s In Section
            Text(
              "Today's In",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Day Selector Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(6, (index) {
                  final List<Map<String, String>> days = [
                    {"day": "Sat", "date": "20"},
                    {"day": "Sun", "date": "21"},
                    {"day": "Mon", "date": "22"},
                    {"day": "Tue", "date": "23"},
                    {"day": "Wed", "date": "24"},
                    {"day": "Thu", "date": "25"},
                  ];

                  final int selectedIndex = 3; // Tue 23
                  final bool isActive = index == selectedIndex;

                  return Container(
                    width: 49,
                    height: 60,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE0E7FF)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(2, 3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          days[index]['day']!,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF666666),
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          days[index]['date']!,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF666666),
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Daily Overview Cards
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                // Row 1: Dark (left), Light (right)
                _buildStatCard(
                  "Calories",
                  "620.68",
                  "kcal",
                  const Color(0xFF0F1120), // Dark
                  textColor: Colors.white,
                  icon: Ionicons.flame,
                  iconColor: const Color(0xFFFF5733), // Orange
                ),
                _buildStatCard(
                  "Heart Rate",
                  "72",
                  "bpm",
                  const Color(0xFFF9FAFB), // Light
                  icon: Ionicons.heart,
                  iconColor: const Color(0xFFEF4444), // Red
                ),
                // Row 2: Light (left), Dark (right)
                _buildStatCard(
                  "Weight",
                  "89.5",
                  "lbs",
                  const Color(0xFFF9FAFB), // Light
                  icon: Ionicons.scale,
                  iconColor: const Color(0xFF10B981), // Green
                ),
                _buildStatCard(
                  "Steps",
                  "5,423",
                  "steps",
                  const Color(0xFF0F1120), // Dark
                  textColor: Colors.white,
                  icon: Ionicons.footsteps,
                  iconColor: const Color(0xFF60A5FA), // Blue
                ),
                // Row 3: Dark (left, spans both columns for Wellness Score)
                _buildStatCard(
                  "Wellness Score",
                  "Good",
                  "You’re healthier than 95% people",
                  const Color(0xFF0F1120), // Dark
                  textColor: Colors.white,
                  isLarge: true,
                  icon: Ionicons.star,
                  iconColor: const Color(0xFFFBBF24), // Gold
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Screens list
  List<Widget> _screens(String userEmail) => [
        _buildHomeScreen(userEmail),
        const ServicesScreen(),
        const ChatbotScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final userEmail = SupabaseService.client.auth.currentUser?.email ?? 'Guest';
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text('Home'),
              actions: [
                IconButton(
                  onPressed: () async {
                    try {
                      await SupabaseService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to sign out')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            )
          : null,
      body: _screens(userEmail)[_selectedIndex],
      bottomNavigationBar: NavigationBarr(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}