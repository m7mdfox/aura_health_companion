import 'dart:math';
import 'package:flutter/material.dart';

enum PowerUpType {
  shield,    // درع - يحمي من ضربة
  speed,     // سرعة - يزيد السرعة
  damage,    // ضرر - ضربة مضاعفة
  health,    // صحة - يزيد القلوب
}

class PowerUp {
  double x;
  double y;
  final PowerUpType type;
  double width = 35;
  double height = 35;
  bool isCollected = false;
  bool isActive = true;
  
  // Animation properties
  double floatOffset = 0;
  double rotationAngle = 0;
  double pulseScale = 1.0;
  double glowIntensity = 0;
  
  // Particles
  List<PowerUpParticle> particles = [];
  double particleTimer = 0;
  
  // Spawn animation
  double spawnScale = 0;
  double spawnRotation = 0;
  bool hasSpawned = false;
  
  PowerUp({
    required this.x,
    required this.y,
    required this.type,
  });
  
  void update(double deltaTime) {
    if (isCollected) {
      // Collection animation
      width *= 0.95;
      height *= 0.95;
      y -= deltaTime * 100;
      rotationAngle += deltaTime * 10;
      
      if (width < 5) isActive = false;
      return;
    }
    
    // Spawn animation
    if (!hasSpawned) {
      spawnScale += deltaTime * 5;
      spawnRotation += deltaTime * 8;
      
      if (spawnScale >= 1.0) {
        spawnScale = 1.0;
        hasSpawned = true;
      }
      return;
    }
    
    // Float animation
    floatOffset += deltaTime * 3;
    final originalY = y;
    y = originalY + sin(floatOffset) * 8;
    
    // Rotation animation
    rotationAngle += deltaTime * 2;
    if (rotationAngle > 2 * pi) rotationAngle -= 2 * pi;
    
    // Pulse animation
    pulseScale = 1.0 + sin(floatOffset * 2) * 0.15;
    
    // Glow animation
    glowIntensity = 0.5 + sin(floatOffset * 1.5) * 0.5;
    
    // Generate particles
    particleTimer += deltaTime;
    if (particleTimer > 0.1) {
      particleTimer = 0;
      _generateParticle();
    }
    
    // Update particles
    particles.removeWhere((p) => p.isDead);
    for (var particle in particles) {
      particle.update(deltaTime);
    }
  }
  
  void _generateParticle() {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final speed = 20 + random.nextDouble() * 30;
    
    particles.add(PowerUpParticle(
      x: x + width / 2,
      y: y + height / 2,
      velocityX: cos(angle) * speed,
      velocityY: sin(angle) * speed,
      color: getColor(),
      size: 3 + random.nextDouble() * 3,
      lifetime: 0.5 + random.nextDouble() * 0.5,
    ));
  }
  
  bool collidesWith(double px, double py, double pw, double ph) {
    if (isCollected || !hasSpawned) return false;
    
    return px < x + width &&
           px + pw > x &&
           py < y + height &&
           py + ph > y;
  }
  
  void collect() {
    isCollected = true;
    
    // Create collection burst
    final random = Random();
    for (int i = 0; i < 20; i++) {
      final angle = (i * 2 * pi / 20);
      final speed = 100 + random.nextDouble() * 100;
      
      particles.add(PowerUpParticle(
        x: x + width / 2,
        y: y + height / 2,
        velocityX: cos(angle) * speed,
        velocityY: sin(angle) * speed,
        color: getColor(),
        size: 4 + random.nextDouble() * 4,
        lifetime: 0.8 + random.nextDouble() * 0.4,
      ));
    }
  }
  
  Color getColor() {
    switch (type) {
      case PowerUpType.shield:
        return const Color(0xFF3B82F6); // Blue
      case PowerUpType.speed:
        return const Color(0xFF10B981); // Green
      case PowerUpType.damage:
        return const Color(0xFFEF4444); // Red
      case PowerUpType.health:
        return const Color(0xFFF59E0B); // Orange
    }
  }
  
  Color getSecondaryColor() {
    switch (type) {
      case PowerUpType.shield:
        return const Color(0xFF1E40AF);
      case PowerUpType.speed:
        return const Color(0xFF059669);
      case PowerUpType.damage:
        return const Color(0xFFDC2626);
      case PowerUpType.health:
        return const Color(0xFFD97706);
    }
  }
  
  String getName() {
    switch (type) {
      case PowerUpType.shield:
        return 'درع';
      case PowerUpType.speed:
        return 'سرعة';
      case PowerUpType.damage:
        return 'قوة';
      case PowerUpType.health:
        return 'صحة';
    }
  }
  
  String getDescription() {
    switch (type) {
      case PowerUpType.shield:
        return 'يحميك من ضربة واحدة';
      case PowerUpType.speed:
        return 'يزيد سرعتك 1.5x';
      case PowerUpType.damage:
        return 'ضربتك تصبح 2x';
      case PowerUpType.health:
        return 'يزيد 2 قلوب';
    }
  }
  
