import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// ============================================
// MAIN GAME SCREEN
// ============================================
class HealthJourneyGameScreen extends StatefulWidget {
  const HealthJourneyGameScreen({super.key});

  @override
  State<HealthJourneyGameScreen> createState() => _HealthJourneyGameScreenState();
}

class _HealthJourneyGameScreenState extends State<HealthJourneyGameScreen> with TickerProviderStateMixin {
  // Game State
  GameState gameState = GameState.playing;
  
  // Player
  late Player player;
  
  // Enemies
  List<Enemy> enemies = [];
  
  // Platforms
  List<Platform> platforms = [];
  
  // PowerUps
  List<PowerUp> powerUps = [];
  
  // Camera
  double cameraOffsetX = 0;
  double cameraShakeX = 0;
  double cameraShakeY = 0;
  
  // Animation
  double cloudsOffset = 0;
  Timer? gameLoop;
  DateTime lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setLandscapeMode();
    _initializeGame();
    _startGameLoop();
  }

  void _setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _initializeGame() {
    // Initialize Player
    player = Player(x: 100, y: 300);
    
    // Create Platforms
    platforms = [
      Platform(x: 0, y: 380, width: 5000, height: 20), // Ground
      Platform(x: 300, y: 280, width: 150, height: 20),
      Platform(x: 600, y: 200, width: 150, height: 20),
      Platform(x: 900, y: 250, width: 150, height: 20),
      Platform(x: 1200, y: 180, width: 150, height: 20),
      Platform(x: 1500, y: 280, width: 150, height: 20),
    ];
    
    // Create Enemies
    enemies = [
      Enemy(x: 400, y: 300, type: EnemyType.junkFood),
      Enemy(x: 700, y: 300, type: EnemyType.sugarMonster),
      Enemy(x: 1000, y: 300, type: EnemyType.lazyCouch),
      Enemy(x: 1300, y: 300, type: EnemyType.stress),
    ];
    
    // Create PowerUps
    powerUps = [
      PowerUp(x: 350, y: 150, type: PowerUpType.health),
      PowerUp(x: 650, y: 100, type: PowerUpType.shield),
      PowerUp(x: 950, y: 150, type: PowerUpType.speed),
    ];
  }

  void _startGameLoop() {
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (gameState != GameState.playing) return;
      
      final now = DateTime.now();
      final deltaTime = (now.difference(lastUpdate).inMilliseconds / 1000.0).clamp(0.0, 0.1);
      lastUpdate = now;
      
      setState(() {
        _updateGame(deltaTime);
      });
    });
  }

  void _updateGame(double dt) {
    // Update Player
    player.update(dt);
    
    // Apply Gravity
    if (!player.isOnGround) {
      player.velocityY += 1500 * dt;
    }
    
    // Check Ground Collision
    player.isOnGround = false;
    for (var platform in platforms) {
      if (_checkPlatformCollision(player, platform)) {
        player.isOnGround = true;
        player.y = platform.y - player.height;
        player.velocityY = 0;
        break;
      }
    }
    
    // Update Camera
    if (player.x > 300) {
      cameraOffsetX = -(player.x - 300);
    }
    
    // Update Clouds
    cloudsOffset += dt * 20;
    
    // Update Enemies
    for (var enemy in enemies) {
      enemy.update(dt);
      
      // Check Enemy Collision
      if (_checkEnemyCollision(player, enemy)) {
        if (player.isPunching || player.isKicking) {
          enemy.takeDamage(1);
          if (enemy.isDead) {
            player.defeatEnemy();
          }
        } else if (!player.isInvincible) {
          player.takeDamage(1);
          if (player.isDead()) {
            gameState = GameState.gameOver;
          }
        }
      }
    }
    
    // Update PowerUps
    for (var powerUp in powerUps) {
      powerUp.update(dt);
      if (_checkPowerUpCollision(player, powerUp)) {
        _collectPowerUp(powerUp);
      }
    }
    
    // Check Win Condition
    if (player.hasReachedTarget()) {
      gameState = GameState.levelComplete;
    }
  }

  bool _checkPlatformCollision(Player p, Platform plat) {
    return p.x < plat.x + plat.width &&
           p.x + p.width > plat.x &&
           p.y + p.height >= plat.y &&
           p.y + p.height <= plat.y + 20 &&
           p.velocityY >= 0;
  }

  bool _checkEnemyCollision(Player p, Enemy e) {
    if (e.isDead || !e.isActive) return false;
    return p.x < e.x + e.width &&
           p.x + p.width > e.x &&
           p.y < e.y + e.height &&
           p.y + p.height > e.y;
  }

  bool _checkPowerUpCollision(Player p, PowerUp pu) {
    if (pu.isCollected) return false;
    return p.x < pu.x + pu.width &&
           p.x + p.width > pu.x &&
           p.y < pu.y + pu.height &&
           p.y + p.height > pu.y;
  }

  void _collectPowerUp(PowerUp powerUp) {
    powerUp.isCollected = true;
    switch (powerUp.type) {
      case PowerUpType.health:
        player.health = (player.health + 2).clamp(0, player.maxHealth);
        break;
      case PowerUpType.shield:
        player.hasShield = true;
        player.shieldTimer = 10.0;
        break;
      case PowerUpType.speed:
        player.hasSpeedBoost = true;
        player.speedBoostTimer = 8.0;
        break;
      case PowerUpType.damage:
        player.hasDoubleDamage = true;
        player.doubleDamageTimer = 10.0;
        break;
    }
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0A1128),
        child: Stack(
          children: [
            // Game Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: GameCanvasPainter(
                  player: player,
                  enemies: enemies,
                  platforms: platforms,
                  powerUps: powerUps,
                  cameraOffsetX: cameraOffsetX,
                  cloudsOffset: cloudsOffset,
                ),
              ),
            ),
            
            // HUD
            if (gameState == GameState.playing) _buildHUD(),
            
            // Controls
            if (gameState == GameState.playing) _buildControls(),
            
            // Pause Button
            if (gameState == GameState.playing) _buildPauseButton(),
            
            // Menus
            if (gameState == GameState.paused) _buildPauseMenu(),
            if (gameState == GameState.levelComplete) _buildWinScreen(),
            if (gameState == GameState.gameOver) _buildGameOverScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHealthBar(),
                _buildScoreDisplay(),
              ],
            ),
            const SizedBox(height: 12),
            _buildWeightProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red.withOpacity(0.9), Colors.red.shade700.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          ...List.generate(player.maxHealth, (i) => Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(
              i < player.health ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: i < player.health ? Colors.white : Colors.white30,
              size: 26,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.amber.withOpacity(0.9), Colors.orange.shade700.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text('${player.score}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeightProgress() {
    final progress = player.getWeightProgress();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.9), Colors.deepPurple.shade700.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.fitness_center_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('الوزن الحالي', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Text('${player.currentWeight.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text(' كجم → ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('${player.targetWeight.toInt()}', style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text(' كجم', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildControlButton(Icons.arrow_back_rounded, Colors.blue, () => player.moveLeft()),
              const SizedBox(width: 10),
              _buildControlButton(Icons.arrow_upward_rounded, Colors.green, () => player.jump()),
              const SizedBox(width: 10),
              _buildControlButton(Icons.arrow_forward_rounded, Colors.blue, () => player.moveRight()),
            ],
          ),
          Row(
            children: [
              _buildControlButton(Icons.sports_mma_rounded, Colors.red, () => player.punch()),
              const SizedBox(width: 10),
              _buildControlButton(Icons.sports_kabaddi_rounded, Colors.orange, () => player.kick()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withOpacity(0.6)]),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12)],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildPauseButton() {
    return Positioned(
      top: 20,
      left: 20,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => setState(() => gameState = GameState.paused),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Colors.indigo, Colors.indigo.shade700]),
              boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.5), blurRadius: 12)],
            ),
            child: const Icon(Icons.pause_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildPauseMenu() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.indigo.shade900]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: Colors.white, size: 80),
              const SizedBox(height: 20),
              const Text('متوقف مؤقتاً', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              _buildMenuButton('استئناف', Colors.green, Icons.play_arrow_rounded, () => setState(() => gameState = GameState.playing)),
              const SizedBox(height: 16),
              _buildMenuButton('خروج', Colors.red, Icons.exit_to_app_rounded, () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinScreen() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade800]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 100),
              const SizedBox(height: 20),
              const Text('🎉 مبروك! 🎉', style: TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Text('النقاط: ${player.score}', style: const TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 40),
              _buildMenuButton('خروج', Colors.grey, Icons.exit_to_app_rounded, () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red.shade700, Colors.red.shade900]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.heart_broken_rounded, color: Colors.white, size: 100),
              const SizedBox(height: 20),
              const Text('😔 للأسف...', style: TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Text('النقاط: ${player.score}', style: const TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 40),
              _buildMenuButton('حاول مرة أخرى', Colors.orange, Icons.refresh_rounded, () {
                _initializeGame();
                setState(() => gameState = GameState.playing);
              }),
              const SizedBox(height: 16),
              _buildMenuButton('خروج', Colors.grey, Icons.exit_to_app_rounded, () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ============================================
// GAME MODELS
// ============================================
enum GameState { playing, paused, levelComplete, gameOver }

enum EnemyType { junkFood, lazyCouch, sugarMonster, stress }

enum PowerUpType { shield, speed, damage, health }

class Player {
  double x, y;
  double velocityX = 0, velocityY = 0;
  double width = 60, height = 80;
  double currentWeight, targetWeight;
  int health = 5, maxHealth = 5;
  int score = 0, enemiesDefeated = 0;
  bool isOnGround = false, isFacingRight = true;
  bool isPunching = false, isKicking = false;
  bool isInvincible = false, hasShield = false, hasSpeedBoost = false, hasDoubleDamage = false;
  double invincibilityTimer = 0, attackTimer = 0;
  double shieldTimer = 0, speedBoostTimer = 0, doubleDamageTimer = 0;

  Player({required this.x, required this.y, this.currentWeight = 120, this.targetWeight = 70});

  void update(double dt) {
    if (invincibilityTimer > 0) invincibilityTimer -= dt;
    if (attackTimer > 0) {
      attackTimer -= dt;
      if (attackTimer <= 0) {
        isPunching = false;
        isKicking = false;
      }
    }
    if (shieldTimer > 0) {
      shieldTimer -= dt;
      if (shieldTimer <= 0) hasShield = false;
    }
    if (speedBoostTimer > 0) {
      speedBoostTimer -= dt;
      if (speedBoostTimer <= 0) hasSpeedBoost = false;
    }
    if (doubleDamageTimer > 0) {
      doubleDamageTimer -= dt;
      if (doubleDamageTimer <= 0) hasDoubleDamage = false;
    }
    
    x += velocityX * dt;
    y += velocityY * dt;
    velocityX *= 0.85;
  }

  void moveLeft() { velocityX = -250; isFacingRight = false; }
  void moveRight() { velocityX = 250; isFacingRight = true; }
  void jump() { if (isOnGround) velocityY = -550; }
  void punch() { if (attackTimer <= 0) { isPunching = true; attackTimer = 0.25; } }
  void kick() { if (attackTimer <= 0) { isKicking = true; attackTimer = 0.35; } }
  
  void takeDamage(int damage) {
    if (isInvincible) return;
    if (hasShield) {
      hasShield = false;
      return;
    }
    health -= damage;
    isInvincible = true;
    invincibilityTimer = 1.5;
  }

  void defeatEnemy() {
    enemiesDefeated++;
    score += 100;
    currentWeight -= 2;
    if (currentWeight < targetWeight) currentWeight = targetWeight;
  }

  bool isDead() => health <= 0;
  bool hasReachedTarget() => currentWeight <= targetWeight;
  double getWeightProgress() => ((120 - currentWeight) / (120 - targetWeight)).clamp(0.0, 1.0);
}

class Enemy {
  double x, y;
  final EnemyType type;
  double width = 50, height = 60;
  int health = 2;
  bool isDead = false, isActive = true;

  Enemy({required this.x, required this.y, required this.type});

  void update(double dt) {}
  void takeDamage(int damage) {
    health -= damage;
    if (health <= 0) {
      isDead = true;
      isActive = false;
    }
  }
}

class Platform {
  final double x, y, width, height;
  Platform({required this.x, required this.y, required this.width, required this.height});
}

class PowerUp {
  double x, y;
  final PowerUpType type;
  double width = 35, height = 35;
  bool isCollected = false;

  PowerUp({required this.x, required this.y, required this.type});

  void update(double dt) {}
}

// ============================================
// GAME CANVAS PAINTER
// ============================================
class GameCanvasPainter extends CustomPainter {
  final Player player;
  final List<Enemy> enemies;
  final List<Platform> platforms;
  final List<PowerUp> powerUps;
  final double cameraOffsetX, cloudsOffset;

  GameCanvasPainter({
    required this.player,
    required this.enemies,
    required this.platforms,
    required this.powerUps,
    required this.cameraOffsetX,
    required this.cloudsOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Sky
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF0A1128), const Color(0xFF87CEEB)],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.7), Paint()..shader = skyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    canvas.save();
    canvas.translate(cameraOffsetX, 0);

    // Ground
    canvas.drawRect(Rect.fromLTWH(0, 380, 5000, 220), Paint()..color = const Color(0xFF16A34A));

    // Platforms
    for (var p in platforms) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.x, p.y, p.width, p.height), const Radius.circular(10)), Paint()..color = const Color(0xFF8B4513));
    }

    // PowerUps
    for (var pu in powerUps) {
      if (!pu.isCollected) {
        canvas.drawCircle(Offset(pu.x + pu.width / 2, pu.y + pu.height / 2), pu.width / 2, Paint()..color = _getPowerUpColor(pu.type));
      }
    }

    // Enemies
    for (var e in enemies) {
      if (e.isActive && !e.isDead) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(e.x, e.y, e.width, e.height), const Radius.circular(12)), Paint()..color = _getEnemyColor(e.type));
      }
    }

    // Player
    _drawPlayer(canvas, player);

    canvas.restore();
  }

  void _drawPlayer(Canvas canvas, Player p) {
    final paint = Paint()..color = const Color(0xFF3B82F6);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.x, p.y, p.width, p.height), const Radius.circular(12)), paint);
    
    // Simple face
    canvas.drawCircle(Offset(p.x + p.width * 0.5, p.y + p.height * 0.3), p.width * 0.3, Paint()..color = const Color(0xFFFFE4C4));
    canvas.drawCircle(Offset(p.x + p.width * 0.4, p.y + p.height * 0.28), 4, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(p.x + p.width * 0.6, p.y + p.height * 0.28), 4, Paint()..color = Colors.black);
  }

  Color _getEnemyColor(EnemyType type) {
    switch (type) {
      case EnemyType.junkFood: return const Color(0xFFEA580C);
      case EnemyType.lazyCouch: return const Color(0xFF92400E);
      case EnemyType.sugarMonster: return const Color(0xFFEC4899);
      case EnemyType.stress: return const Color(0xFF991B1B);
    }
  }

  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield: return const Color(0xFF3B82F6);
      case PowerUpType.speed: return const Color(0xFF10B981);
      case PowerUpType.damage: return const Color(0xFFEF4444);
      case PowerUpType.health: return const Color(0xFFF59E0B);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}