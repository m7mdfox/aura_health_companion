import 'package:aura_health_companion/data/supabase_service.dart';
import 'package:aura_health_companion/logic/auth_controller.dart';
import 'package:aura_health_companion/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  await SupabaseService.initialize();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final AuthController _authController = AuthController();

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
    );
  }
}
