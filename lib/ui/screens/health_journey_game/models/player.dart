import 'dart:ui';

class Player {
  double x;
  double y;
  double velocityX = 0;
  double velocityY = 0;
  
  // Size (يتغير حسب الوزن)
  double width = 60;
  double height = 80;
  
  // Weight system
  double currentWeight;
  double targetWeight;
  final double startWeight = 120;
  
  // Health
  int health = 5;
  int maxHealth = 5;
  
  // Stats
  int score = 0;
  int enemiesDefeated = 0;
  int combo = 0;
  double comboTimer = 0;
  
  // Power-ups
  bool hasShield = false;
  double shieldTimer = 0;
  bool hasSpeedBoost = false;
  double speedBoostTimer = 0;
  bool hasDoubleDamage = false;
  double doubleDamageTimer = 0;
  
  // State
  bool isOnGround = false;
  bool isFacingRight = true;
  bool isPunching = false;
  bool isKicking = false;
  bool isInvincible = false;
  double invincibilityTimer = 0;
  double attackTimer = 0;
  bool isDashing = false;
  double dashTimer = 0;
  double dashCooldown = 0;
  
  // Animation
  int walkFrame = 0;
  double animationTimer = 0;
  double dustTimer = 0;
  
  // Particles
  List<Particle> particles = [];
  
  // Double jump
  int jumpsLeft = 2;
  
  Player({
    required this.x,
    required this.y,
    this.currentWeight = 120,
    this.targetWeight = 70,
  });
  
  void update(double deltaTime) {
    // Update timers
    if (invincibilityTimer > 0) {
      invincibilityTimer -= deltaTime;
      if (invincibilityTimer <= 0) isInvincible = false;
    }
    
    if (attackTimer > 0) {
      attackTimer -= deltaTime;
      if (attackTimer <= 0) {
        isPunching = false;
        isKicking = false;
      }
    }
    
    if (dashTimer > 0) {
      dashTimer -= deltaTime;
      if (dashTimer <= 0) isDashing = false;
    }
    
    if (dashCooldown > 0) {
      dashCooldown -= deltaTime;
    }
    
    if (comboTimer > 0) {
      comboTimer -= deltaTime;
      if (comboTimer <= 0) combo = 0;
    }
    
    // Power-ups
    if (shieldTimer > 0) {
      shieldTimer -= deltaTime;
      if (shieldTimer <= 0) hasShield = false;
    }
    
    if (speedBoostTimer > 0) {
      speedBoostTimer -= deltaTime;
      if (speedBoostTimer <= 0) hasSpeedBoost = false;
    }
    
    if (doubleDamageTimer > 0) {
      doubleDamageTimer -= deltaTime;
      if (doubleDamageTimer <= 0) hasDoubleDamage = false;
    }
    
    // Update animation
    if (velocityX.abs() > 0.5 && isOnGround) {
      animationTimer += deltaTime;
      if (animationTimer > 0.1) {
        walkFrame = (walkFrame + 1) % 6;
        animationTimer = 0;
        
        // Dust particles
        dustTimer += deltaTime;
        if (dustTimer > 0.15) {
          createDustParticle();
          dustTimer = 0;
        }
      }
    }
    
    // Update size based on weight
    double weightRatio = (currentWeight - targetWeight) / (startWeight - targetWeight);
    width = 50 + (weightRatio * 30);
    height = 70 + (weightRatio * 20);
    
    // Apply movement with speed boost
    double speedMultiplier = hasSpeedBoost ? 1.5 : 1.0;
    x += velocityX * deltaTime * speedMultiplier;
    y += velocityY * deltaTime;
    
    // Friction (less friction when dashing)
    if (isDashing) {
      velocityX *= 0.98;
    } else {
      velocityX *= 0.85;
    }
    
    // Update particles
    particles.removeWhere((p) => p.isDead);
    for (var particle in particles) {
      particle.update(deltaTime);
    }
    
    // Reset jumps when on ground
    if (isOnGround) {
      jumpsLeft = 2;
    }
  }
  
  void moveLeft() {
    double speed = isDashing ? -400 : -250;
    velocityX = speed;
    isFacingRight = false;
  }
  
  void moveRight() {
    double speed = isDashing ? 400 : 250;
    velocityX = speed;
    isFacingRight = true;
  }
  
  void jump() {
    if (jumpsLeft > 0) {
      velocityY = -550;
      jumpsLeft--;
      createJumpParticles();
    }
  }
  
  void dash() {
    if (dashCooldown <= 0 && !isDashing) {
      isDashing = true;
      dashTimer = 0.3;
      dashCooldown = 1.5;
      velocityX = isFacingRight ? 500 : -500;
      createDashParticles();
    }
  }
  
  void punch() {
    if (attackTimer <= 0) {
      isPunching = true;
      attackTimer = 0.25;
      createAttackParticles();
    }
  }
  
