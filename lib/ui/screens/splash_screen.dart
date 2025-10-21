import 'package:aura_health_companion/data/supabase_service.dart';
import 'package:aura_health_companion/ui/screens/home_screen.dart';
import 'package:aura_health_companion/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _orbitAnimation;
  late Animation<double> _textRevealAnimation;
  double _progress = 0.0;
  bool _showProgress = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Heartbeat pulse effect for logo
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.05),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 0.97),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.97, end: 1.02),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 0.98),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.0),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutSine),
      ),
    );

    // Subtle orbital rotation effect for logo
    _orbitAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
      ),
    );

    // Sequential text reveal effect
    _textRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.linearToEaseOut),
      ),
    );

    _controller.forward();

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _showProgress = true);
    _simulateLoading();
  }

  void _simulateLoading() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.02;
        if (_progress >= 1.0) {
          timer.cancel();
          _navigateToNextScreen();
        }
      });
    });
  }

  void _navigateToNextScreen() async {
    if (!mounted) return;

    try {
      await _controller.reverse();
    } catch (e) {
      debugPrint('Animation error: $e');
    }
    if (!mounted) return;

    final session = SupabaseService.client.auth.currentSession;
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ScaleTransition(
            scale: animation,
            child: session != null ? const HomeScreen() : const LoginScreen(),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1120),
              Color(0xFF0025CC),
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_orbitAnimation.value * 0.05),
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                       
                      ),
                      child: ClipOval(
                        child: Image.asset(
                       
                          'assets/animations/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_hospital,
                                  size: 150,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Error: ${error.toString()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedBuilder(
                    animation: _textRevealAnimation,
                    builder: (context, child) {
                      return _buildTextReveal(context);
                    },
                    child: Text(
                      'AURA HEALTH COMPANION',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_showProgress) _buildProgressIndicator(),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextReveal(BuildContext context) {
    const text = 'AURA HEALTH COMPANION';
    final textSpan = <TextSpan>[];
    final progress = _textRevealAnimation.value;
    final charCount = (text.length * progress).floor();

    for (var i = 0; i < text.length; i++) {
      textSpan.add(
        TextSpan(
          text: text[i],
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: i < charCount
                ? Colors.white
                : const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
          ),
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: textSpan),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00B4DB),
                        Color(0xFF0083B0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B4DB).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          AnimatedOpacity(
            opacity: (_progress * 10 % 2).floor() == 0 ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFF00B4DB),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Initializing Health Data',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00B4DB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}