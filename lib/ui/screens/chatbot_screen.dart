import 'package:flutter/material.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: [Color(0xFF00177E), Color(0xFF0F1120)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Chatbot Screennnnnnnnnnnnn',
          style: TextStyle(fontSize: 24),
        ),
        
      ),
    );
  }
}
