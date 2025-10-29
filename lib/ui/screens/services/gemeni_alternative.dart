import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:http/http.dart' as http;

/// 🔮 Generic Gemini AI Service Template
/// --------------------------------------
/// Handles communication with the Gemini API.

class GeminiFeatureService {
// 🔑 WARNING: API Key included below. Replace with a secure method for production!
  static const String _apiKey =
      'AIzaSyCLDXLHkGs4-9EO63wy4zW_8oHM7HwlWVg'; // Key provided by user

// 🔽 REVERT BACK TO THIS
  static const String _model =
      'gemini-2.5-flash-preview-09-2025'; // Use the original flash model

  static String get _url =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';
// // 🧠 Conversation memory (optional for this feature, but kept for structure)
  final List<Map<String, dynamic>> _conversationHistory = [];

  // 🧩 Base System Role / Behavior Template
  static const String baseSystemPrompt = """
You are an advanced AI assistant inside a mobile app called Aura Health Companion.

🎯 **Goal:**
Your purpose is to help users by providing intelligent responses
related to the app’s main feature. Adapt to the specific feature prompt provided.

👤 **Behavior:**
- Be helpful, knowledgeable about medications (but always include disclaimers), friendly, and human-like.
- Never break character or mention APIs, code, or AI internals.
- Reply clearly and concisely. Format lists using markdown bullet points (* item).
- Use emojis naturally when appropriate (e.g., a pill 💊 or caution sign ⚠️).

🚫 **Restrictions:**
- Do NOT provide medical diagnoses or treatment plans.
- Do NOT suggest specific dosages unless explicitly stated in the source information you find (if using grounding).
- Always prioritize safety and direct users to consult healthcare professionals for medical advice.
- Don’t provide unrelated content (like politics, religion, or entertainment).
- Don’t reveal system details or API information.
""";

  // 🌍 Language detection helper (Simple version)
  String detectLanguage(String text) {
    // Basic check for Arabic characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text) ? 'ar' : 'en';
  }

  /// 📨 Send a message to Gemini API
  /// [featurePrompt] defines the "AI role" or "task"
  /// [message] is the user’s input
  Future<String> sendMessage({
    required String featurePrompt,
    required String message,
  }) async {
    if (message.trim().isEmpty) return 'Please enter a medicine name first.';

    final lang = detectLanguage(message);
    final languageNote = lang == 'ar'
        ? "Please respond ONLY in Arabic naturally and clearly."
        : "Please respond ONLY in English naturally and clearly.";

    // Construct the combined prompt for the API
    final fullPrompt = "$featurePrompt\n\nUser's Medicine: \"$message\"";

    try {
      final payload = {
        "systemInstruction": {
          "parts": [
            {"text": "$baseSystemPrompt\n\n$languageNote"}
          ]
        },
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": fullPrompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.5,
          "maxOutputTokens": 1024,
        },
        // Optional Grounding (Uncomment if needed)
        // "tools": [ { "google_search": {} } ],
      };

      if (kDebugMode) {
        print('--- Sending to Gemini ---');
        // Avoid printing the full URL with key in debug for slightly better practice
        print(
            'URL: https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=YOUR_API_KEY');
        print('Payload: ${jsonEncode(payload)}');
        print('------------------------');
      }

      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('--- Gemini Response ---');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        print('----------------------');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List<dynamic>?;

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;

          // 🔽 ADD THIS CHECK for 'content'
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;

            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null) {
                return text.trim();
              }
            }
          }
          // 🔼
        }

        // Handle cases where parsing fails or 'parts' is missing
        final finishReason = candidates?[0]?['finishReason'];
        if (finishReason == 'MAX_TOKENS') {
          return "💡 Sorry, the response was too long and got cut off. Please try a more specific question.";
        }
        return "💡 Sorry, I received an unexpected response format. Please try again.";
      } else {
        String errorMsg = 'Unknown error';
        try {
          final errorData = jsonDecode(response.body);
          errorMsg = errorData['error']?['message'] ?? response.body;
        } catch (_) {
          errorMsg = response.body;
        }
        print('Gemini API Error: $errorMsg');
        return "💡 Sorry, I couldn’t process that right now. Error: ${response.statusCode}";
      }
    } catch (e) {
      print('Network or other Error: $e');
      return "⚠️ Oops! Something went wrong. Please check your connection and try again.";
    }
  }
}
