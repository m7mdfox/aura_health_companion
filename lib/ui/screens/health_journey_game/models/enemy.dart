enum EnemyType {
  junkFood,    // وجبات سريعة
  lazyCouch,   // كنبة الكسل
  sugarMonster, // وحش السكر
  stress,      // التوتر
}

class Enemy {
  double x;
  double y;
  double velocityX = 0;
  double velocityY = 0;
  
  double width = 50;
  double height = 60;
  
  final EnemyType type;
  int health;
  final int maxHealth;
  bool isDead = false;
  bool isActive = true;
  
  // Movement range
  final double minX;
  final double maxX;
  bool movingRight = false;
  double speed = 80;
  
  // AI
  double playerX = 0;
  double playerY = 0;
  bool playerDetected = false;
  
  Enemy({
    required this.x,
    required this.y,
    required this.type,
    required this.minX,
    required this.maxX,
    this.health = 2,
  }) : maxHealth = health {
    _setTypeProperties();
  }
  
  void _setTypeProperties() {
    switch (type) {
      case EnemyType.junkFood:
        speed = 100;
        health = 2;
        width = 45;
        height = 50;
        break;
      case EnemyType.lazyCouch:
        speed = 60;
        health = 3;
        width = 60;
        height = 45;
        break;
      case EnemyType.sugarMonster:
        speed = 120;
        health = 2;
        width = 40;
        height = 55;
        break;
      case EnemyType.stress:
        speed = 90;
        health = 4;
        width = 50;
        height = 60;
        break;
    }
  }
  
  void update(double deltaTime) {
    if (isDead) return;
    
    // Simple patrol AI
    if (movingRight) {
      velocityX = speed;
      if (x >= maxX) movingRight = false;
    } else {
      velocityX = -speed;
      if (x <= minX) movingRight = true;
    }
    
    // Apply movement
    x += velocityX * deltaTime;
    y += velocityY * deltaTime;
  }
  
  void takeDamage(int damage) {
    if (isDead) return;
    health -= damage;
    if (health <= 0) {
      health = 0;
      isDead = true;
    }
  }
  
  void updatePlayerPosition(double px, double py) {
    playerX = px;
    playerY = py;
    playerDetected = (playerX - x).abs() < 200;
  }
  
  int getDamage() {
    switch (type) {
      case EnemyType.junkFood:
        return 1;
      case EnemyType.lazyCouch:
        return 2;
      case EnemyType.sugarMonster:
        return 1;
      case EnemyType.stress:
        return 2;
    }
  }
  
  void reset() {
    health = maxHealth;
    isDead = false;
    isActive = true;
    velocityX = 0;
    velocityY = 0;
    movingRight = false;
  }
}