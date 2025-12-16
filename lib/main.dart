import 'package:aura_health_companion/logic/auth_controller.dart';
import 'package:aura_health_companion/ui/logic/theme_controller.dart';
import 'package:aura_health_companion/ui/screens/services/notification_service.dart';
import 'package:aura_health_companion/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Initialize services before the app starts
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          // عرض شاشة تحميل بسيطة أثناء تحميل الثيم
          if (themeController.isLoading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00177E), Color(0xFF0F1120)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }

          return MaterialApp(
            title: 'Aura Health Companion',
            debugShowCheckedModeBanner: false,
            
            // تطبيق الثيمات
            theme: themeController.lightTheme,
            darkTheme: themeController.darkTheme,
            themeMode: themeController.isDarkMode 
              ? ThemeMode.dark 
              : ThemeMode.light,
            
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}