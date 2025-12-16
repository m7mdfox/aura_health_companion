import 'package:flutter/material.dart';
import 'package:aura_health_companion/ui/models/user_profile_model.dart';
import 'package:aura_health_companion/ui/screens/profile/pages/connected_devices.dart';
import 'package:provider/provider.dart';
import 'package:aura_health_companion/logic/auth_controller.dart';
import 'package:aura_health_companion/data/profile_service.dart';
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:aura_health_companion/ui/screens/login_screen.dart';
import 'package:aura_health_companion/ui/screens/profile/widgets/profile_stats_card.dart';
import 'package:aura_health_companion/ui/screens/profile/widgets/health_insights_card.dart';
import 'package:aura_health_companion/ui/screens/profile/widgets/profile_menu_item.dart';
import 'package:aura_health_companion/ui/screens/profile/pages/edit_profile_page.dart';
import 'package:aura_health_companion/ui/screens/profile/pages/medical_history_page.dart';
import 'package:aura_health_companion/ui/screens/profile/pages/settings_page.dart';
import 'package:aura_health_companion/ui/screens/profile/pages/about_page.dart';
import 'package:aura_health_companion/ui/screens/profile/pages/help_support_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileModel? userProfile;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('🔄 Loading profile from backend...');
      final profile = await ProfileService.getProfile();
      
      print('✅ Profile loaded successfully: ${profile.name}');
      if (mounted) {
        setState(() {
          userProfile = profile;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading profile from backend: $e');
      
      try {
        if (AuthService.profile != null) {
          print('🔄 Trying fallback to local profile...');
          final profile = UserProfileModel.fromJson(AuthService.profile!);
          print('✅ Local profile loaded: ${profile.name}');
          
          if (mounted) {
            setState(() {
              userProfile = profile;
              isLoading = false;
              errorMessage = null;
            });
          }
        } else {
          print('❌ No local profile available');
          if (mounted) {
            setState(() {
              errorMessage = 'No profile data available. Please try logging in again.';
              isLoading = false;
            });
          }
        }
      } catch (parseError) {
        print('❌ Error parsing local profile: $parseError');
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load profile. Please try logging in again.';
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your profile...'),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null || userProfile == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage ?? 'Failed to load profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loadUserProfile,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00177E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(userProfile!),
              
              ProfileStatsCard(
                streakDays: userProfile!.streakDays,
                totalPoints: userProfile!.totalPoints,
                completedChallenges: userProfile!.completedChallenges,
              ),
              
              HealthInsightsCard(
                weight: userProfile!.weight,
                height: userProfile!.height,
                bmi: userProfile!.bmi,
                bmiCategory: userProfile!.bmiCategory,
                bloodType: userProfile!.bloodType,
              ),
              
              const SizedBox(height: 20),
              
              _buildMenuSection(context),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileModel profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String? avatarUrl;
    if (profile.avatarUrl != null && 
        profile.avatarUrl!.isNotEmpty && 
        profile.avatarUrl != '') {
      if (profile.avatarUrl!.startsWith('http://') || 
          profile.avatarUrl!.startsWith('https://')) {
        avatarUrl = profile.avatarUrl;
      } else {
        avatarUrl = '${AuthService.baseUrl}${profile.avatarUrl}';
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF1A1D2E), const Color(0xFF0F1120)]
            : [const Color(0xFF00177E), const Color(0xFF0F1120)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 57,
                      backgroundColor: const Color(0xFF00177E).withOpacity(0.2),
                      backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl) as ImageProvider
                        : null,
                      onBackgroundImageError: avatarUrl != null
                        ? (exception, stackTrace) {
                            print('❌ Failed to load avatar: $exception');
                          }
                        : null,
                      child: avatarUrl == null
                        ? Text(
                            profile.name.isNotEmpty 
                              ? profile.name[0].toUpperCase() 
                              : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00177E),
                            ),
                          )
                        : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _navigateToEditProfile,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Color(0xFF00177E),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        children: [
          _buildSectionTitle('Account'),
          ProfileMenuItem(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal info',
            iconColor: const Color(0xFF00177E),
            onTap: _navigateToEditProfile,
          ),
          ProfileMenuItem(
            icon: Icons.medical_information,
            title: 'Medical History',
            subtitle: 'View your health records',
            iconColor: const Color(0xFFE91E63),
            onTap: _navigateToMedicalHistory,
          ),
          
          _buildSectionTitle('Preferences'),
          ProfileMenuItem(
            icon: Icons.watch,
            title: 'Connected Devices',
            subtitle: 'Manage smartwatch & wearables',
            iconColor: const Color(0xFF607D8B),
            onTap: _navigateToDevices,
          ),
          ProfileMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App settings & preferences',
            iconColor: const Color(0xFF9C27B0),
            onTap: _navigateToSettings,
          ),
          
          _buildSectionTitle('Support'),
          ProfileMenuItem(
            icon: Icons.help_center,
            title: 'Help & Support',
            subtitle: 'FAQ and contact us',
            iconColor: const Color(0xFF009688),
            onTap: _navigateToSupport,
          ),
          ProfileMenuItem(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App info & version',
            iconColor: const Color(0xFF3F51B5),
            onTap: _navigateToAbout,
          ),
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            iconColor: const Color(0xFFE53935),
            onTap: _handleLogout,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _navigateToEditProfile() async {
    if (userProfile == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userProfile: userProfile!),
      ),
    );
    
    if (result != null && result is UserProfileModel) {
      setState(() {
        userProfile = result;
      });
      
      await AuthService.updateProfileInSession(result.toJson());
    }
  }

  void _navigateToMedicalHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicalHistoryPage(),
      ),
    );
  }

  void _navigateToDevices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConnectedDevicesPage(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _navigateToSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpSupportPage(),
      ),
    );
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutPage(),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await AuthService.logout();
                
                if (mounted) {
                  final authController = Provider.of<AuthController>(context, listen: false);
                  authController.notifyAuthChange();
                  
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}