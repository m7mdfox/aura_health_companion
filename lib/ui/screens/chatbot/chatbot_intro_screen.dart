// lib/ui/screens/chatbot_intro_screen.dart
import 'package:flutter/material.dart';

class ChatbotIntroScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const ChatbotIntroScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Title
          const Text(
            'AI BOT NAME',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00177E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description text
          const Text(
            'Using this software, you can ask questions and receive articles using an artificial intelligence assistant.',
            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),

          // Enlarged logo
          Image.asset(
            'assets/loginLogo.png',
            width: 280,
            height: 280,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 70),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00177E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
