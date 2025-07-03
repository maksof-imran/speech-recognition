import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:dawaadost_ads/features/home/data/service/speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:collection'; // For Queue
import 'dart:async'; // For Timer

class SpeechWidget extends StatefulWidget {
  const SpeechWidget({super.key});

  @override
  State<SpeechWidget> createState() => _SpeechWidgetState();
}

class _SpeechWidgetState extends State<SpeechWidget> {
  final SpeechService _speechService = SpeechService();
  String _spokenText = "Listening...";
  String _status = "Starting...";
  bool _videoShown = false;
  bool _isVideoVisible = false;
  String? _currentVideo;
  VideoPlayerController? _videoController;
  final Queue<String> _videoQueue = Queue<String>();
  final Set<String> _playedVideos = <String>{};
  Timer? _debounceTimer; // Timer for debouncing speech input

  final Map<String, List<String>> videoToKeywordsMap = {
    'assets/videos/fever.mp4': ['fever', 'bukhar', 'jwar', 'tap'],
    'assets/videos/headech.mp4': [
      'pain',
      'dard',
      'peeda',
      'headaches',
      'headache',
    ],
    'assets/videos/cough.mp4': ['cough', 'khansi', 'khasi'],
    'assets/videos/headache.mp4': ['headache', 'sirdard', 'sar dard'],
    'assets/videos/cold.mp4': ['cold', 'sardi', 'zukaam'],
    'assets/videos/fatigue.mp4': ['fatigue', 'thakan', 'thakavat'],
    'assets/videos/stomachache.mp4': ['stomachache', 'pet dard', 'udar dard'],
    'assets/videos/sorethroat.mp4': [
      'sore throat',
      'gala kharab',
      'galey mein dard',
    ],
    'assets/videos/nausea.mp4': ['nausea', 'ulti', 'matli'],
    'assets/videos/allergy.mp4': ['allergy', 'elergy', 'ruj'],
  };

  @override
  void initState() {
    super.initState();
    // Set app to landscape mode by default
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).catchError((e) {
      print("Error setting orientation to landscape: $e");
    });
    _startSpeechRecognition();
  }

  Future<void> _startSpeechRecognition() async {
    await _speechService.init();

    _speechService.onTextResult = (text) async {
      setState(() => _spokenText = text);
      // Reset debounce timer on new speech input
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 1), () {
        // Process text after a 1-second pause
        _processSpokenText();
      });
    };

    _speechService.onStatus = (status) async {
      setState(() => _status = status);
      // Processing handled by debounce timer
    };

    _speechService.startListening();
  }

  Future<void> _processSpokenText() async {
    if (_videoShown || _spokenText == "Listening...") return;

    List<String> matchedVideos = [];
    for (var entry in videoToKeywordsMap.entries) {
      final videoPath = entry.key;
      final keywords = entry.value;
      for (var word in keywords) {
        if (_spokenText.toLowerCase().contains(word.toLowerCase())) {
          if (!matchedVideos.contains(videoPath) &&
              !_videoQueue.contains(videoPath) &&
              !_playedVideos.contains(videoPath)) {
            matchedVideos.add(videoPath);
          }
          break;
        }
      }
    }

    if (matchedVideos.isNotEmpty) {
      _videoShown = true;
      _videoQueue.addAll(matchedVideos);
      _speechService.stopListening();
      await _playNextVideo();
    } else {
      // Resume listening if no videos matched
      _speechService.resumeListening();
    }
  }

  Future<void> _playNextVideo() async {
    if (_videoQueue.isEmpty) {
      setState(() {
        _videoShown = false;
        _isVideoVisible = false;
        _spokenText = "Listening...";
        _status = "Starting...";
      });
      _playedVideos.clear();
      _speechService.resumeListening();
      // Restore status bar
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      ).catchError((e) {
        print("Error restoring UI: $e");
      });
      return;
    }

    final nextVideo = _videoQueue.removeFirst();
    _playedVideos.add(nextVideo);
    await _playInlineVideo(nextVideo);
  }

  Future<void> _playInlineVideo(String path) async {
    // Hide status bar
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive,
    ).catchError((e) {
      print("Error hiding UI: $e");
    });

    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }

    _currentVideo = path;
    _videoController = VideoPlayerController.asset(path);

    try {
      await _videoController!.initialize();
      if (!mounted) return;

      setState(() {
        _isVideoVisible = true;
      });
      await _videoController!.play();

      _videoController!.addListener(() {
        if (_videoController!.value.position >=
                _videoController!.value.duration &&
            _videoController!.value.isInitialized &&
            !_videoController!.value.isPlaying) {
          _playNextVideo(); // Directly play next video
        }
      });
    } catch (e) {
      print("Error initializing video: $e");
      setState(() {
        _isVideoVisible = false;
        _videoShown = false;
        _spokenText = "Listening...";
        _status = "Starting...";
      });
      _videoQueue.clear();
      _playedVideos.clear();
      _speechService.resumeListening();
      // Restore status bar on error
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      ).catchError((e) {
        print("Error restoring UI: $e");
      });
    }
  }

  Future<void> _stopInlineVideo() async {
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
    if (!mounted) return;
    // Do not reset _isVideoVisible here to prevent flicker
    await _playNextVideo();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _speechService.stopListening();
    _videoController?.dispose();
    _videoQueue.clear();
    _playedVideos.clear();
    // Restore status bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    ).catchError((e) {
      print("Error resetting UI: $e");
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isVideoVisible ? Colors.black : null,
      body: Stack(
        children: [
          // Speech text section
          Visibility(
            visible: !_isVideoVisible,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Status: $_status",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Live Speech Text:",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _spokenText,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Inline Video Section
          if (_isVideoVisible && _videoController != null)
            Center(
              child: _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
