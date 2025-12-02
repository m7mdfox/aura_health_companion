import 'package:aura_health_companion/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  final int _totalPages = 7; // زادت صفحة للمراجعة

  // Answers (Defaulting to the Arabic text directly)
  String _lifestyle = '';
  String _eatingRelation = '';
  final List<String> _mealTimes = [];
  String _improvementGoal = '';

  // Real user data
  String fullName = "جاري التحميل...";
  double heightCm = 170;
  double weightKg = 70;

  bool _isLoading = false;
  bool _isFetchingProfile = true;
  bool _isInitializing = true;

  // Static options for better performance
  static const List<Map<String, Object>> _lifestyleOptions = [
    {
      'value': 'أجلس فترات طويلة\n(عمل مكتبي)',
      'title': 'أجلس فترات طويلة\n(عمل مكتبي)',
      'icon': Icons.chair
    },
    {
      'value': 'أتحرك على فترات متقطعة',
      'title': 'أتحرك على فترات متقطعة',
      'icon': Icons.directions_walk
    },
    {
      'value': 'يومي نشيط',
      'title': 'يومي نشيط',
      'icon': Icons.local_fire_department
    },
    {
      'value': 'نشاط بدني عالي',
      'title': 'نشاط بدني عالي',
      'icon': Icons.directions_run
    },
  ];

  static const List<Map<String, Object>> _eatingRelationOptions = [
    {'value': 'آكل عندما أشعر بالتوتر', 'title': 'آكل عندما أشعر بالتوتر'},
    {
      'value': 'آكل بانتظام لكن بدون خطة',
      'title': 'آكل بانتظام لكن بدون خطة'
    },
    {'value': 'ملتزم بنظام غذائي غالبًا', 'title': 'ملتزم بنظام غذائي غالبًا'},
    {
      'value': 'أجد صعوبة في مقاومة الحلويات',
      'title': 'أجد صعوبة في مقاومة الحلويات'
    },
  ];

  static const List<Map<String, Object>> _mealTimesOptions = [
    {'key': 'صباحًا مبكرًا', 'title': 'صباحًا مبكرًا'},
    {'key': 'منتصف اليوم', 'title': 'منتصف اليوم'},
    {'key': 'مساءً', 'title': 'مساءً'},
    {'key': 'متنوع حسب اليوم', 'title': 'متنوع حسب اليوم'},
  ];

  static const List<Map<String, Object>> _improvementGoalOptions = [
    {'value': 'طاقتي اليومية', 'title': 'طاقتي اليومية', 'icon': Icons.bolt},
    {'value': 'شكل جسمي', 'title': 'شكل جسمي', 'icon': Icons.fitness_center},
    {'value': 'جودة نومي', 'title': 'جودة نومي', 'icon': Icons.bedtime},
    {'value': 'عاداتي الغذائية', 'title': 'عاداتي الغذائية', 'icon': Icons.restaurant},
    {
      'value': 'لياقتي العامة',
      'title': 'لياقتي العامة',
      'icon': Icons.monitor_heart
    },
  ];

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

    setState(() => _isFetchingProfile = true);
    
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/profile/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['profile'];
        if (mounted) {
          setState(() {
            fullName = data['full_name'] ?? "المستخدم";
            heightCm = (data['height_cm'] ?? 170).toDouble();
            weightKg = (data['weight_kg'] ?? 70).toDouble();
            _isFetchingProfile = false;
            _isInitializing = false;
          });
        }
      } else {
        throw 'فشل في تحميل البيانات';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingProfile = false;
          _isInitializing = false;
        });
        _showErrorDialog(
          'تعذر تحميل الملف الشخصي',
          'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
          _fetchUserProfile,
        );
      }
    }
  }

  Future<void> _updateBodyMeasurements() async {
    final result = await showDialog<Map<String, double>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UpdateBodyDialog(
        currentHeight: heightCm,
        currentWeight: weightKg,
      ),
    );

    if (result == null) return;

    try {
      final response = await http.patch(
        Uri.parse('${AuthService.baseUrl}/api/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          'height_cm': result['height'],
          'weight_kg': result['weight'],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        setState(() {
          heightCm = result['height']!;
          weightKg = result['weight']!;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildAuraSnackBar('تم التحديث بنجاح', isError: false),
          );
        }
      } else {
        throw 'فشل في التحديث';
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'تعذر تحديث البيانات',
          'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
          _updateBodyMeasurements,
        );
      }
    }
  }

  Future<void> _submitAll() async {
    if (_isLoading) return;

    // التحقق من اكتمال جميع الحقول
    if (_lifestyle.isEmpty || 
        _eatingRelation.isEmpty || 
        _mealTimes.isEmpty || 
        _improvementGoal.isEmpty) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        _buildAuraSnackBar('يرجى الإجابة على جميع الأسئلة', isError: true),
      );
      return;
    }

    // التحقق من أن mealTimes لا يحتوي على قيم فارغة
    final validMealTimes = _mealTimes.where((time) => time.isNotEmpty).toList();
    if (validMealTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildAuraSnackBar('يرجى اختيار أوقات الوجبات', isError: true),
      );
      return;
    }

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
          "meal_times": validMealTimes,
          "improvement_goal": _improvementGoal,
        }),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NutritionLoadingScreen()),
        );
      } else {
        final errorData = jsonDecode(resp.body);
        throw errorData['message'] ?? 'فشل الإرسال';
      }
    } catch (e) {
      _showErrorDialog(
        'تعذر إرسال البيانات',
        'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
        _submitAll,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الخروج', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('هل تريد الخروج من عملية الإعداد؟', style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('البقاء', style: GoogleFonts.cairo(color: Color(0xFF0D1B4C))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الديالوج
              Navigator.pop(context); // الخروج من الشاشة
            },
            child: Text('خروج', style: GoogleFonts.cairo(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: Text('إعادة المحاولة', style: GoogleFonts.cairo(color: Color(0xFF0D1B4C))),
          ),
        ],
      ),
    );
  }

  /// Custom Aura Snack Bar
  SnackBar _buildAuraSnackBar(String message, {required bool isError}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'حسناً',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
  }

  Widget _buildProgressDots() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (i) {
          return Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? const Color(0xFF0D1B4C)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _handleMealTimeToggle(String key, bool value) {
    setState(() {
      if (value) {
        _mealTimes.add(key);
      } else {
        _mealTimes.remove(key);
      }
    });
  }

  bool get _isFormComplete {
    return _lifestyle.isNotEmpty &&
        _eatingRelation.isNotEmpty &&
        _mealTimes.isNotEmpty &&
        _improvementGoal.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF0D1B4C)),
              SizedBox(height: 20),
              Text('جاري تحميل البيانات...', style: GoogleFonts.cairo()),
            ],
          ),
        ),
      );
    }

    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _isLoading ? null : _previousPage,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isLoading ? Colors.grey : const Color(0xFF0D1B4C),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D1B4C).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _isLoading ? null : _showExitDialog,
                      icon: Icon(Icons.close, color: _isLoading ? Colors.grey : Color(0xFF0D1B4C)),
                    ),
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
                  WelcomeSlide(
                    fullName: fullName, 
                    onNext: _nextPage,
                    isSmallScreen: isSmallScreen,
                  ),
                  PhysicalDataSlide(
                    height: heightCm,
                    weight: weightKg,
                    onEdit: _isLoading ? null : _updateBodyMeasurements,
                    onNext: _nextPage,
                    isLoading: _isFetchingProfile || _isLoading,
                  ),
                  LifestyleSlide(
                      selected: _lifestyle,
                      onSelect: (v) => setState(() => _lifestyle = v),
                      onNext: _nextPage),
                  EatingRelationSlide(
                      selected: _eatingRelation,
                      onSelect: (v) => setState(() => _eatingRelation = v),
                      onNext: _nextPage),
                  MealTimesSlide(
                    selectedTimes: _mealTimes,
                    onToggle: _handleMealTimeToggle,
                    onNext: _nextPage,
                  ),
                  ImprovementGoalSlide(
                    selected: _improvementGoal,
                    onSelect: (v) => setState(() => _improvementGoal = v),
                    onNext: _nextPage,
                  ),
                  ReviewSlide(
                    lifestyle: _lifestyle,
                    eatingRelation: _eatingRelation,
                    mealTimes: _mealTimes,
                    improvementGoal: _improvementGoal,
                    height: heightCm,
                    weight: weightKg,
                    onEdit: (page) => _goToPage(page),
                    onSubmit: _isLoading ? null : _submitAll,
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

// ====================== ALL SLIDES ======================

class WelcomeSlide extends StatelessWidget {
  final String fullName;
  final VoidCallback onNext;
  final bool isSmallScreen;

  const WelcomeSlide({
    super.key, 
    required this.fullName, 
    required this.onNext,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Image
          Image.asset(
            'assets/loginLogo.png',
            height: isSmallScreen ? 150 : 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'مرحبًا $fullName',
            style: GoogleFonts.cairo(
              fontSize: isSmallScreen ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لنصمم لك خطة صحية تناسب جسمك',
            style: GoogleFonts.cairo(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'أجب على الأسئلة التالية لنبدأ رحلتك',
            style: GoogleFonts.cairo(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D1B4C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 50 : 60, 
                vertical: isSmallScreen ? 16 : 20
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: const Color(0xFF0D1B4C).withOpacity(0.3),
            ),
            child: Text(
              'ابدأ الآن',
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhysicalDataSlide extends StatelessWidget {
  final double height;
  final double weight;
  final VoidCallback? onEdit;
  final VoidCallback onNext;
  final bool isLoading;

  const PhysicalDataSlide({
    super.key,
    required this.height,
    required this.weight,
    required this.onEdit,
    required this.onNext,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'بياناتك البدنية',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 40),
          isLoading
              ? const CircularProgressIndicator(color: Color(0xFF0D1B4C))
              : Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1B4C).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.height,
                                size: 24, color: Color(0xFF0D1B4C)),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${height.toInt()} سم',
                            style: GoogleFonts.mulish(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D1B4C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1B4C).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.fitness_center,
                                size: 24, color: Color(0xFF0D1B4C)),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${weight.toInt()} كجم',
                            style: GoogleFonts.mulish(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D1B4C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: Text('تعديل', style: GoogleFonts.cairo()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D1B4C),
                          side: const BorderSide(color: Color(0xFF0D1B4C)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
          const Spacer(),
          NextButton(
            onPressed: isLoading ? null : onNext,
            text: 'التالي',
          ),
        ],
      ),
    );
  }
}

class LifestyleSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const LifestyleSlide({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OptionSlide(
        title: 'صف يومك النموذجي',
        options: _NutritionOnboardingFlowState._lifestyleOptions,
        selectedValue: selected,
        onSelect: onSelect, // لا انتقال تلقائي
        onNext: onNext,
        showNextButton: true);
  }
}

class EatingRelationSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const EatingRelationSlide({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OptionSlide(
        title: 'كيف تصف علاقتك بالطعام؟',
        options: _NutritionOnboardingFlowState._eatingRelationOptions,
        selectedValue: selected,
        onSelect: onSelect, // لا انتقال تلقائي
        onNext: onNext,
        useIcon: false,
        showNextButton: true);
  }
}

class MealTimesSlide extends StatelessWidget {
  final List<String> selectedTimes;
  final void Function(String, bool) onToggle;
  final VoidCallback onNext;

  const MealTimesSlide({
    super.key,
    required this.selectedTimes,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'متى تفضل تناول وجباتك؟',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _NutritionOnboardingFlowState._mealTimesOptions.map((t) {
                  final key = t['key'] as String;
                  final bool isSelected = selectedTimes.contains(key);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: isSelected ? const Color(0xFF0D1B4C) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: isSelected ? 4 : 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: InkWell(
                        onTap: () => onToggle(key, !isSelected),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Text(
                                t['title'] as String,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF0D1B4C),
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 22)
                              else
                                Icon(Icons.circle_outlined,
                                    color: Colors.grey.shade400, size: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          NextButton(
            onPressed: selectedTimes.isNotEmpty ? onNext : null,
            text: 'التالي',
          ),
        ],
      ),
    );
  }
}

class ImprovementGoalSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const ImprovementGoalSlide({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'ما الذي تريد تحسينه؟',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: _NutritionOnboardingFlowState._improvementGoalOptions.map((g) {
                final bool isSelected = selected == g['value'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: isSelected ? const Color(0xFF0D1B4C) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    elevation: isSelected ? 4 : 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: InkWell(
                      onTap: () => onSelect(g['value'] as String),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              g['icon'] as IconData,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                g['title'] as String,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF0D1B4C),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          NextButton(
            onPressed: selected.isNotEmpty ? onNext : null,
            text: 'التالي',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ReviewSlide extends StatelessWidget {
  final String lifestyle;
  final String eatingRelation;
  final List<String> mealTimes;
  final String improvementGoal;
  final double height;
  final double weight;
  final ValueChanged<int> onEdit;
  final VoidCallback? onSubmit;
  final bool isLoading;

  const ReviewSlide({
    super.key,
    required this.lifestyle,
    required this.eatingRelation,
    required this.mealTimes,
    required this.improvementGoal,
    required this.height,
    required this.weight,
    required this.onEdit,
    this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'مراجعة الإجابات',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'راجع إجاباتك قبل الإرسال',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _ReviewItem(
                    title: 'البيانات البدنية',
                    value: '${height.toInt()} سم - ${weight.toInt()} كجم',
                    onEdit: () => onEdit(1),
                  ),
                  _ReviewItem(
                    title: 'نمط الحياة',
                    value: lifestyle,
                    onEdit: () => onEdit(2),
                  ),
                  _ReviewItem(
                    title: 'علاقة الطعام',
                    value: eatingRelation,
                    onEdit: () => onEdit(3),
                  ),
                  _ReviewItem(
                    title: 'أوقات الوجبات',
                    value: mealTimes.join('، '),
                    onEdit: () => onEdit(4),
                  ),
                  _ReviewItem(
                    title: 'هدف التحسين',
                    value: improvementGoal,
                    onEdit: () => onEdit(5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D1B4C),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'تأكيد وإرسال',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onEdit;

  const _ReviewItem({
    required this.title,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D1B4C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: Color(0xFF0D1B4C)),
          ),
        ],
      ),
    );
  }
}

// ====================== HELPERS ======================

class OptionSlide extends StatelessWidget {
  final String title;
  final List<Map<String, Object>> options;
  final String selectedValue;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final bool useIcon;
  final bool showNextButton;

  const OptionSlide({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
    required this.onNext,
    this.useIcon = true,
    this.showNextButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 30),
          ...options.map((opt) {
            final String value = opt['value'] as String;
            final bool isSelected = selectedValue == value;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: isSelected ? const Color(0xFF0D1B4C) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                elevation: isSelected ? 4 : 2,
                shadowColor: Colors.black.withOpacity(0.1),
                child: InkWell(
                  onTap: () => onSelect(value), // فقط يختار ولا ينتقل
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (useIcon && opt['icon'] != null) ...[
                          Icon(
                            opt['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Text(
                            opt['title'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              height: 1.4,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0D1B4C),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          if (showNextButton)
            NextButton(
              onPressed: selectedValue.isNotEmpty ? onNext : null,
              text: 'التالي',
            ),
        ],
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const NextButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: onPressed != null ? const Color(0xFF0D1B4C) : Colors.grey,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.cairo(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: onPressed != null ? const Color(0xFF0D1B4C) : Colors.grey),
            ),
            if (onPressed != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildEnhancedInputField({
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
  IconData? prefixIcon,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    style: GoogleFonts.mulish(
      color: const Color(0xFF0D1B4C),
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.cairo(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B4C), width: 2),
      ),
    ),
  );
}

class _UpdateBodyDialog extends StatefulWidget {
  final double currentHeight;
  final double currentWeight;
  const _UpdateBodyDialog(
      {required this.currentHeight, required this.currentWeight});

  @override
  State<_UpdateBodyDialog> createState() => _UpdateBodyDialogState();
}

class _UpdateBodyDialogState extends State<_UpdateBodyDialog> {
  late TextEditingController heightCtrl =
      TextEditingController(text: widget.currentHeight.toInt().toString());
  late TextEditingController weightCtrl =
      TextEditingController(text: widget.currentWeight.toInt().toString());

  @override
  void dispose() {
    heightCtrl.dispose();
    weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تعديل الطول والوزن',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D1B4C),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Inputs
              _buildEnhancedInputField(
                controller: heightCtrl,
                label: 'الطول (سم)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.height,
              ),
              const SizedBox(height: 16),
              _buildEnhancedInputField(
                controller: weightCtrl,
                label: 'الوزن (كجم)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.fitness_center,
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0D1B4C),
                        side: const BorderSide(color: Color(0xFF0D1B4C)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final h = double.tryParse(heightCtrl.text);
                        final w = double.tryParse(weightCtrl.text);
                        if (h != null &&
                            w != null &&
                            h >= 100 &&
                            h <= 250 &&
                            w >= 30 &&
                            w <= 300) {
                          Navigator.pop(context, {'height': h, 'weight': w});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'يرجى إدخال قيم صحيحة (الطول: 100-250 سم، الوزن: 30-300 كجم)',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B4C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'حفظ',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}