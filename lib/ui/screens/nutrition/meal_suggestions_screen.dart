// lib/ui/screens/nutrition/meal_suggestions_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aura_health_companion/data/auth_service.dart';

class MealSuggestionsScreen extends StatefulWidget {
  const MealSuggestionsScreen({super.key});

  @override
  State<MealSuggestionsScreen> createState() => _MealSuggestionsScreenState();
}

class _MealSuggestionsScreenState extends State<MealSuggestionsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _suggestion;
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  Future<void> _getSuggestion() async {
    if (_caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أدخل السعرات المتبقية', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/api/nutrition/suggest-meal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          'remainingCalories': int.parse(_caloriesController.text),
          'availableIngredients': _ingredientsController.text.isNotEmpty
              ? _ingredientsController.text.split(',').map((e) => e.trim()).toList()
              : [],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _suggestion = data['suggestion'];
          _isLoading = false;
        });
      } else {
        throw Exception('فشل الحصول على الاقتراح');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B4C),
        title: Text(
          'اقتراح وجبات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_suggestion != null)
              _buildSuggestionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'احصل على اقتراح وجبة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'السعرات المتبقية اليوم',
              labelStyle: GoogleFonts.cairo(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.local_fire_department, color: Colors.orange),
            ),
            style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ingredientsController,
            decoration: InputDecoration(
              labelText: 'مكونات موجودة (اختياري)',
              hintText: 'مثال: بيض، دجاج، أرز',
              hintStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              labelStyle: GoogleFonts.cairo(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.kitchen, color: Colors.green),
            ),
            style: GoogleFonts.cairo(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _getSuggestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B4C),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'اقترح وجبة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade600, size: 28),
              const SizedBox(width: 8),
              Text(
                'الوجبة المقترحة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _suggestion!['mealName'],
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildNutrientRow(
            'السعرات',
            '${_suggestion!['calories']} سعرة',
            Icons.local_fire_department,
            Colors.red.shade400,
          ),
          _buildNutrientRow(
            'البروتين',
            '${_suggestion!['protein']}g',
            Icons.egg,
            Colors.orange.shade400,
          ),
          _buildNutrientRow(
            'الكارب',
            '${_suggestion!['carbs']}g',
            Icons.rice_bowl,
            Colors.amber.shade600,
          ),
          _buildNutrientRow(
            'الدهون',
            '${_suggestion!['fats']}g',
            Icons.water_drop,
            Colors.blue.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'المكونات:',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...(_suggestion!['ingredients'] as List).map(
            (ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade400, size: 16),
                  const SizedBox(width: 8),
                  Text(ingredient, style: GoogleFonts.cairo()),
                ],
              ),
            ),
          ),
          if (_suggestion!['preparation'] != null) ...[
            const SizedBox(height: 16),
            Text(
              'طريقة التحضير:',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _suggestion!['preparation'],
              style: GoogleFonts.cairo(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.mulish(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}