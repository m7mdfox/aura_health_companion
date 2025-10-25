// lib/ui/screens/chatbot_screen.dart
import 'package:flutter/material.dart';
import 'chatbot_intro_screen.dart';
import 'chatbot_welcome_screen.dart';
import 'chatbot_conversation_screen.dart';

class ChatbotScreen extends StatefulWidget {
  final String userName;
  const ChatbotScreen({super.key, required this.userName});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  int _currentStep = 0;

  void _goToNext() => setState(() => _currentStep++);

  bool get _showBottomBar => _currentStep >= 2;

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_currentStep) {
      case 0:
        currentScreen = ChatbotIntroScreen(onContinue: _goToNext);
        break;
      case 1:
        currentScreen = ChatbotWelcomeScreen(
          onContinue: _goToNext,
          userName: widget.userName,
        );
        break;
      case 2:
        currentScreen = ChatbotConversationScreen(
          userName: widget.userName,
        );
        break;
      default:
        currentScreen = ChatbotConversationScreen(
          userName: widget.userName,
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chatbot',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        ),
        child: Container(
          key: ValueKey<int>(_currentStep),
          child: currentScreen,
        ),
      ),
      bottomNavigationBar: _showBottomBar
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF00177E),
              unselectedItemColor: Colors.grey,
              currentIndex: 1,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Companion'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
              onTap: (i) {},
            )
          : null,
    );
  }
}