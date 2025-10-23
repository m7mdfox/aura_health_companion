import 'package:aura_health_companion/data/auth_service.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  AuthController() {
    // Notify listeners on auth changes
  }

  void notifyAuthChange() {
    notifyListeners();
  }
}