  IconData getIcon() {
    switch (type) {
      case PowerUpType.shield:
        return Icons.shield_rounded;
      case PowerUpType.speed:
        return Icons.flash_on_rounded;
      case PowerUpType.damage:
        return Icons.whatshot_rounded;
      case PowerUpType.health:
        return Icons.favorite_rounded;
    }
  }
  
  double getDuration() {
    switch (type) {
      case PowerUpType.shield:
        return 10.0;
      case PowerUpType.speed:
        return 8.0;
      case PowerUpType.damage:
        return 10.0;
      case PowerUpType.health:
        return 0.0; // Instant effect
    }
  }
}

class PowerUpParticle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  Color color;
  double size;
  double lifetime;
  double age = 0;
  bool isDead = false;
  double rotation = 0;
  
  PowerUpParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.lifetime,
  }) {
    rotation = Random().nextDouble() * 2 * pi;
  }
  
  void update(double deltaTime) {
    age += deltaTime;
    if (age >= lifetime) {
      isDead = true;
      return;
    }
    
    x += velocityX * deltaTime;
    y += velocityY * deltaTime;
    
    // Gravity effect
    velocityY += 150 * deltaTime;
    
    // Air resistance
    velocityX *= 0.97;
    velocityY *= 0.97;
    
    // Rotation
    rotation += deltaTime * 5;
  }
  
  double getOpacity() {
    return (1 - age / lifetime).clamp(0.0, 1.0);
  }
  
  double getSize() {
    final progress = age / lifetime;
    if (progress < 0.3) {
      return size * (progress / 0.3);
    }
    return size * (1 - progress);
  }
}

// PowerUp Manager Class
class PowerUpManager {
  List<PowerUp> powerUps = [];
  
  void addPowerUp(double x, double y, PowerUpType type) {
    powerUps.add(PowerUp(x: x, y: y, type: type));
  }
  
  void update(double deltaTime) {
    powerUps.removeWhere((p) => !p.isActive);
    for (var powerUp in powerUps) {
      powerUp.update(deltaTime);
    }
  }
  
  PowerUp? checkCollision(double px, double py, double pw, double ph) {
    for (var powerUp in powerUps) {
      if (powerUp.collidesWith(px, py, pw, ph)) {
        return powerUp;
      }
    }
    return null;
  }
  
  void clear() {
    powerUps.clear();
  }
  
  // Generate random power-ups for level
  void generateForLevel(double levelWidth, List<dynamic> platforms) {
    powerUps.clear();
    final random = Random();
    final types = PowerUpType.values;
    
    // Generate 8-12 power-ups
    final count = 8 + random.nextInt(5);
    
    for (int i = 0; i < count; i++) {
      final x = 400 + (levelWidth - 800) * (i / count) + random.nextDouble() * 200;
      final y = 200 + random.nextDouble() * 100;
      final type = types[random.nextInt(types.length)];
      
      addPowerUp(x, y, type);
    }
  }
  
  int getActiveCount() {
    return powerUps.where((p) => !p.isCollected && p.hasSpawned).length;
  }
  
  int getCollectedCount() {
    return powerUps.where((p) => p.isCollected).length;
  }
}

// PowerUp Info Widget - for UI display
class PowerUpInfoWidget extends StatelessWidget {
  final PowerUpType type;
  final double timeLeft;
  final bool isActive;
  
  const PowerUpInfoWidget({
    super.key,
    required this.type,
    required this.timeLeft,
    this.isActive = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final powerUp = PowerUp(x: 0, y: 0, type: type);
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            powerUp.getColor().withOpacity(isActive ? 0.9 : 0.4),
            powerUp.getSecondaryColor().withOpacity(isActive ? 0.8 : 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(isActive ? 0.4 : 0.2),
          width: 2,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: powerUp.getColor().withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ] : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            powerUp.getIcon(),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          if (timeLeft > 0) ...[
            Text(
              '${timeLeft.toInt()}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// PowerUp Collection Notification Widget
class PowerUpNotification extends StatefulWidget {
  final PowerUpType type;
  final VoidCallback onDismiss;
  
  const PowerUpNotification({
    super.key,
    required this.type,
    required this.onDismiss,
  });
  
  @override
  State<PowerUpNotification> createState() => _PowerUpNotificationState();
}

class _PowerUpNotificationState extends State<PowerUpNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -200,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3),
    ));
    
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _controller.reverse().then((_) => widget.onDismiss());
        }
      });
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final powerUp = PowerUp(x: 0, y: 0, type: widget.type);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    powerUp.getColor(),
                    powerUp.getSecondaryColor(),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: powerUp.getColor().withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      powerUp.getIcon(),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'حصلت على ${powerUp.getName()}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        powerUp.getDescription(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.yellow,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}