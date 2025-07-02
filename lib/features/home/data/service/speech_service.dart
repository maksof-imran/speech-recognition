import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  late stt.SpeechToText _speechToText;
  String _currentTranscription = '';
  final Map<String, String> _keywordToVideo = {
    'on': 'assets/videos/sample.mp4',
    'of ': 'assets/videos/sample2.mp4',
  };
  final List<String> _videoQueue = [];
  bool _isListening = false;

  SpeechService() {
    _speechToText = stt.SpeechToText();
  }

  Future<void> initialize() async {
    bool available = await _speechToText.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );
    if (available) {
      startListening();
    }
  }

  void _onStatus(String status) {
    print('Speech status: $status');
    if (status == 'notListening' && _isListening) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (!_speechToText.isListening) {
          startListening();
        }
      });
    }
  }

  void _onError(error) {
    print('Speech error: $error');
    // Optional: restart listening on error
    if (_isListening) {
      Future.delayed(Duration(seconds: 1), () {
        if (!_speechToText.isListening) {
          startListening();
        }
      });
    }
  }

  void startListening() {
    if (!_speechToText.isListening) {
      _speechToText.listen(
        onResult: (result) {
          _currentTranscription = result.recognizedWords.toLowerCase();
          print(result);
          _checkKeywords();
        },
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        pauseFor: const Duration(seconds: 5),
        listenFor: const Duration(seconds: 30),
      );
      _isListening = true;
    }
  }

  void _checkKeywords() {
    for (var keyword in _keywordToVideo.keys) {
      if (_currentTranscription.contains(keyword)) {
        _addToQueue(_keywordToVideo[keyword]!);
        break;
      }
    }
  }

  void _addToQueue(String videoPath) {
    if (!_videoQueue.contains(videoPath)) {
      _videoQueue.add(videoPath);
      print('Added to queue: $videoPath');
    }
  }

  List<String> getVideoQueue() => List.from(_videoQueue);

  void clearQueue() {
    _videoQueue.clear();
  }

  void stopListening() {
    _speechToText.stop();
    _isListening = false;
  }

  void dispose() {
    stopListening();
    _speechToText.cancel();
  }
}