  void kick() {
    if (attackTimer <= 0) {
      isKicking = true;
      attackTimer = 0.35;
      createAttackParticles();
    }
  }
  
  void takeDamage(int damage) {
    if (isInvincible || isDashing) return;
    
    if (hasShield) {
      hasShield = false;
      shieldTimer = 0;
      return;
    }
    
    health -= damage;
    if (health < 0) health = 0;
    isInvincible = true;
    invincibilityTimer = 1.5;
    velocityY = -350;
    combo = 0;
  }
  
  void loseWeight(double amount) {
    currentWeight -= amount;
    if (currentWeight < targetWeight) {
      currentWeight = targetWeight;
    }
  }
  
  void defeatEnemy() {
    enemiesDefeated++;
    combo++;
    comboTimer = 3.0;
    
    int baseScore = 100;
    int comboBonus = combo * 50;
    int damageBonus = hasDoubleDamage ? 50 : 0;
    
    score += baseScore + comboBonus + damageBonus;
    
    double weightLoss = hasDoubleDamage ? 3.0 : 2.0;
    loseWeight(weightLoss);
    
    createVictoryParticles();
  }
  
  void collectPowerUp(String type) {
    switch (type) {
      case 'shield':
        hasShield = true;
        shieldTimer = 10.0;
        break;
      case 'speed':
        hasSpeedBoost = true;
        speedBoostTimer = 8.0;
        break;
      case 'damage':
        hasDoubleDamage = true;
        doubleDamageTimer = 10.0;
        break;
      case 'health':
        health = (health + 2).clamp(0, maxHealth);
        break;
    }
    createCollectParticles();
  }
  
  int getAttackDamage() {
    int baseDamage = isKicking ? 2 : 1;
    int comboDamage = combo > 5 ? 1 : 0;
    int powerUpDamage = hasDoubleDamage ? baseDamage : 0;
    return baseDamage + comboDamage + powerUpDamage;
  }
  
  bool isDead() => health <= 0;
  
  bool hasReachedTarget() => currentWeight <= targetWeight;
  
  double getWeightProgress() {
    return ((startWeight - currentWeight) / (startWeight - targetWeight)).clamp(0.0, 1.0);
  }
  
  void createDustParticle() {
    particles.add(Particle(
      x: x + (isFacingRight ? 0 : width),
      y: y + height - 10,
      velocityX: (isFacingRight ? -50 : 50),
      velocityY: -20,
      color: const Color(0xFFD4A574),
      size: 4,
      lifetime: 0.5,
    ));
  }
  
  void createJumpParticles() {
    for (int i = 0; i < 8; i++) {
      particles.add(Particle(
        x: x + width / 2,
        y: y + height,
        velocityX: (i - 4) * 20,
        velocityY: -50,
        color: const Color(0xFF87CEEB),
        size: 5,
        lifetime: 0.6,
      ));
    }
  }
  
  void createDashParticles() {
    for (int i = 0; i < 12; i++) {
      particles.add(Particle(
        x: x + width / 2,
        y: y + height / 2,
        velocityX: (isFacingRight ? -100 : 100) + (i - 6) * 10,
        velocityY: (i - 6) * 10,
        color: const Color(0xFFFFA500),
        size: 6,
        lifetime: 0.4,
      ));
    }
  }
  
  void createAttackParticles() {
    for (int i = 0; i < 6; i++) {
      particles.add(Particle(
        x: x + (isFacingRight ? width : 0),
        y: y + height / 2,
        velocityX: (isFacingRight ? 100 : -100) + (i - 3) * 20,
        velocityY: (i - 3) * 20,
        color: const Color(0xFFFFFF00),
        size: 7,
        lifetime: 0.3,
      ));
    }
  }
  
  void createVictoryParticles() {
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(
        x: x + width / 2,
        y: y + height / 2,
        velocityX: (i - 10) * 30,
        velocityY: -100 + (i - 10) * 10,
        color: const Color(0xFFFFD700),
        size: 8,
        lifetime: 1.0,
      ));
    }
  }
  
  void createCollectParticles() {
    for (int i = 0; i < 15; i++) {
      particles.add(Particle(
        x: x + width / 2,
        y: y + height / 2,
        velocityX: (i - 7.5) * 40,
        velocityY: -80 + (i - 7.5) * 15,
        color: const Color(0xFF00FF00),
        size: 6,
        lifetime: 0.8,
      ));
    }
  }
}

class Particle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  Color color;
  double size;
  double lifetime;
  double age = 0;
  bool isDead = false;
  
  Particle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.lifetime,
  });
  
  void update(double deltaTime) {
    age += deltaTime;
    if (age >= lifetime) {
      isDead = true;
      return;
    }
    
    x += velocityX * deltaTime;
    y += velocityY * deltaTime;
    velocityY += 300 * deltaTime; // Gravity
    velocityX *= 0.95; // Air resistance
  }
  
  double getOpacity() {
    return (1 - age / lifetime).clamp(0.0, 1.0);
  }
}