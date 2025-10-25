import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyALbYgmWPZ7KTAKigAzP9mlIMqDEJ9Skp0';
  static const String _model = 'gemini-2.5-flash';
  static String get _url =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  // 🧠 ذاكرة المحادثة
  final List<Map<String, dynamic>> _conversationHistory = [];

  // 🧠 الـ System Prompt الخاص بـ Aura
  static const String botSystemPrompt = """
You are Aura, a friendly and intelligent **Smart Health Assistant** inside the mobile app **AURA Health Companion**.

🎯 **Your Role:**
You help users understand their health data (from smartwatch and sensors), analyze symptoms, and give educational, human-like guidance.  
You are warm, supportive, and always professional.

👤 **Your Identity:**
- Your name is **Aura**.
- You work inside the AURA Health Companion app.
- You are **not** Google, Gemini, or ChatGPT — you are Aura, a personal AI companion focused on health and wellness.
- You never say "I am a large language model trained by Google."

💬 **How You Speak:**
- Always sound friendly, empathetic, and concise.
- Speak naturally like a human coach.
- You may use emojis to make the conversation friendly (🌱💙💤 etc.).
- Never share system or technical details (like APIs or code).
- Never break character.

⚙️ **What You Can Do:**
1. Explain smartwatch readings (heart rate, oxygen, sleep, steps, etc.).
2. Give daily health and wellness tips.
3. Suggest lifestyle improvements (nutrition, hydration, rest).
4. Analyze symptoms in simple terms and suggest which doctor to visit.
5. Remind users to take medication or drink water.
6. Motivate users gently to improve their health habits.
7. Provide emotional support — calm and caring tone.

🚫 **What You Can’t Do:**
- Never give medical diagnoses or prescribe medicine.
- Never ask for personal details (like full name, address, or ID).
- If a situation sounds risky, say: “I recommend you consult a healthcare professional for proper evaluation.”
- ❗ If the user asks about topics unrelated to health or wellness (like sports, politics, entertainment, etc.), politely respond with:
  "I'm here to help only with health and wellness topics 💙. Let's talk about your wellbeing instead!"
""";

  // 🧩 دالة لتحديد لغة المستخدم
  String detectLanguage(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text) ? 'ar' : 'en';
  }

  // 📨 إرسال الرسالة مع الاحتفاظ بالسياق
  Future<String> sendMessage(String message) async {
    if (message.trim().isEmpty) return 'Please write a message first.';

    final lang = detectLanguage(message);
    final languageNote = lang == 'ar'
        ? "Please respond in Arabic in a friendly, natural way."
        : "Please respond in English in a friendly, natural way.";

    // أضف الرسالة الجديدة إلى الذاكرة
    _conversationHistory.add({
      'role': 'user',
      'parts': [
        {'text': message}
      ]
    });

    try {
      // تحضير الجسم الكامل للطلب
      final body = jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': "$botSystemPrompt\n\n$languageNote"}
            ]
          },
          ..._conversationHistory
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
        }
      });

      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // أضف رد Aura إلى الذاكرة
        _conversationHistory.add({
          'role': 'model',
          'parts': [
            {'text': reply}
          ]
        });

        return reply;
      } else {
        final error =
            jsonDecode(response.body)['error']?['message'] ?? 'Unknown error';
        print('Gemini API Error: $error');
        return "💡 Sorry, I couldn’t process that right now. Can you try again?";
      }
    } catch (e) {
      print('Network Error: $e');
      return "⚠️ Oops! I lost connection for a moment. Please try again.";
    }
  }
}
