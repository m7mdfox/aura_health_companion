import 'package:aura_health_companion/data/auth_service.dart';
import 'package:aura_health_companion/logic/auth_controller.dart';
import 'package:aura_health_companion/ui/screens/home_screen.dart';
import 'package:aura_health_companion/ui/screens/signup_screen.dart';
import 'package:aura_health_companion/ui/widgets/error_animation.dart';
import 'package:aura_health_companion/ui/widgets/success_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _clearLocalMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_mood_date');
    await prefs.remove('today_mood');
    await prefs.remove('last_mood_user_id');
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : Colors.white,
      body: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: isDark ? 0.2 : 0.3,
              child: Image.asset(
                'assets/PatternLogin.png',
                width: screenWidth,
                height: screenHeight * 0.5,
                fit: BoxFit.cover,
                color: isDark ? const Color(0xFF1A1D2E) : null,
                colorBlendMode: isDark ? BlendMode.modulate : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Image.asset('assets/loginLogo.png', width: 150),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Welcome to Aura",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        color: isDark ? Colors.white : const Color(0xFF00177E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Create an account or log in to explore \nabout our app",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login / Sign Up Toggle
                    Container(
                      width: 327,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF5F6F9),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isDark 
                            ? Colors.white12 
                            : const Color.fromARGB(255, 218, 218, 218),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark 
                                  ? const Color(0xFF00177E) 
                                  : const Color(0xFF0F1120),
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 1),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: isDark ? Colors.white70 : Colors.black,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              onPressed: _navigateToSignUp,
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    SizedBox(
                      width: 327,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white24 : const Color(0xFF0025CC),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF00177E) : const Color(0xFF0F1120),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontFamily: GoogleFonts.inter().fontFamily,
                            fontSize: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    SizedBox(
                      width: 327,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white24 : const Color(0xFF0025CC),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF00177E) : const Color(0xFF0F1120),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontFamily: GoogleFonts.inter().fontFamily,
                            fontSize: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login Button
                    SizedBox(
                      width: 327,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0025CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await AuthService.login(
                                _emailController.text.trim(),
                                _passwordController.text,
                              );

                              await _clearLocalMoodData();
                              authController.notifyAuthChange();

                              if (mounted) {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SuccessAnimation(
                                      message: 'Welcome back!',
                                      onComplete: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => const HomeScreen(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              var message = e.toString().replaceAll('Exception: ', '');
                              if (message.contains('Invalid')) {
                                message = 'Invalid email or password';
                              } else {
                                message = 'Login failed. Please try again.';
                              }
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return ErrorAnimation(
                                    message: message,
                                    onDismiss: () {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Social Login
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Or login using social media",
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.grey[600],
                                fontFamily: GoogleFonts.inter().fontFamily,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Ionicons.logo_google,
                                  color: Colors.red, size: 35),
                              onPressed: () {
                                print("Google login");
                              },
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Ionicons.logo_facebook,
                                  color: Colors.blue, size: 35),
                              onPressed: () {
                                print("Facebook login");
                              },
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: Icon(
                                Ionicons.logo_apple,
                                color: isDark ? Colors.white : Colors.black,
                                size: 35,
                              ),
                              onPressed: () {
                                print("Apple login");
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}