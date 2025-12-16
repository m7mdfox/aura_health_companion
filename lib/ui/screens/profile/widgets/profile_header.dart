import 'package:flutter/material.dart';
import 'package:aura_health_companion/data/auth_service.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Build full avatar URL with proper validation
    String? fullAvatarUrl;
    if (avatarUrl != null && avatarUrl!.isNotEmpty && avatarUrl != '') {
      // Check if it's already a full URL
      if (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://')) {
        fullAvatarUrl = avatarUrl;
      } else {
        // Build full URL from base URL
        fullAvatarUrl = '${AuthService.baseUrl}$avatarUrl';
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
                  // Avatar with proper error handling
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 57,
                      backgroundColor: const Color(0xFF00177E).withOpacity(0.2),
                      backgroundImage: fullAvatarUrl != null
                        ? NetworkImage(fullAvatarUrl)
                        : null,
                      onBackgroundImageError: fullAvatarUrl != null
                        ? (exception, stackTrace) {
                            print('❌ Failed to load avatar from: $fullAvatarUrl');
                            print('Error: $exception');
                          }
                        : null,
                      child: fullAvatarUrl == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00177E),
                            ),
                          )
                        : null,
                    ),
                  ),
                  // Edit button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onEditPressed,
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
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
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
}