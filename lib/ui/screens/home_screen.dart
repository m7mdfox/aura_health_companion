import 'dart:async';
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:aura_health_companion/data/vital_simulator.dart';
import 'package:aura_health_companion/ui/screens/chatbot/chatbot_screen.dart';
import 'package:aura_health_companion/ui/screens/profile/profile_screen.dart';
import 'package:aura_health_companion/ui/screens/services_screen.dart';
import 'package:aura_health_companion/ui/widgets/navigation_bar.dart';
import 'package:aura_health_companion/ui/widgets/soon_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const int heartRateLowThreshold = 40;
const int heartRateHighThreshold = 120;
const int oxygenLowThreshold = 90;
DateTime _lastAlertCheck = DateTime.now().subtract(const Duration(minutes: 5));

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final VitalSimulator _vitalSimulator = VitalSimulator();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });

    // Start vital monitoring
    _vitalSimulator.simulateVitals().listen((vitals) {
      _checkVitals(vitals);
    });
  }

  void _checkVitals(Map<String, dynamic> vitals) async {
    final int heartRate = vitals['heartRate'] ?? 0;
    final int oxygen = vitals['spo2'] ?? 0;

    String? alertMessage;

    if (heartRate < heartRateLowThreshold) {
      alertMessage = 'Heart rate is too low: $heartRate bpm';
    } else if (heartRate > heartRateHighThreshold) {
      alertMessage = 'Heart rate is too high: $heartRate bpm';
    } else if (oxygen < oxygenLowThreshold) {
      alertMessage = 'Oxygen level is low: $oxygen%';
    }

    if (alertMessage != null && mounted) {
      final now = DateTime.now();

      if (now.difference(_lastAlertCheck) >= const Duration(minutes: 5)) {
        _lastAlertCheck = now;
        _showAlert(alertMessage);
      }
    }
  }

  void _callNumber(String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    try {
      if (!await launchUrl(callUri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch call')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching call: $e')),
        );
      }
    }
  }

  void _showAlert(String message) {
    final emergencyContact = AuthService.profile?['emergency_contact'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Vital Alert'),
        content: Text(message),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.call),
            label: const Text('Call Help'),
            onPressed: () {
              Navigator.pop(context);
              _callNumber('01097699663');
            },
          ),
          if (emergencyContact.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.contact_phone),
              label: const Text('Call Emergency Contact'),
              onPressed: () {
                Navigator.pop(context);
                _callNumber(emergencyContact);
              },
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _vitalSimulator.dispose();
    super.dispose();
  }

  Widget _buildVitalStats(bool isDark) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _vitalSimulator.simulateVitals(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? Colors.white : const Color(0xFF00177E),
            ),
          );
        }

        final vitals = snapshot.data!;
        return Column(
          children: [
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  "Heart Rate",
                  vitals['heartRate']?.toString() ?? "0",
                  "bpm",
                  isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF9FAFB),
                  textColor: isDark ? Colors.white : Colors.black,
                  icon: Ionicons.heart,
                  iconColor: const Color(0xFFEF4444),
                  isDark: isDark,
                ),
                _buildStatCard(
                  "Calories",
                  vitals['caloriesBurnt']?.toString() ?? "0",
                  "kcal",
                  isDark ? const Color(0xFF1A1D2E) : const Color(0xFF0F1120),
                  textColor: Colors.white,
                  icon: Ionicons.flame,
                  iconColor: const Color(0xFFFF5733),
                  isDark: isDark,
                ),
                _buildStatCard(
                  "Steps",
                  vitals['steps']?.toString() ?? "0",
                  "steps",
                  isDark ? const Color(0xFF1A1D2E) : const Color(0xFF0F1120),
                  textColor: Colors.white,
                  icon: Ionicons.footsteps,
                  iconColor: const Color(0xFF60A5FA),
                  isDark: isDark,
                ),
                _buildStatCard(
                  "Oxygen Level",
                  vitals['spo2']?.toString() ?? "0",
                  "%",
                  isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF9FAFB),
                  textColor: isDark ? Colors.white : Colors.black,
                  iconWidget: Image.asset(
                    'assets/oxygen-tank.png',
                    width: 20,
                    height: 20,
                    color: const Color(0xFF10B981),
                  ),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              "Wellness Score",
              "Good",
              "You're healthier than 95% people",
              isDark ? const Color(0xFF1A1D2E) : const Color(0xFF0F1120),
              textColor: Colors.white,
              isLarge: true,
              icon: Ionicons.star,
              iconColor: const Color(0xFFFBBF24),
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    Color bgColor, {
    Color textColor = Colors.black,
    bool isLarge = false,
    Widget? iconWidget,
    IconData? icon,
    Color? iconColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.1),
            offset: const Offset(3, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isLarge ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (iconWidget != null)
                iconWidget
              else if (icon != null)
                Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          isLarge
              ? Text(
                  "$value – You're healthier than 95% people",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
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

  Widget _buildHomeScreen(String userName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF1A1D2E), const Color(0xFF2D1B69)]
                    : [const Color(0xFF00177E), const Color(0xFF1B1E36)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF2D1B69) : const Color(0xFF00177E))
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
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
                        'Get AURA Premium to unlock \nall features.',
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
                      opacity: 0.2,
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
            Text(
              "Today's In",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
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
                  const int selectedIndex = 3;
                  final bool isActive = index == selectedIndex;
                  return Container(
                    width: 49,
                    height: 60,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark ? const Color(0xFF2D1B69) : const Color(0xFFE0E7FF))
                          : (isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF5F5F5)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.2),
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
                                ? (isDark ? Colors.white : const Color(0xFF3B82F6))
                                : (isDark ? Colors.white54 : const Color(0xFF666666)),
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
                                ? (isDark ? Colors.white : const Color(0xFF3B82F6))
                                : (isDark ? Colors.white54 : const Color(0xFF666666)),
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
            _buildVitalStats(isDark),
          ],
        ),
      ),
    );
  }

  List<Widget> _screens(String userName) => [
        _buildHomeScreen(userName),
        const ServicesScreen(),
        ChatbotScreen(
          key: const ValueKey("chatbot_screen"),
          userName: userName,
        ),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.profile?['full_name'] ?? 'Guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
              elevation: 0,
              title: Text(
                '$userName 👋',
                style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.account_circle_rounded,
                    color: isDark ? Colors.white : const Color(0xFF00177E),
                    size: 32,
                  ),
                  tooltip: 'Profile',
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: _screens(userName)[_selectedIndex],
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