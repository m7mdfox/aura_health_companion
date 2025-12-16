import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// ⚠️ Ensure this path matches your project structure
import 'package:aura_health_companion/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String patientId;

  const ChatScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  List<Map<String, dynamic>> _messages = [];
  late String roomId;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    roomId = "room_${widget.patientId}_${widget.doctorId}";

    _chatService.connect(roomId);
    
    _loadHistory();

    // --- LISTENER FIX: Prevent Duplicates ---
    _chatService.listenForMessages((data) {
      if (mounted) {
        // Only add if the sender is NOT me (since I already added mine optimistically)
        // OR if your server logic handles this, you can remove the check.
        // But this is safer:
        if (data['sender'] != widget.patientId) {
          setState(() {
            _messages.add(data);
          });
          _scrollToBottom();
        }
      }
    });
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await _chatService.getChatHistory(roomId);
    if (mounted) {
      setState(() {
        _messages = history;
        _isLoadingHistory = false;
      });
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendTextMessage() {
    if (_msgController.text.trim().isEmpty) return;

    final msgText = _msgController.text.trim();

    _chatService.sendMessage(
      roomId: roomId,
      senderId: widget.patientId,
      type: 'text',
      message: msgText,
    );

    setState(() {
      _messages.add({
        'sender': widget.patientId,
        'message': msgText,
        'type': 'text',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    _msgController.clear();
    _scrollToBottom();
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      File file = File(image.path);
      
      // Show uploading feedback if needed
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading image..."), duration: Duration(seconds: 1)));

      String? uploadedUrl = await _chatService.uploadImage(file);

      if (uploadedUrl != null) {
        _chatService.sendMessage(
          roomId: roomId,
          senderId: widget.patientId,
          type: 'image',
          imageUrl: uploadedUrl,
          message: 'Sent an image', // Fallback text for old clients
        );

        setState(() {
          _messages.add({
            'sender': widget.patientId,
            'imageUrl': uploadedUrl,
            'type': 'image',
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
        _scrollToBottom();
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image")),
          );
        }
      }
    } catch (e) {
      print("Image Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doctorName, style: const TextStyle(fontSize: 16)),
            const Text("Online", style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
          ],
        ),
        backgroundColor: const Color(0xFF00177E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      // Null check for timestamp
                      final timestamp = msg['timestamp']?.toString() ?? DateTime.now().toIso8601String(); 
                      final isMe = msg['sender'] == widget.patientId;
                      return _buildMessageBubble(msg, isMe, timestamp);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_camera, color: Colors.grey),
                  onPressed: _pickAndSendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00177E),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendTextMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe, String timeStr) {
    // Robust Time Parsing
    String formattedTime = "";
    try {
        formattedTime = DateFormat('HH:mm').format(DateTime.parse(timeStr).toLocal());
    } catch (e) {
        formattedTime = ""; // Fallback if time is broken
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00177E) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg['type'] == 'image' && msg['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  msg['imageUrl']!, // Bang operator is safe due to check above
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                        height: 150, 
                        width: 200, 
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()));
                  },
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              )
            else
              Text(
                msg['message'] ?? "", // Safe Fallback for null text
                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}