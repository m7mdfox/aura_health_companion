import 'dart:io';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  final Dio _dio = Dio();
  // Replace with your IP
  final String _serverUrl = 'http://10.0.2.2:4000'; 

  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  void connect(String roomId) {
    socket = IO.io(_serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.onConnect((_) {
      print('Connected');
      socket.emit('join_room', roomId);
    });
  }

  // --- NEW: Fetch History ---
  Future<List<Map<String, dynamic>>> getChatHistory(String roomId) async {
    try {
      final response = await _dio.get("$_serverUrl/api/chat/history/$roomId");
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print("Error fetching history: $e");
    }
    return [];
  }

  void sendMessage({
    required String roomId,
    required String senderId,
    String? message,
    String? imageUrl,
    required String type,
  }) {
    final data = {
      'room': roomId,
      'sender': senderId,
      'message': message ?? "",
      'imageUrl': imageUrl ?? "",
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    };
    socket.emit('send_message', data);
  }

  void listenForMessages(Function(dynamic) onMessageReceived) {
    socket.on('receive_message', (data) => onMessageReceived(data));
  }

  Future<String?> uploadImage(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });
      Response response = await _dio.post("$_serverUrl/api/upload", data: formData);
      return response.data['url'];
    } catch (e) {
      return null;
    }
  }

  void disconnect() {
    socket.disconnect();
  }
}