// lib/ui/screens/nutrition/nutrition_loading_screen.dart
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'nutrition_result_screen.dart';

class NutritionLoadingScreen extends StatefulWidget {
  const NutritionLoadingScreen({super.key});

  @override
  State<NutritionLoadingScreen> createState() => _NutritionLoadingScreenState();
}

class _NutritionLoadingScreenState extends State<NutritionLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _statusText = 'جاري إنشاء خطتك الغذائية...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _generatePlan();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    print('🔄 Starting plan generation...');
    
    try {
      setState(() {
        _statusText = 'جاري تحليل بياناتك...';
      });

      await Future.delayed(const Duration(seconds: 1));

      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token');
      }

      print('📡 Calling API: ${AuthService.baseUrl}/api/nutrition/generate-plan');
      
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/api/nutrition/generate-plan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        print('✅ Plan generated successfully!');
        print('📊 Calculations: ${data['data']['calculations']}');
        print('📅 Plan days: ${(data['data']['plan']['weeklyPlan'] as List).length}');

        setState(() {
          _statusText = 'تم إنشاء خطتك بنجاح!';
        });

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => NutritionResultScreen(
                calculations: data['data']['calculations'],
                plan: data['data']['plan'],
              ),
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'فشل إنشاء الخطة');
      }
    } catch (e, stackTrace) {
      print('❌ Error generating plan: $e');
      print('Stack trace: $stackTrace');
      
      setState(() {
        _hasError = true;
        _statusText = 'حدث خطأ: ${e.toString()}';
      });

      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل إنشاء الخطة. حاول مرة أخرى.',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B4C),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_hasError) ...[
                RotationTransition(
                  turns: _controller,
                  child: Image.asset(
                    'assets/loginLogo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade300,
                  size: 80,
                ),
              ],
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!_hasError)
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.orange.shade300,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}