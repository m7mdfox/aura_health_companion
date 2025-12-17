import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class CoquiTtsService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _baseUrl = "http://192.168.1.10:5002"; // Default URL, can be changed
  Function()? _completionHandler;

  CoquiTtsService() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _completionHandler?.call();
    });
  }

  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  void setCompletionHandler(Function() handler) {
    _completionHandler = handler;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      final url = Uri.parse("$_baseUrl/api/tts");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'speaker_id': 'p225',
          'style_wav': '',
          'language_id': 'en',
        }),
      );

      if (response.statusCode == 200) {
        String? mimeType = response.headers['content-type'];
        // Play the audio bytes directly, specifying mimeType for Web support
        await _audioPlayer.play(
          BytesSource(response.bodyBytes, mimeType: mimeType),
        );
      } else {
        print("Coqui TTS Error: ${response.statusCode} - ${response.body}");
        throw Exception("Coqui Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error calling Coqui TTS: $e");
      rethrow; // Rethrow so the UI can show the error
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
