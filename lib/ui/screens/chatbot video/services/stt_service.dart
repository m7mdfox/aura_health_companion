import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    _isInitialized = await _speechToText.initialize();
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
  }) async {
    if (_isInitialized) {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          } else {
            onPartialResult?.call(result.recognizedWords);
          }
        },
      );
    }
  }

  Future<void> stopListening() async {
    if (_isInitialized) {
      await _speechToText.stop();
    }
  }

  bool get isListening => _speechToText.isListening;
}
