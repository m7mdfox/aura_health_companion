import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/platform.dart';
import '../models/powerup.dart';
import 'dart:math' as math;

class EnhancedGameCanvas extends CustomPainter {
  final Player player;
  final List<Enemy> enemies;
  final List<Platform> platforms;
  final List<PowerUp> powerUps;
  final double cameraOffsetX;
  final double cameraShakeX;
  final double cameraShakeY;
  final double cloudsOffset;
  
  EnhancedGameCanvas({
    required this.player,
    required this.enemies,
    required this.platforms,
    required this.powerUps,
    required this.cameraOffsetX,
    required this.cameraShakeX,
    required this.cameraShakeY,
    required this.cloudsOffset,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(cameraShakeX, cameraShakeY);
    
    // Animated Sky with gradient
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0A1128),
        const Color(0xFF1E3A5F),
        const Color(0xFF2B5876),
        const Color(0xFF4E9FD1),
        const Color(0xFF87CEEB),
      ],
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.7),
      Paint()..shader = skyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.7)),
    );
    
    // Animated sun with rays
    _drawAnimatedSun(canvas, size);
    
    // Far mountains with depth
    _drawDistantMountains(canvas, size);
    
    // Animated clouds
    _drawMovingClouds(canvas, size);
    
    canvas.save();
    canvas.translate(cameraOffsetX, 0);
    
    // Mid-layer mountains
    _drawMidMountains(canvas, size);
    
    // Ground with rich gradient and texture
    _drawEnhancedGround(canvas, size);
    
    // Platforms with 3D effect
    for (var platform in platforms) {
      if (!platform.isActive) continue;
      _drawEnhancedPlatform(canvas, platform);
    }
    
    // Power-ups with glow
    for (var powerUp in powerUps) {
      if (!powerUp.isCollected) {
        _drawPowerUp(canvas, powerUp);
      }
    }
    
    // Enemies with enhanced graphics
    for (var enemy in enemies) {
      if (!enemy.isActive || enemy.isDead) continue;
      _drawEnhancedEnemy(canvas, enemy);
    }
    
    // Player particles
    _drawPlayerParticles(canvas, player);
    
    // Player with enhanced sprite
    _drawEnhancedPlayer(canvas, player);
    
    // Player effects (shield, speed lines, etc)
    _drawPlayerEffects(canvas, player);
    
    canvas.restore();
    canvas.restore();
  }
  
  void _drawAnimatedSun(Canvas canvas, Size size) {
    final sunPos = Offset(size.width * 0.82, 70);
    
    // Sun rays
    final rayPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.2)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8) + (DateTime.now().millisecondsSinceEpoch / 1000.0);
      final endX = sunPos.dx + math.cos(angle) * 65;
      final endY = sunPos.dy + math.sin(angle) * 65;
      canvas.drawLine(sunPos, Offset(endX, endY), rayPaint);
    }
    
    // Sun glow layers
    for (int i = 3; i > 0; i--) {
      canvas.drawCircle(
        sunPos,
        40 + (i * 15),
        Paint()..color = Colors.yellow.withOpacity(0.15 / i)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }
    
    // Sun core
    canvas.drawCircle(sunPos, 40, Paint()
      ..shader = RadialGradient(
        colors: [Colors.yellow, Colors.orange.shade600],
      ).createShader(Rect.fromCircle(center: sunPos, radius: 40)));
  }
  
  void _drawDistantMountains(Canvas canvas, Size size) {
    final distantPaint = Paint()..color = const Color(0xFF2C3E50).withOpacity(0.3);
    
    final path1 = Path();
    path1.moveTo(0, 220);
    path1.lineTo(200, 140);
    path1.lineTo(400, 180);
    path1.lineTo(600, 120);
    path1.lineTo(800, 200);
    path1.lineTo(800, 220);
    path1.close();
    canvas.drawPath(path1, distantPaint);
  }
  
  void _drawMidMountains(Canvas canvas, Size size) {
    final midPaint = Paint()..color = const Color(0xFF34495E).withOpacity(0.5);
    
    final path = Path();
    path.moveTo(0, 250);
    path.lineTo(400, 150);
    path.lineTo(800, 200);
    path.lineTo(1200, 160);
    path.lineTo(1600, 220);
    path.lineTo(2000, 180);
    path.lineTo(2400, 240);
    path.lineTo(2800, 200);
    path.lineTo(3200, 250);
    path.lineTo(3200, 280);
    path.lineTo(0, 280);
    path.close();
    canvas.drawPath(path, midPaint);
  }
  
  void _drawMovingClouds(Canvas canvas, Size size) {
    void drawCloud(double x, double y, double scale) {
      final cloudPaint = Paint()..color = Colors.white.withOpacity(0.8);
      
      canvas.drawCircle(Offset(x, y), 20 * scale, cloudPaint);
      canvas.drawCircle(Offset(x + 25 * scale, y), 28 * scale, cloudPaint);
      canvas.drawCircle(Offset(x + 50 * scale, y), 22 * scale, cloudPaint);
      canvas.drawCircle(Offset(x + 25 * scale, y - 12 * scale), 18 * scale, cloudPaint);
    }
    
    // Multiple cloud layers moving at different speeds
    canvas.save();
    drawCloud((size.width * 0.1 + cloudsOffset * 0.3) % size.width, 90, 1.0);
    drawCloud((size.width * 0.4 + cloudsOffset * 0.5) % size.width, 130, 0.8);
    drawCloud((size.width * 0.65 + cloudsOffset * 0.4) % size.width, 110, 1.2);
    drawCloud((size.width * 0.85 + cloudsOffset * 0.6) % size.width, 95, 0.9);
    canvas.restore();
  }
  
  void _drawEnhancedGround(Canvas canvas, Size size) {
    final groundY = 380.0;
    
    // Ground gradient with layers
    final groundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF16A34A),
        const Color(0xFF15803D),
        const Color(0xFF166534),
        const Color(0xFF14532D),
      ],
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, 5000, 220),
      Paint()..shader = groundGradient.createShader(Rect.fromLTWH(0, groundY, 5000, 220)),
    );
    
    // Grass blades with variety
    final grassPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    for (double x = 0; x < 5000; x += 10) {
      final variation = (x % 40) / 40;
      grassPaint.color = Color.lerp(
        const Color(0xFF166534),
        const Color(0xFF16A34A),
        variation,
      )!;
      
      final height = 8 + (x % 30 == 0 ? 6 : 0);
      final sway = math.sin((x + cloudsOffset) / 30) * 2;
      
      canvas.drawLine(
        Offset(x, groundY),
        Offset(x + sway, groundY + height),
        grassPaint,
      );
    }
    
    // Flowers scattered
    for (double x = 50; x < 5000; x += 180) {
      _drawDetailedFlower(canvas, x, groundY);
    }
    
    // Rocks for detail
    for (double x = 100; x < 5000; x += 250) {
      _drawRock(canvas, x, groundY);
    }
  }
  
  void _drawDetailedFlower(Canvas canvas, double x, double y) {
    // Stem
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y + 18),
      Paint()
        ..color = const Color(0xFF16A34A)
        ..strokeWidth = 2.5,
    );
    
    // Petals with gradient
    final petalColors = [Colors.red, Colors.pink, Colors.purple, Colors.yellow, Colors.orange];
    final petalColor = petalColors[(x ~/ 180) % petalColors.length];
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * math.pi / 6);
      final petalX = x + 6 * math.cos(angle);
      final petalY = y + 6 * math.sin(angle);
      
      canvas.drawCircle(
        Offset(petalX, petalY),
        4,
        Paint()..color = petalColor,
      );
    }
    
    // Center
    canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = Colors.yellow.shade700);
  }
  
  void _drawRock(Canvas canvas, double x, double y) {
    final rockPath = Path();
    rockPath.addOval(Rect.fromLTWH(x, y, 25, 15));
    
    canvas.drawPath(
      rockPath,
      Paint()..color = const Color(0xFF6B7280),
    );
    
    canvas.drawPath(
      rockPath,
      Paint()
        ..color = const Color(0xFF9CA3AF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
  
  void _drawEnhancedPlatform(Canvas canvas, Platform platform) {
    // Shadow with blur
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(platform.x + 4, platform.y + 4, platform.width, platform.height),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    
    // Platform with wood texture
    final platformGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFA0522D),
        const Color(0xFF8B4513),
        const Color(0xFF654321),
        const Color(0xFF4A3016),
      ],
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(platform.x, platform.y, platform.width, platform.height),
        const Radius.circular(10),
      ),
      Paint()..shader = platformGradient.createShader(
        Rect.fromLTWH(platform.x, platform.y, platform.width, platform.height),
      ),
    );
    
    // Highlight edge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(platform.x, platform.y, platform.width, 4),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFCD853F),
    );
    
    // Wood grain lines
    final grainPaint = Paint()
      ..color = const Color(0xFF5D4037).withOpacity(0.3)
      ..strokeWidth = 1;
    
    for (double i = platform.x + 20; i < platform.x + platform.width - 20; i += 30) {
      canvas.drawLine(
        Offset(i, platform.y + 2),
        Offset(i, platform.y + platform.height - 2),
        grainPaint,
      );
    }
  }
  
  void _drawPowerUp(Canvas canvas, PowerUp powerUp) {
    // Draw power-up particles first
    for (var particle in powerUp.particles) {
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        Paint()..color = powerUp.getColor().withOpacity(particle.getOpacity()),
      );
    }
    
    // Glow effect
    for (int i = 3; i > 0; i--) {
      canvas.drawCircle(
        Offset(powerUp.x + powerUp.width / 2, powerUp.y + powerUp.height / 2),
        powerUp.width / 2 + (i * 8),
        Paint()
          ..color = powerUp.getColor().withOpacity(0.2 / i)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    
    // Rotating outer ring
    canvas.save();
    canvas.translate(powerUp.x + powerUp.width / 2, powerUp.y + powerUp.height / 2);
    canvas.rotate(powerUp.rotationAngle);
    
    final ringPaint = Paint()
      ..color = powerUp.getColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(Offset.zero, powerUp.width / 2 + 5, ringPaint);
    
    canvas.restore();
    
    // Power-up icon background
    canvas.drawCircle(
      Offset(powerUp.x + powerUp.width / 2, powerUp.y + powerUp.height / 2),
      powerUp.width / 2,
      Paint()..shader = RadialGradient(
        colors: [
          powerUp.getColor().withOpacity(0.9),
          powerUp.getColor(),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(powerUp.x + powerUp.width / 2, powerUp.y + powerUp.height / 2),
          radius: powerUp.width / 2,
        ),
      ),
    );
    
    // Draw icon based on type
    _drawPowerUpIcon(canvas, powerUp);
  }
  
  void _drawPowerUpIcon(Canvas canvas, PowerUp powerUp) {
    final center = Offset(powerUp.x + powerUp.width / 2, powerUp.y + powerUp.height / 2);
    final iconPaint = Paint()..color = Colors.white;
    
    switch (powerUp.type) {
      case PowerUpType.shield:
        // Shield icon
        final shieldPath = Path();
        shieldPath.moveTo(center.dx, center.dy - 12);
        shieldPath.lineTo(center.dx + 10, center.dy - 8);
        shieldPath.lineTo(center.dx + 10, center.dy + 5);
        shieldPath.lineTo(center.dx, center.dy + 12);
        shieldPath.lineTo(center.dx - 10, center.dy + 5);
        shieldPath.lineTo(center.dx - 10, center.dy - 8);
        shieldPath.close();
        canvas.drawPath(shieldPath, iconPaint);
        break;
        
      case PowerUpType.speed:
        // Lightning bolt
        final boltPath = Path();
        boltPath.moveTo(center.dx - 5, center.dy - 12);
        boltPath.lineTo(center.dx + 8, center.dy - 12);
        boltPath.lineTo(center.dx - 2, center.dy);
        boltPath.lineTo(center.dx + 5, center.dy);
        boltPath.lineTo(center.dx - 8, center.dy + 12);
        boltPath.lineTo(center.dx + 2, center.dy);
        boltPath.close();
        canvas.drawPath(boltPath, iconPaint);
        break;
        
      case PowerUpType.damage:
        // Fist/Star burst
        for (int i = 0; i < 8; i++) {
          final angle = (i * math.pi / 4);
          canvas.drawLine(
            center,
            Offset(center.dx + math.cos(angle) * 10, center.dy + math.sin(angle) * 10),
            Paint()..color = Colors.white..strokeWidth = 3..strokeCap = StrokeCap.round,
          );
        }
        canvas.drawCircle(center, 4, iconPaint);
        break;
        
      case PowerUpType.health:
        // Heart
        final heartPath = Path();
        heartPath.moveTo(center.dx, center.dy + 8);
        heartPath.cubicTo(
          center.dx - 12, center.dy - 5,
          center.dx - 12, center.dy - 10,
          center.dx, center.dy - 5,
        );
        heartPath.cubicTo(
          center.dx + 12, center.dy - 10,
          center.dx + 12, center.dy - 5,
          center.dx, center.dy + 8,
        );
        canvas.drawPath(heartPath, iconPaint);
        break;
    }
  }
  
  void _drawPlayerParticles(Canvas canvas, Player player) {
    for (var particle in player.particles) {
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        Paint()..color = particle.color.withOpacity(particle.getOpacity()),
      );
    }
  }
  
  void _drawPlayerEffects(Canvas canvas, Player player) {
    final center = Offset(player.x + player.width / 2, player.y + player.height / 2);
    
    // Shield effect
    if (player.hasShield) {
      final shieldPaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(
          center,
          player.width / 2 + 15 + (i * 5),
          shieldPaint..color = Colors.blue.withOpacity(0.3 - i * 0.1),
        );
      }
    }
    
    // Speed boost effect (motion lines)
    if (player.hasSpeedBoost) {
      final speedPaint = Paint()
        ..color = Colors.green.withOpacity(0.5)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      
      for (int i = 0; i < 5; i++) {
        final offsetX = player.isFacingRight ? -20 - (i * 8) : 20 + (i * 8);
        canvas.drawLine(
          Offset(player.x + player.width / 2 + offsetX, player.y + 15 + (i * 10)),
          Offset(player.x + player.width / 2 + offsetX - 15, player.y + 15 + (i * 10)),
          speedPaint..color = Colors.green.withOpacity(0.5 - i * 0.1),
        );
      }
    }
    
    // Double damage effect (red aura)
    if (player.hasDoubleDamage) {
      canvas.drawCircle(
        center,
        player.width / 2 + 12,
        Paint()
          ..color = Colors.red.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }
  }
  
  void _drawEnhancedPlayer(Canvas canvas, Player player) {
    canvas.save();
    
    if (!player.isFacingRight) {
      canvas.translate(player.x + player.width, player.y);
      canvas.scale(-1, 1);
    } else {
      canvas.translate(player.x, player.y);
    }
    
    final w = player.width;
    final h = player.height;
    final pixel = w / 12;
    
    // Shadow under player
    canvas.drawOval(
      Rect.fromLTWH(-5, h, w + 10, 8),
      Paint()..color = Colors.black.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    
    // Overall (Blue) with shine
    final overallGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
    );
    
    final overallPath = Path();
    overallPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.4, w * 0.6, h * 0.45),
      const Radius.circular(6),
    ));
    canvas.drawPath(
      overallPath,
      Paint()..shader = overallGradient.createShader(Rect.fromLTWH(w * 0.2, h * 0.4, w * 0.6, h * 0.45)),
    );
    
    // Suspenders with gradient
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.35, pixel * 0.8, h * 0.3),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF1E40AF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.6, h * 0.35, pixel * 0.8, h * 0.3),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF1E40AF),
    );
    
    // Shiny gold buttons
    for (var btnY in [h * 0.45, h * 0.55]) {
      canvas.drawCircle(
        Offset(w * 0.35, btnY),
        pixel * 0.6,
        Paint()..shader = RadialGradient(
          colors: [const Color(0xFFFCD34D), const Color(0xFFF59E0B)],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.35, btnY), radius: pixel * 0.6)),
      );
      canvas.drawCircle(
        Offset(w * 0.65, btnY),
        pixel * 0.6,
        Paint()..shader = RadialGradient(
          colors: [const Color(0xFFFCD34D), const Color(0xFFF59E0B)],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.65, btnY), radius: pixel * 0.6)),
      );
    }
    
    // Shirt (Red) with gradient
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.28, w * 0.7, h * 0.25),
        const Radius.circular(8),
      ),
      Paint()..shader = LinearGradient(
        colors: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.28, w * 0.7, h * 0.25)),
    );
    
    // Head with better shading
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.18),
      w * 0.28,
      Paint()..shader = RadialGradient(
        colors: [const Color(0xFFFFE4C4), const Color(0xFFFFD4A3)],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.18), radius: w * 0.28)),
    );
    
    // Hair/Hat
    final hairPath = Path();
    hairPath.addOval(Rect.fromLTWH(w * 0.25, h * 0.03, w * 0.5, h * 0.18));
    canvas.drawPath(hairPath, Paint()..color = const Color(0xFF92400E));
    
    // Hat brim with shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.15, w * 0.6, h * 0.05),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFF78350F),
    );
    
    // Eyes with shine
    // White base
    canvas.drawCircle(Offset(w * 0.38, h * 0.18), pixel * 0.9, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.62, h * 0.18), pixel * 0.9, Paint()..color = Colors.white);
    
    // Blue pupils
    canvas.drawCircle(Offset(w * 0.38, h * 0.18), pixel * 0.6, Paint()..color = const Color(0xFF3B82F6));
    canvas.drawCircle(Offset(w * 0.62, h * 0.18), pixel * 0.6, Paint()..color = const Color(0xFF3B82F6));
    
    // Eye shine
    canvas.drawCircle(Offset(w * 0.37, h * 0.17), pixel * 0.3, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.61, h * 0.17), pixel * 0.3, Paint()..color = Colors.white);
    
    // Beard
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.23, w * 0.4, h * 0.12),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.black,
    );
    
    // Nose
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.22),
      pixel * 0.7,
      Paint()..color = const Color(0xFFFFB088),
    );
    
    // Arms with better animation
    if (player.isPunching) {
      // Extended punching arm
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.75, h * 0.32, w * 0.4, h * 0.12),
          const Radius.circular(6),
        ),
        Paint()..shader = RadialGradient(
          colors: [Colors.white, Colors.grey.shade300],
        ).createShader(Rect.fromLTWH(w * 0.75, h * 0.32, w * 0.4, h * 0.12)),
      );
      
      // Fist
      canvas.drawCircle(
        Offset(w * 1.1, h * 0.38),
        pixel * 1.3,
        Paint()..color = Colors.white,
      );
      
      // Impact lines
      for (int i = 0; i < 3; i++) {
        canvas.drawLine(
          Offset(w * 1.15 + i * 5, h * 0.38 - 5 + i * 5),
          Offset(w * 1.25 + i * 5, h * 0.38 - 5 + i * 5),
          Paint()..color = Colors.yellow.withOpacity(0.7)..strokeWidth = 2,
        );
      }
    } else if (player.isKicking) {
      // Kicking animation
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.75, h * 0.35, pixel * 1.5, h * 0.28),
          const Radius.circular(6),
        ),
        Paint()..color = Colors.white,
      );
    } else {
      // Normal arms
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.75, h * 0.35, pixel * 1.5, h * 0.28),
          const Radius.circular(6),
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(Offset(w * 0.82, h * 0.65), pixel * 1.1, Paint()..color = Colors.white);
    }
    
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.35, pixel * 1.5, h * 0.28),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(Offset(w * 0.12, h * 0.65), pixel * 1.1, Paint()..color = Colors.white);
    
    // Legs/Boots
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.78, w * 0.18, h * 0.18),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.57, h * 0.78, w * 0.18, h * 0.18),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF78350F),
    );
    
    // Invincibility flash
    if (player.isInvincible && (player.invincibilityTimer * 10).toInt() % 2 == 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-5, -5, w + 10, h + 10),
          const Radius.circular(12),
        ),
        Paint()
          ..color = Colors.yellow.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
    
    // Dash trail
    if (player.isDashing) {
      for (int i = 0; i < 5; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-20 * (i + 1), 0, w, h),
            const Radius.circular(12),
          ),
          Paint()..color = Colors.orange.withOpacity(0.3 - i * 0.06),
        );
      }
    }
    
    canvas.restore();
  }
  
  void _drawEnhancedEnemy(Canvas canvas, Enemy enemy) {
    final color = _getEnemyColor(enemy.type);
    final secondaryColor = _getEnemySecondaryColor(enemy.type);
    
    // Shadow
    canvas.drawOval(
      Rect.fromLTWH(enemy.x + 5, enemy.y + enemy.height + 2, enemy.width - 10, 8),
      Paint()..color = Colors.black.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    
    // Enemy body with gradient
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(enemy.x, enemy.y, enemy.width, enemy.height),
        const Radius.circular(12),
      ),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, secondaryColor],
      ).createShader(Rect.fromLTWH(enemy.x, enemy.y, enemy.width, enemy.height)),
    );
    
    // Enemy details based on type
    _drawEnemyDetails(canvas, enemy);
    
    // Eyes with angry expression
    // White base
    canvas.drawCircle(
      Offset(enemy.x + enemy.width * 0.3, enemy.y + enemy.height * 0.3),
      enemy.width * 0.13,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(enemy.x + enemy.width * 0.7, enemy.y + enemy.height * 0.3),
      enemy.width * 0.13,
      Paint()..color = Colors.white,
    );
    
    // Angry pupils
    canvas.drawCircle(
      Offset(enemy.x + enemy.width * 0.3, enemy.y + enemy.height * 0.32),
      enemy.width * 0.07,
      Paint()..color = Colors.red.shade900,
    );
    canvas.drawCircle(
      Offset(enemy.x + enemy.width * 0.7, enemy.y + enemy.height * 0.32),
      enemy.width * 0.07,
      Paint()..color = Colors.red.shade900,
    );
    
    // Angry eyebrows
    canvas.drawLine(
      Offset(enemy.x + enemy.width * 0.2, enemy.y + enemy.height * 0.2),
      Offset(enemy.x + enemy.width * 0.4, enemy.y + enemy.height * 0.25),
      Paint()..color = Colors.black..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(enemy.x + enemy.width * 0.8, enemy.y + enemy.height * 0.2),
      Offset(enemy.x + enemy.width * 0.6, enemy.y + enemy.height * 0.25),
      Paint()..color = Colors.black..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
    
    // Mouth
    final mouthPath = Path();
    mouthPath.moveTo(enemy.x + enemy.width * 0.3, enemy.y + enemy.height * 0.65);
    mouthPath.quadraticBezierTo(
      enemy.x + enemy.width * 0.5, enemy.y + enemy.height * 0.75,
      enemy.x + enemy.width * 0.7, enemy.y + enemy.height * 0.65,
    );
    canvas.drawPath(
      mouthPath,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    
    // Health bar with better styling
    if (enemy.health < enemy.maxHealth) {
      final barWidth = enemy.width;
      final barHeight = 7.0;
      final healthPercent = enemy.health / enemy.maxHealth;
      
      // Background with border
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(enemy.x - 2, enemy.y - 16, barWidth + 4, barHeight + 4),
          const Radius.circular(5),
        ),
        Paint()..color = Colors.black.withOpacity(0.6),
      );
      
      // Red background
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(enemy.x, enemy.y - 14, barWidth, barHeight),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.red.shade900,
      );
      
      // Health with gradient
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(enemy.x, enemy.y - 14, barWidth * healthPercent, barHeight),
          const Radius.circular(4),
        ),
        Paint()..shader = LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ).createShader(Rect.fromLTWH(enemy.x, enemy.y - 14, barWidth * healthPercent, barHeight)),
      );
    }
  }
  
  void _drawEnemyDetails(Canvas canvas, Enemy enemy) {
    switch (enemy.type) {
      case EnemyType.junkFood:
        // Draw burger/fries pattern
        for (int i = 0; i < 3; i++) {
          canvas.drawRect(
            Rect.fromLTWH(
              enemy.x + enemy.width * 0.2 + i * (enemy.width * 0.2),
              enemy.y + enemy.height * 0.5,
              enemy.width * 0.15,
              enemy.height * 0.08,
            ),
            Paint()..color = Colors.yellow.shade700,
          );
        }
        break;
        
      case EnemyType.lazyCouch:
        // Draw couch cushions
        for (int i = 0; i < 2; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                enemy.x + enemy.width * 0.15 + i * (enemy.width * 0.4),
                enemy.y + enemy.height * 0.5,
                enemy.width * 0.3,
                enemy.height * 0.25,
              ),
              const Radius.circular(5),
            ),
            Paint()..color = Colors.brown.shade700,
          );
        }
        break;
        
      case EnemyType.sugarMonster:
        // Draw candy pattern
        for (int i = 0; i < 5; i++) {
          final angle = (i * 2 * math.pi / 5);
          canvas.drawCircle(
            Offset(
              enemy.x + enemy.width * 0.5 + math.cos(angle) * enemy.width * 0.25,
              enemy.y + enemy.height * 0.5 + math.sin(angle) * enemy.height * 0.25,
            ),
            enemy.width * 0.08,
            Paint()..color = Colors.white,
          );
        }
        break;
        
      case EnemyType.stress:
        // Draw stress lines
        for (int i = 0; i < 4; i++) {
          canvas.drawLine(
            Offset(enemy.x + enemy.width * 0.3, enemy.y + enemy.height * 0.45 + i * 5),
            Offset(enemy.x + enemy.width * 0.7, enemy.y + enemy.height * 0.45 + i * 5),
            Paint()..color = Colors.yellow..strokeWidth = 2,
          );
        }
        break;
    }
  }
  
  Color _getEnemyColor(EnemyType type) {
    switch (type) {
      case EnemyType.junkFood:
        return const Color(0xFFEA580C);
      case EnemyType.lazyCouch:
        return const Color(0xFF92400E);
      case EnemyType.sugarMonster:
        return const Color(0xFFEC4899);
      case EnemyType.stress:
        return const Color(0xFF991B1B);
    }
  }
  
  Color _getEnemySecondaryColor(EnemyType type) {
    switch (type) {
      case EnemyType.junkFood:
        return const Color(0xFFC2410C);
      case EnemyType.lazyCouch:
        return const Color(0xFF78350F);
      case EnemyType.sugarMonster:
        return const Color(0xFFDB2777);
      case EnemyType.stress:
        return const Color(0xFF7F1D1D);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}