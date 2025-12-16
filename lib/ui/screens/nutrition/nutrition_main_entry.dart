// lib/ui/screens/nutrition/nutrition_main_entry.dart
import 'package:aura_health_companion/ui/screens/nutrition/nutrition_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aura_health_companion/data/auth_service.dart';
import 'nutrition_result_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class NutritionMainEntry extends StatefulWidget {
  const NutritionMainEntry({super.key});

  @override
  State<NutritionMainEntry> createState() => _NutritionMainEntryState();
}

class _NutritionMainEntryState extends State<NutritionMainEntry> {
  bool _isLoading = true;
  bool _hasSavedPlan = false;
  Map<String, dynamic>? _savedPlanData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkForSavedPlan();
  }

  Future<void> _checkForSavedPlan() async {
    print('🔍 Checking for saved plan...');
    
    try {
      final token = AuthService.token;
      if (token == null) {
        print('❌ No token found');
        _navigateToOnboarding();
        return;
      }

      print('📡 Making API request to: ${AuthService.baseUrl}/api/nutrition/saved-plan');
      
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/nutrition/saved-plan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['hasPlan'] == true && data['data'] != null) {
          print('✅ Saved plan found!');
          
          setState(() {
            _hasSavedPlan = true;
            _savedPlanData = data['data'];
            _isLoading = false;
          });
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => NutritionResultScreen(
                  calculations: _savedPlanData!['calculations'],
                  plan: _savedPlanData!['plan'],
                ),
              ),
            );
          }
        } else {
          print('ℹ️ No saved plan, going to onboarding');
          _navigateToOnboarding();
        }
      } else if (response.statusCode == 404) {
        print('ℹ️ No plan found (404), going to onboarding');
        _navigateToOnboarding();
      } else {
        print('⚠️ Unexpected status code: ${response.statusCode}');
        _navigateToOnboarding();
      }
    } catch (e, stackTrace) {
      print('❌ Error checking for saved plan: $e');
      print('Stack trace: $stackTrace');
      
      setState(() {
        _errorMessage = 'حدث خطأ في الاتصال';
        _isLoading = false;
      });
      
      await Future.delayed(const Duration(seconds: 2));
      _navigateToOnboarding();
    }
  }

  void _navigateToOnboarding() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const NutritionOnboardingFlow(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFF0D1B4C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null) ...[
              Icon(
                Icons.error_outline,
                color: isDark ? const Color(0xFFFFB74D) : Colors.orange.shade300,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ] else ...[
              CircularProgressIndicator(
                color: isDark ? const Color(0xFF60A5FA) : Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'جاري التحميل...',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}