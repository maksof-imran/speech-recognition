import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final _speech = SpeechToText();
  bool _isAvailable = false;
  bool _forceStop = false;
  Function(String text)? onTextResult;
  Function(String status)? onStatus;

  Future<void> init() async {
    _isAvailable = await _speech.initialize(
      onStatus: _statusListener,
      onError: _errorListener,
    );
  }

  void startListening() {
    if (!_isAvailable || _forceStop) return;

    _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase();
        if (text.isNotEmpty) {
          onTextResult?.call(text);
        }
      },
      listenMode: ListenMode.dictation,
      pauseFor: const Duration(seconds: 10),
    );
  }

  void stopListening() {
    _forceStop = true;
    _speech.stop();
  }

  void resumeListening() {
    _forceStop = false;
    startListening();
  }

  void _statusListener(String status) {
    onStatus?.call(status);
    if (_forceStop) return;

    if (status == 'done' || status == 'notListening') {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_forceStop) startListening();
      });
    }
  }

  void _errorListener(SpeechRecognitionError error) {
    if (_forceStop) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!_forceStop) startListening();
    });
  }
}
