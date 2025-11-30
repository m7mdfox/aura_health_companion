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
  final int _totalPages = 6;

  // Answers (Defaulting to the Arabic text directly)
  String _lifestyle = '';
  String _eatingRelation = '';
  final List<String> _mealTimes = [''];
  String _improvementGoal = '';

  // Real user data
  String fullName = "جاري التحميل...";
  double heightCm = 170;
  double weightKg = 70;

  bool _isLoading = false;
  bool _isFetchingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
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
            heightCm = (data['height_cm'] ?? 170).toDouble();
            weightKg = (data['weight_kg'] ?? 70).toDouble();
            _isFetchingProfile = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingProfile = false);
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
      );

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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildAuraSnackBar('فشل التحديث', isError: true),
        );
      }
    }
  }

  Future<void> _submitAll() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Sending the exact Arabic strings to the backend
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
      ScaffoldMessenger.of(context).showSnackBar(
        _buildAuraSnackBar('فشل الاتصال', isError: true),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _submitAll();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  /// Custom Aura Snack Bar
  SnackBar _buildAuraSnackBar(String message, {required bool isError}) {
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
                ? const Color(0xFF0D1B4C) // Aura Navy
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
      backgroundColor: Colors.grey.shade50, // Aura Background
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
                    onEdit: _updateBodyMeasurements,
                    onNext: _nextPage,
                    isLoading: _isFetchingProfile,
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
                    onToggle: (key, value) {
                      setState(() {
                        value
                            ? _mealTimes.add(key)
                            : _mealTimes.remove(key);
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

// ====================== ALL SLIDES ======================

class WelcomeSlide extends StatelessWidget {
  final String fullName;
  final VoidCallback onNext;
  const WelcomeSlide({super.key, required this.fullName, required this.onNext});

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
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'مرحبًا $fullName',
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لنصمم لك خطة صحية تناسب جسمك',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'أجب على الأسئلة التالية لنبدأ رحلتك',
            style: GoogleFonts.cairo(
              fontSize: 16,
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
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: const Color(0xFF0D1B4C).withOpacity(0.3),
            ),
            child: Text(
              'ابدأ الآن',
              style: GoogleFonts.cairo(
                fontSize: 20,
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
  final VoidCallback onEdit;
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
          NextButton(onPressed: onNext),
        ],
      ),
    );
  }
}

class LifestyleSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  const LifestyleSlide(
      {super.key,
      required this.selected,
      required this.onSelect,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    // Value equals Title (Arabic)
    final options = [
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
    return OptionSlide(
        title: 'صف يومك النموذجي',
        options: options,
        selectedValue: selected,
        onSelect: (v) {
          onSelect(v);
          onNext();
        },
        onNext: onNext);
  }
}

class EatingRelationSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  const EatingRelationSlide(
      {super.key,
      required this.selected,
      required this.onSelect,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    // Value equals Title (Arabic)
    final options = [
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
    return OptionSlide(
        title: 'كيف تصف علاقتك بالطعام؟',
        options: options,
        selectedValue: selected,
        onSelect: (v) {
          onSelect(v);
          onNext();
        },
        onNext: onNext,
        useIcon: false);
  }
}

class MealTimesSlide extends StatelessWidget {
  final List<String> selectedTimes;
  final void Function(String, bool) onToggle;
  final VoidCallback onNext;
  const MealTimesSlide(
      {super.key,
      required this.selectedTimes,
      required this.onToggle,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    // Key equals Title (Arabic)
    final times = [
      {'key': 'صباحًا مبكرًا', 'title': 'صباحًا مبكرًا'},
      {'key': 'منتصف اليوم', 'title': 'منتصف اليوم'},
      {'key': 'مساءً', 'title': 'مساءً'},
      {'key': 'متنوع حسب اليوم', 'title': 'متنوع حسب اليوم'},
    ];

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
          ...times.map((t) {
            final key = t['key'] as String;
            final bool isSelected = selectedTimes.contains(key);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
                    padding: const EdgeInsets.all(18),
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
          }),
          const Spacer(),
          NextButton(onPressed: onNext),
        ],
      ),
    );
  }
}

class ImprovementGoalSlide extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback? onNext;
  final bool isLoading;
  const ImprovementGoalSlide(
      {super.key,
      required this.selected,
      required this.onSelect,
      this.onNext,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    // Value equals Title (Arabic)
    final goals = [
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
              children: goals.map((g) {
                final bool isSelected = selected == g['value'];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
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
                            Text(
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
                            const Spacer(),
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
          ElevatedButton(
            onPressed: isLoading ? null : onNext,
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
                    'اعرض خطتي',
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

// ====================== HELPERS ======================

class OptionSlide extends StatelessWidget {
  final String title;
  final List<Map<String, Object>> options;
  final String selectedValue;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final bool useIcon;

  const OptionSlide({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
    required this.onNext,
    this.useIcon = true,
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
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: isSelected ? const Color(0xFF0D1B4C) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                elevation: isSelected ? 4 : 2,
                shadowColor: Colors.black.withOpacity(0.1),
                child: InkWell(
                  onTap: () => onSelect(value),
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
          NextButton(onPressed: onNext),
        ],
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  const NextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: const Color(0xFF0D1B4C),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'التالي',
              style: GoogleFonts.cairo(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 18),
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
                          // Handle error
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