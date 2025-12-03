// lib/ui/screens/nutrition/widgets/ai_chat_dialog.dart (FIXED & LARGER)
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

  // 🆕 Quick suggestions
  final List<Map<String, dynamic>> _suggestions = [
    {
      'text': 'أكلت مكرونة ودجاج، ينفع أكمل اليوم إيه؟',
      'icon': Icons.restaurant_menu,
    },
    {
      'text': 'إزاي أقلل السكر وأنا مريض سكري؟',
      'icon': Icons.health_and_safety,
    },
    {
      'text': 'ما أفضل وقت لتناول البروتين؟',
      'icon': Icons.access_time,
    },
    {
      'text': 'عايز وصفات صحية سهلة',
      'icon': Icons.book,
    },
    {
      'text': 'إيه أفضل سناك صحي؟',
      'icon': Icons.cookie,
    },
    {
      'text': 'كيف أحسب احتياجي من الماء؟',
      'icon': Icons.water_drop,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
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
      print('🔄 Sending question: $question');
      print('🔄 URL: ${AuthService.baseUrl}/api/nutrition/ask-nutritionist');
      print('🔄 Token: ${AuthService.token}');
      
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/api/nutrition/ask-nutritionist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({'question': question}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('انتهى وقت الاتصال. يرجى المحاولة مرة أخرى.');
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'] ?? 'عذراً، لم أستطع الحصول على إجابة.';
        
        setState(() {
          _messages.add({'role': 'ai', 'text': answer});
        });
        _scrollToBottom();
      } else if (response.statusCode == 404) {
        throw Exception('❌ الـ endpoint غير موجود. تأكد من الـ route في الـ backend');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'خطأ في الخادم');
      }
    } catch (e) {
      print('❌ Error details: $e');
      setState(() {
        _messages.add({
          'role': 'ai',
          'text': 'عذراً، حدث خطأ 😔\n\n📋 تفاصيل الخطأ:\n${e.toString()}\n\n💡 الحلول المقترحة:\n• تأكد من تشغيل الـ backend\n• تأكد من الـ endpoint: /api/nutrition/ask-nutritionist\n• تأكد من الـ token صحيح\n• جرب سؤال آخر',
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        height: screenHeight * 0.88, // 🔥 زودت الارتفاع من 0.8 لـ 0.88
        width: screenWidth * 0.95,    // 🔥 زودت العرض
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMessages()),
            if (_messages.length <= 1) _buildSuggestions(),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24), // 🔥 زودت الـ padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D1B4C),
            const Color(0xFF1a2d6e),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12), // 🔥 زودت الحجم
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 28), // 🔥 زودت الأيقونة
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خبير التغذية الذكي',
                  style: GoogleFonts.cairo(
                    fontSize: 20, // 🔥 زودت الخط
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isLoading ? 'يكتب...' : 'متصل الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 14, // 🔥 زودت الخط
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 26), // 🔥 زودت الأيقونة
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return Container(
      color: Colors.grey.shade50,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20), // 🔥 زودت الـ padding
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isLoading) {
            return _buildTypingIndicator();
          }

          final message = _messages[index];
          final isUser = message['role'] == 'user';

          return Padding(
            padding: const EdgeInsets.only(bottom: 20), // 🔥 زودت المسافة
            child: Row(
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  Container(
                    padding: const EdgeInsets.all(10), // 🔥 زودت الحجم
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0D1B4C),
                          const Color(0xFF1a2d6e),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology,
                        color: Colors.white, size: 22), // 🔥 زودت الأيقونة
                  ),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(16), // 🔥 زودت الـ padding
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF0D1B4C)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isUser
                            ? const Radius.circular(18)
                            : const Radius.circular(4),
                        bottomRight: isUser
                            ? const Radius.circular(4)
                            : const Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      message['text'],
                      style: GoogleFonts.cairo(
                        fontSize: 15.5, // 🔥 زودت الخط
                        color: isUser ? Colors.white : Colors.black87,
                        height: 1.7,
                      ),
                    ),
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10), // 🔥 زودت الحجم
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D1B4C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 22), // 🔥 زودت الأيقونة
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D1B4C),
                  const Color(0xFF1a2d6e),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 5),
                _buildDot(1),
                const SizedBox(width: 5),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 9, // 🔥 زودت الحجم
            height: 9,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 110, // 🔥 زودت الارتفاع
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقتراحات سريعة:',
            style: GoogleFonts.cairo(
              fontSize: 13, // 🔥 زودت الخط
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              suggestion['icon'],
                              size: 18, // 🔥 زودت الأيقونة
                              color: const Color(0xFF0D1B4C),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              suggestion['text'],
                              style: GoogleFonts.cairo(
                                fontSize: 13, // 🔥 زودت الخط
                                color: const Color(0xFF0D1B4C),
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

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(18), // 🔥 زودت الـ padding
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: 'اكتب سؤالك هنا...',
                    hintStyle: GoogleFonts.cairo(
                      color: Colors.grey.shade500,
                      fontSize: 15, // 🔥 زودت الخط
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: GoogleFonts.cairo(fontSize: 15), // 🔥 زودت الخط
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
                onTap: _isLoading
                    ? null
                    : () => _askQuestion(_questionController.text),
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  padding: const EdgeInsets.all(14), // 🔥 زودت الحجم
                  decoration: BoxDecoration(
                    gradient: _isLoading
                        ? null
                        : LinearGradient(
                            colors: [
                              const Color(0xFF0D1B4C),
                              const Color(0xFF1a2d6e),
                            ],
                          ),
                    color: _isLoading ? Colors.grey.shade300 : null,
                    shape: BoxShape.circle,
                    boxShadow: _isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF0D1B4C).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.send,
                    color: Colors.white,
                    size: 22, // 🔥 زودت الأيقونة
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