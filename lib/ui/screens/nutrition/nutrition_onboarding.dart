// lib/ui/screens/nutrition/nutrition_onboarding_flow.dart
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import slides
import 'slides/welcome_slide.dart';
import 'slides/physical_data_slide.dart';
import 'slides/activity_level_slide.dart';
import 'slides/goal_selection_slide.dart';
import 'slides/chronic_diseases_slide.dart';
import 'slides/lifestyle_slide.dart';
import 'slides/eating_relation_slide.dart';
import 'slides/meal_times_slide.dart';
import 'slides/improvement_goal_slide.dart';
import 'nutrition_loading_screen.dart';

class NutritionOnboardingFlow extends StatefulWidget {
  const NutritionOnboardingFlow({super.key});

  @override
  State<NutritionOnboardingFlow> createState() =>
      _NutritionOnboardingFlowState();
}

class _NutritionOnboardingFlowState extends State<NutritionOnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 9;

  // Answers
  String _lifestyle = '';
  String _eatingRelation = '';
  final List<String> _mealTimes = [];
  String _improvementGoal = '';
  String _goalType = '';
  String _dietType = '';
  String _ifSchedule = '';
  String _activityLevel = '';
  final List<String> _chronicDiseases = [];

  // User data
  String fullName = "جاري التحميل...";
  String email = "";
  String gender = "";
  int age = 0;
  double heightCm = 170;
  double weightKg = 70;

  bool _isLoading = false;
  bool _isFetchingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    final token = AuthService.token;
    if (token == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/profile/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['profile'];
        if (mounted) {
          setState(() {
            fullName = data['full_name'] ?? "المستخدم";
            email = data['email'] ?? "";
            gender = data['gender'] ?? "male";
            heightCm = (data['height_cm'] ?? 170).toDouble();
            weightKg = (data['weight_kg'] ?? 70).toDouble();
            _activityLevel = data['activity_level'] ?? "sedentary";
            
            if (data['birthdate'] != null) {
              final birthDate = DateTime.parse(data['birthdate']);
              final today = DateTime.now();
              age = today.year - birthDate.year;
              if (today.month < birthDate.month ||
                  (today.month == birthDate.month && today.day < birthDate.day)) {
                age--;
              }
            }
            
            _isFetchingProfile = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingProfile = false);
    }
  }

  Future<void> _updateBodyMeasurements(double newHeight, double newWeight) async {
    try {
      final response = await http.patch(
        Uri.parse('${AuthService.baseUrl}/api/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          'height_cm': newHeight,
          'weight_kg': newWeight,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          heightCm = newHeight;
          weightKg = newWeight;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildSnackBar('تم التحديث بنجاح', isError: false),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar('فشل التحديث', isError: true),
        );
      }
    }
  }

  Future<void> _submitAll() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final resp = await http.post(
        Uri.parse('${AuthService.baseUrl}/api/nutrition/onboarding'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          "lifestyle": _lifestyle,
          "eating_relation": _eatingRelation,
          "meal_times": _mealTimes,
          "improvement_goal": _improvementGoal,
          "goal_type": _goalType,
          "diet_type": _dietType,
          "if_schedule": _ifSchedule,
          "activity_level": _activityLevel,
          "chronic_diseases": _chronicDiseases,
        }),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NutritionLoadingScreen()),
        );
      } else {
        throw 'فشل الإرسال';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar('فشل الاتصال', isError: true),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submitAll();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  SnackBar _buildSnackBar(String message, {required bool isError}) {
    return SnackBar(
      content: Text(
        message,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
      ),
      backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == i ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == i
                ? const Color(0xFF0D1B4C)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _previousPage,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B4C),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D1B4C).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  Text(
                    '${_currentPage + 1}/$_totalPages',
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF0D1B4C),
                    ),
                  ),
                ],
              ),
            ),
            _buildProgressDots(),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (v) => setState(() => _currentPage = v),
                children: [
                  WelcomeSlide(fullName: fullName, onNext: _nextPage),
                  PhysicalDataSlide(
                    height: heightCm,
                    weight: weightKg,
                    age: age,
                    gender: gender,
                    onEdit: _updateBodyMeasurements,
                    onNext: _nextPage,
                    isLoading: _isFetchingProfile,
                  ),
                  ActivityLevelSlide(
                    selected: _activityLevel,
                    onSelect: (v) => setState(() => _activityLevel = v),
                    onNext: _nextPage,
                  ),
                  GoalSelectionSlide(
                    selectedGoalType: _goalType,
                    selectedDietType: _dietType,
                    selectedIfSchedule: _ifSchedule,
                    onGoalTypeSelect: (v) => setState(() => _goalType = v),
                    onDietTypeSelect: (v) => setState(() => _dietType = v),
                    onIfScheduleSelect: (v) => setState(() => _ifSchedule = v),
                    onNext: _nextPage,
                  ),
                  ChronicDiseasesSlide(
                    selectedDiseases: _chronicDiseases,
                    onToggle: (key, value) {
                      setState(() {
                        value
                            ? _chronicDiseases.add(key)
                            : _chronicDiseases.remove(key);
                      });
                    },
                    onNext: _nextPage,
                  ),
                  LifestyleSlide(
                    selected: _lifestyle,
                    onSelect: (v) => setState(() => _lifestyle = v),
                    onNext: _nextPage,
                  ),
                  EatingRelationSlide(
                    selected: _eatingRelation,
                    onSelect: (v) => setState(() => _eatingRelation = v),
                    onNext: _nextPage,
                  ),
                  MealTimesSlide(
                    selectedTimes: _mealTimes,
                    onToggle: (key, value) {
                      setState(() {
                        value ? _mealTimes.add(key) : _mealTimes.remove(key);
                      });
                    },
                    onNext: _nextPage,
                  ),
                  ImprovementGoalSlide(
                    selected: _improvementGoal,
                    onSelect: (v) => setState(() => _improvementGoal = v),
                    onNext: _isLoading ? null : _submitAll,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}