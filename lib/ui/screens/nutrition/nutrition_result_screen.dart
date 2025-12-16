// lib/ui/screens/nutrition/nutrition_result_screen.dart (DARK MODE ENABLED)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:aura_health_companion/data/auth_service.dart';
import 'nutrition_onboarding.dart';
import 'widgets/meal_suggestion_dialog.dart';
import 'widgets/ai_chat_dialog.dart';
import 'widgets/progress_tracker_screen.dart';
import 'widgets/if_timer_screen.dart';

class NutritionResultScreen extends StatefulWidget {
  final Map<String, dynamic> calculations;
  final Map<String, dynamic> plan;

  const NutritionResultScreen({
    super.key,
    required this.calculations,
    required this.plan,
  });

  @override
  State<NutritionResultScreen> createState() => _NutritionResultScreenState();
}

class _NutritionResultScreenState extends State<NutritionResultScreen> {
  int _selectedDay = 0;
  bool _isDeletingPlan = false;
  int _currentTab = 0; // 0: Plan, 1: Progress, 2: IF Timer

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeklyPlan = (widget.plan['weeklyPlan'] as List?) ?? [];

    if (weeklyPlan.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1120) : Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1A1D2E) : const Color(0xFF0D1B4C),
          title: Text('خطتك الغذائية', style: GoogleFonts.cairo()),
        ),
        body: Center(
          child: Text(
            'لا توجد بيانات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : Colors.grey.shade50,
      appBar: _buildAppBar(isDark),
      body: _currentTab == 0
          ? _buildPlanView(weeklyPlan, isDark)
          : _currentTab == 1
              ? ProgressTrackerScreen(
                  targetCalories: widget.calculations['targetCalories'],
                )
              : IFTimerScreen(),
      bottomNavigationBar: _buildBottomNav(isDark),
      floatingActionButton: _currentTab == 0 ? _buildFloatingActions(isDark) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A1D2E) : const Color(0xFF0D1B4C),
      title: Text(
        'خطتك الغذائية',
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AIChatDialog(),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(isDark);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.refresh, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'إعادة إنشاء خطة جديدة',
                    style: GoogleFonts.cairo(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return BottomNavigationBar(
      currentIndex: _currentTab,
      onTap: (index) => setState(() => _currentTab = index),
      selectedItemColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
      unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
      backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.cairo(),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'الخطة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: 'التقدم',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timer),
          label: 'الصيام',
        ),
      ],
    );
  }

  Widget _buildFloatingActions(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'suggest',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => MealSuggestionDialog(
                targetCalories: widget.calculations['targetCalories'],
              ),
            );
          },
          backgroundColor: Colors.orange.shade400,
          child: const Icon(Icons.lightbulb_outline, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'chat',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AIChatDialog(),
            );
          },
          backgroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPlanView(List weeklyPlan, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCaloriesHeader(isDark),
          const SizedBox(height: 20),
          _buildMacrosCards(isDark),
          const SizedBox(height: 20),
          _buildQuickActions(isDark),
          const SizedBox(height: 20),
          _buildDaySelector(weeklyPlan, isDark),
          const SizedBox(height: 20),
          if (weeklyPlan.length > _selectedDay)
            _buildMealsSection(weeklyPlan[_selectedDay], isDark),
          const SizedBox(height: 20),
          _buildTipsSection(isDark),
          const SizedBox(height: 20),
          _buildShoppingListSection(isDark),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCaloriesHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1D2E), const Color(0xFF252838)]
              : [const Color(0xFF0D1B4C), const Color(0xFF1a2d6e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0D1B4C)).withOpacity(0.3),
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
              Icon(Icons.local_fire_department, color: Colors.orange.shade300, size: 28),
              const SizedBox(width: 8),
              Text(
                'هدفك اليومي',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.calculations['targetCalories']}',
            style: GoogleFonts.mulish(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سعرة حرارية',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosCards(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildMacroCard(
              'بروتين',
              '${widget.calculations['proteinGrams']}g',
              Icons.egg_outlined,
              Colors.red.shade400,
              Colors.red.shade50,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMacroCard(
              'كارب',
              '${widget.calculations['carbsGrams']}g',
              Icons.rice_bowl_outlined,
              Colors.orange.shade400,
              Colors.orange.shade50,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMacroCard(
              'دهون',
              '${widget.calculations['fatsGrams']}g',
              Icons.water_drop_outlined,
              Colors.blue.shade400,
              Colors.blue.shade50,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String title, String value, IconData icon, Color color, Color bgColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.2) : bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.mulish(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D1B4C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'اقترح وجبة',
              Icons.lightbulb_outline,
              Colors.orange.shade400,
              isDark,
              () {
                showDialog(
                  context: context,
                  builder: (_) => MealSuggestionDialog(
                    targetCalories: widget.calculations['targetCalories'],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'اسأل خبير',
              Icons.chat_bubble_outline,
              isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
              isDark,
              () {
                showDialog(
                  context: context,
                  builder: (_) => const AIChatDialog(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, bool isDark, VoidCallback onPressed) {
    return Material(
      color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(List weeklyPlan, bool isDark) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: weeklyPlan.length,
        itemBuilder: (context, index) {
          final day = weeklyPlan[index];
          final isSelected = _selectedDay == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF60A5FA), const Color(0xFF3B82F6)]
                            : [const Color(0xFF0D1B4C), const Color(0xFF1a2d6e)],
                      )
                    : null,
                color: isSelected ? null : (isDark ? const Color(0xFF1A1D2E) : Colors.white),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C)).withOpacity(0.3)
                        : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: isSelected ? 15 : 8,
                    offset: Offset(0, isSelected ? 6 : 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day['dayName'] ?? '',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF0D1B4C)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'يوم ${day['day']}',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white70
                          : (isDark ? Colors.white60 : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealsSection(Map<String, dynamic> dayData, bool isDark) {
    final meals = (dayData['meals'] as Map<String, dynamic>?) ?? {};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الوجبات',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 14),
          if (meals.containsKey('breakfast'))
            _buildMealCard('إفطار', meals['breakfast'], Icons.wb_sunny, Colors.orange.shade400, isDark),
          if (meals.containsKey('lunch'))
            _buildMealCard('غداء', meals['lunch'], Icons.restaurant, Colors.green.shade400, isDark),
          if (meals.containsKey('dinner'))
            _buildMealCard('عشاء', meals['dinner'], Icons.nightlight, Colors.purple.shade400, isDark),
        ],
      ),
    );
  }

  Widget _buildMealCard(String mealType, dynamic meal, IconData icon, Color color, bool isDark) {
    if (meal == null || meal is! Map<String, dynamic>) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealType,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      meal['name'] ?? '',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${meal['calories']} سعرة',
                  style: GoogleFonts.mulish(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildNutrientTag('P', meal['protein'], Colors.red.shade400, isDark),
              const SizedBox(width: 8),
              _buildNutrientTag('C', meal['carbs'], Colors.orange.shade400, isDark),
              const SizedBox(width: 8),
              _buildNutrientTag('F', meal['fats'], Colors.blue.shade400, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientTag(String label, dynamic value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${value}g',
        style: GoogleFonts.mulish(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTipsSection(bool isDark) {
    final tips = (widget.plan['tips'] as List?) ?? [];
    if (tips.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                Text(
                  'نصائح مهمة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade400, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip.toString(),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingListSection(bool isDark) {
    final shoppingList = (widget.plan['shoppingList'] as List?) ?? [];
    if (shoppingList.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'قائمة التسوق',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: shoppingList.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.toString(),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تأكيد إعادة الإنشاء',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'هل تريد حذف خطتك الحالية وإنشاء خطة جديدة من البداية؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: isDark ? Colors.white60 : Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'نعم، أعد الإنشاء',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deletePlan();
    }
  }

  Future<void> _deletePlan() async {
    setState(() => _isDeletingPlan = true);

    try {
      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl}/api/nutrition/delete-plan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف الخطة بنجاح', style: GoogleFonts.cairo()),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NutritionOnboardingFlow()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeletingPlan = false);
    }
  }
}