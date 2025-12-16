// lib/ui/screens/chatbot_conversation_screen.dart
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../services/gemini_service.dart';
import 'package:flutter/services.dart';

class ChatbotConversationScreen extends StatefulWidget {
  final String? initialMessage;
  final String userName;

  const ChatbotConversationScreen({
    super.key,
    this.initialMessage,
    required this.userName,
  });

  @override
  State<ChatbotConversationScreen> createState() =>
      _ChatbotConversationScreenState();
}

class _ChatbotConversationScreenState extends State<ChatbotConversationScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    // Send the initial message automatically if provided
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialMessage!);
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // If user is editing an existing message
    if (_editingIndex != null) {
      final userIndex = _editingIndex!;
      setState(() {
        _messages[userIndex]['text'] = text;
        _messages[userIndex]['edited'] = true;
        _isLoading = true;
      });

      // Find the bot reply that follows the edited message
      int botIndex = -1;
      for (int i = userIndex + 1; i < _messages.length; i++) {
        if (_messages[i]['role'] == 'bot') {
          botIndex = i;
          break;
        }
      }

      // Get the updated bot reply and replace the old one
      final reply = await _geminiService.sendMessage(text);

      setState(() {
        if (botIndex != -1) {
          _messages[botIndex]['text'] = reply;
        } else {
          _messages.add({'role': 'bot', 'text': reply});
        }
        _isLoading = false;
        _editingIndex = null;
      });

      _controller.clear();
      _scrollToBottom();
      return;
    }

    // Send a new message
    setState(() {
      _messages.add({'role': 'user', 'text': text, 'edited': false});
      _isLoading = true;
    });
    _scrollToBottom();

    final reply = await _geminiService.sendMessage(text);

    setState(() {
      _messages.add({'role': 'bot', 'text': reply});
      _isLoading = false;
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _controller.clear();
      _isLoading = false;
      _editingIndex = null;
    });
  }

  void _editMessage(int index) {
    setState(() {
      _editingIndex = index;
      _controller.text = _messages[index]['text'];
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBot = msg['role'] == 'bot';
    final alignment = isBot ? Alignment.centerLeft : Alignment.centerRight;
    final bubbleColor = isBot
        ? (isDark ? const Color(0xFF1A1D2E) : const Color(0xFFE9F2FF))
        : const Color(0xFF00177E);
    final textColor = isBot
        ? (isDark ? Colors.white : Colors.black87)
        : Colors.white;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            SelectableText(
              msg['text'],
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button for user messages
                if (!isBot)
                  InkWell(
                    onTap: () => _editMessage(index),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          msg['edited'] == true ? "Edit (edited)" : "Edit",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Copy button for bot messages
                if (isBot)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: msg['text']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Copied to clipboard"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Copy",
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : const Color(0xFFE9F2FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: LoadingAnimationWidget.threeArchedCircle(
          color: const Color(0xFF00177E),
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00177E),
        foregroundColor: Colors.white,
        elevation: 3,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/loginLogo.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Aura Assistant',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Start New Chat",
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _startNewChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/loginLogo.png',
                            width: 160,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Hello 👋 I'm Aura, your wellness assistant.\nAsk me anything to get started!",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index], index);
                    },
                  ),
          ),

          // Input field
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black38 : Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: _editingIndex != null
                            ? 'Edit your message...'
                            : 'Type your message...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF1F3F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(_controller.text),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap:
                        _isLoading ? null : () => _sendMessage(_controller.text),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFF00177E),
                      child: _isLoading
                          ? const Icon(Icons.more_horiz, color: Colors.white)
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}