// lib/ui/screens/mental_health/mood_questions_screen.dart
import 'package:aura_health_companion/ui/screens/mental_health/questions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:aura_health_companion/data/auth_service.dart';

class MoodQuestionsScreen extends StatefulWidget {
  final String moodLabel;
  final Color moodColor;

  const MoodQuestionsScreen({
    super.key,
    required this.moodLabel,
    required this.moodColor,
  });

  @override
  State<MoodQuestionsScreen> createState() => _MoodQuestionsScreenState();
}

class _MoodQuestionsScreenState extends State<MoodQuestionsScreen> {
  static final TextStyle _poppins =
      TextStyle(fontFamily: GoogleFonts.poppins().fontFamily);

  late List<Question> _currentQuestions;
  late List<Set<int>> _usedIndices;

  final List<TextEditingController> _controllers = [];
  final List<bool?> _boolAnswers = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
    _initializeControllers();
  }

  void _initializeQuestions() {
    final allQuestions = _getAllQuestionsForMood();
    _currentQuestions = [];
    _usedIndices = [];

    for (int i = 0; i < allQuestions.length; i++) {
      _currentQuestions.add(allQuestions[i]);
      _usedIndices.add({i});
    }
  }

  List<Question> _getAllQuestionsForMood() {
    final key = widget.moodLabel.toLowerCase();
    return moodQuestions[key] ?? moodQuestions['neutral']!;
  }

  void _initializeControllers() {
    for (int i = 0; i < _currentQuestions.length; i++) {
      _controllers.add(TextEditingController());
      _boolAnswers.add(null);
    }
  }

  void _replaceQuestion(int index) {
    final allQuestions = _getAllQuestionsForMood();
    final used = _usedIndices[index];
    final available = allQuestions
        .asMap()
        .entries
        .where((e) => !used.contains(e.key))
        .toList();

    if (available.isEmpty) {
      available.addAll(allQuestions.asMap().entries);
    }

    final randomEntry = available[Random().nextInt(available.length)];
    final newQuestion = randomEntry.value;
    final newOriginalIndex = randomEntry.key;

    setState(() {
      _currentQuestions[index] = newQuestion;
      _usedIndices[index].add(newOriginalIndex);
      _controllers[index].clear();
      _boolAnswers[index] = null;
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _backButton(isDark),
        ),
        title: Text(
          '${widget.moodLabel} ${LocaleProvider.currentLocale == 'ar' ? 'تأمل' : 'Reflection'}',
          style: _poppins.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                LocaleProvider.currentLocale == 'ar'
                    ? 'أخبرنا المزيد عن شعورك'
                    : 'Tell us more about how you feel',
                style: _poppins.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _currentQuestions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionCard(
                    question: _currentQuestions[index],
                    index: index,
                    isDark: isDark,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildSubmitButton(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required Question question,
    required int index,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.1)
            : widget.moodColor.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question.text,
                  style: _poppins.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _replaceQuestion(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.moodColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh,
                    size: 18,
                    color: widget.moodColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (question.hint.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                question.hint,
                style: _poppins.copyWith(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (question.type == QuestionType.text || question.type == QuestionType.number)
            TextField(
              controller: _controllers[index],
              style: _poppins.copyWith(
                fontSize: 14, 
                color: isDark ? Colors.white : const Color(0xFF475569)
              ),
              decoration: InputDecoration(
                hintText: question.hint.isNotEmpty ? null : 'Type your answer...',
                hintStyle: _poppins.copyWith(
                  fontSize: 14, 
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8)
                ),
                filled: true,
                fillColor: isDark 
                  ? const Color(0xFF0F1120) 
                  : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: question.type == QuestionType.text ? 3 : 1,
              keyboardType: question.type == QuestionType.number
                  ? TextInputType.number
                  : TextInputType.text,
            )
          else if (question.type == QuestionType.true_false)
            Row(
              children: [
                _buildToggleButton('Yes', true, index, isDark),
                const SizedBox(width: 12),
                _buildToggleButton('No', false, index, isDark),
              ],
            )
          else if (question.type == QuestionType.multiple_choice)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: question.options.asMap().entries.map((e) {
                final option = e.value;
                final isSelected = _controllers[index].text == option;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers[index].text = isSelected ? '' : option;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? widget.moodColor 
                        : (isDark ? const Color(0xFF0F1120) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                          ? widget.moodColor 
                          : (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      option,
                      style: _poppins.copyWith(
                        fontSize: 13,
                        color: isSelected 
                          ? Colors.white 
                          : (isDark ? Colors.white70 : const Color(0xFF475569)),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool value, int index, bool isDark) {
    final isSelected = _boolAnswers[index] == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _boolAnswers[index] = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
              ? widget.moodColor 
              : (isDark ? const Color(0xFF0F1120) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected 
                ? widget.moodColor 
                : (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: _poppins.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected 
                ? Colors.white 
                : (isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitAnswers,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.moodColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: widget.moodColor.withOpacity(0.4),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                LocaleProvider.currentLocale == 'ar' ? 'إرسال' : 'Submit',
                style: _poppins.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _submitAnswers() async {
    final answers = <String, dynamic>{};

    for (int i = 0; i < _currentQuestions.length; i++) {
      final q = _currentQuestions[i];
      final key = q.en.split('?').first.trim().toLowerCase().replaceAll(' ', '_');

      if (q.type == QuestionType.true_false) {
        if (_boolAnswers[i] == null) {
          _showError('Please answer: ${q.text}');
          return;
        }
        answers[key] = _boolAnswers[i];
      } else if (q.type == QuestionType.multiple_choice) {
        final text = _controllers[i].text.trim();
        if (text.isEmpty) {
          _showError('Please select an option for: ${q.text}');
          return;
        }
        answers[key] = text;
      } else {
        final text = _controllers[i].text.trim();
        if (text.isEmpty && q.type == QuestionType.text) {
          _showError('Please answer: ${q.text}');
          return;
        }
        answers[key] = text;
      }
    }

    setState(() => _isSubmitting = true);

    final userId = AuthService.profile?['auth_id'] ?? AuthService.profile?['user_id'];
    if (userId == null) {
      _showError('User not logged in');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/api/moods/answers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'auth_id': userId,
          'mood_type': widget.moodLabel.toLowerCase(),
          'answers': answers,
          'language': LocaleProvider.currentLocale,
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocaleProvider.currentLocale == 'ar' ? 'تم الحفظ بنجاح' : 'Saved successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _backButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark 
              ? const Color(0xFF0F1120).withOpacity(0.7)
              : Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark 
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.5), 
              width: 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), 
                blurRadius: 12, 
                offset: const Offset(1, 3)
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back, 
            color: isDark ? Colors.white70 : const Color(0xFF475569), 
            size: 22
          ),
        ),
      ),
    );
  }
}