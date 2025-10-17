import 'dart:async';

import 'package:aura_health_companion/data/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends ChangeNotifier {
  late final StreamSubscription<AuthState> _authStateSubscription;

  AuthController() {
    _authStateSubscription = SupabaseService.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}