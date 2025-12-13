// lib/ui/screens/nutrition/widgets/ai_chat_dialog.dart (DARK MODE)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aura_health_companion/data/auth_service.dart';

class AIChatDialog extends StatefulWidget {
  const AIChatDialog({super.key});

  @override
  State<AIChatDialog> createState() => _AIChatDialogState();
}

class _AIChatDialogState extends State<AIChatDialog> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _suggestions = [
    {'text': 'أكلت مكرونة ودجاج، ينفع أكمل اليوم إيه؟', 'icon': Icons.restaurant_menu},
    {'text': 'إزاي أقلل السكر وأنا مريض سكري؟', 'icon': Icons.health_and_safety},
    {'text': 'ما أفضل وقت لتناول البروتين؟', 'icon': Icons.access_time},
    {'text': 'عايز وصفات صحية سهلة', 'icon': Icons.book},
    {'text': 'إيه أفضل سناك صحي؟', 'icon': Icons.cookie},
    {'text': 'كيف أحسب احتياجي من الماء؟', 'icon': Icons.water_drop},
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'ai',
      'text': 'مرحباً! أنا خبير التغذية الذكي 👋\n\nيمكنني مساعدتك في:\n• اقتراح وجبات مناسبة لك\n• الإجابة عن أسئلة التغذية\n• نصائح حسب حالتك الصحية\n\nاسألني أي شيء! 🌟',
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _askQuestion(String question) async {
    if (question.trim().isEmpty) return;

    _questionController.clear();

    setState(() {
      _messages.add({'role': 'user', 'text': question});
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/api/nutrition/ask-nutritionist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({'question': question}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('انتهى وقت الاتصال. يرجى المحاولة مرة أخرى.'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'] ?? 'عذراً، لم أستطع الحصول على إجابة.';
        
        setState(() {
          _messages.add({'role': 'ai', 'text': answer});
        });
        _scrollToBottom();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'خطأ في الخادم');
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'text': 'عذراً، حدث خطأ 😔\n\nجرب سؤال آخر أو تحقق من الاتصال',
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        height: screenHeight * 0.88,
        width: screenWidth * 0.95,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(child: _buildMessages(isDark)),
            if (_messages.length <= 1) _buildSuggestions(isDark),
            _buildInputField(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF252838), const Color(0xFF1A1D2E)]
              : [const Color(0xFF0D1B4C), const Color(0xFF1a2d6e)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خبير التغذية الذكي',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isLoading ? 'يكتب...' : 'متصل الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0F1120) : Colors.grey.shade50,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isLoading) {
            return _buildTypingIndicator(isDark);
          }

          final message = _messages[index];
          final isUser = message['role'] == 'user';

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF60A5FA), const Color(0xFF3B82F6)]
                            : [const Color(0xFF0D1B4C), const Color(0xFF1a2d6e)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser
                          ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C))
                          : (isDark ? const Color(0xFF1A1D2E) : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      message['text'],
                      style: GoogleFonts.cairo(
                        fontSize: 15.5,
                        color: isUser
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                        height: 1.7,
                      ),
                    ),
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF60A5FA), const Color(0xFF3B82F6)]
                    : [const Color(0xFF0D1B4C), const Color(0xFF1a2d6e)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, isDark),
                const SizedBox(width: 5),
                _buildDot(1, isDark),
                const SizedBox(width: 5),
                _buildDot(2, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: isDark ? Colors.white54 : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildSuggestions(bool isDark) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقتراحات سريعة:',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _askQuestion(suggestion['text']),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF252838) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              suggestion['icon'],
                              size: 18,
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D1B4C),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              suggestion['text'],
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252838) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: 'اكتب سؤالك هنا...',
                    hintStyle: GoogleFonts.cairo(
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) => _askQuestion(value),
                  enabled: !_isLoading,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : () => _askQuestion(_questionController.text),
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: _isLoading
                        ? null
                        : LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF60A5FA), const Color(0xFF3B82F6)]
                                : [const Color(0xFF0D1B4C), const Color(0xFF1a2d6e)],
                          ),
                    color: _isLoading
                        ? (isDark ? Colors.white24 : Colors.grey.shade300)
                        : null,
                    shape: BoxShape.circle,
                    boxShadow: _isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: (isDark
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF0D1B4C))
                                  .withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.send,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}