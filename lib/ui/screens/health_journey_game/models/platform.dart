import 'package:flutter/material.dart';

class Platform {
  double x;
  double y;
  double width;
  double height;
  Color color;
  bool isActive = true;
  
  Platform({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.color = const Color(0xFF8B4513),
  });
  
  bool collidesWith(double px, double py, double pw, double ph) {
    return px < x + width &&
           px + pw > x &&
           py < y + height &&
           py + ph > y;
  }
  
  void reset() {
    isActive = true;
  }
}