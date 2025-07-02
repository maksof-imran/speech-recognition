import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:dawaadost_ads/features/home/data/service/speech_service.dart';
import 'package:flutter/material.dart';
import 'dart:collection'; // For Queue

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
  final Queue<String> _videoQueue = Queue<String>(); // Queue for videos
  final Set<String> _playedVideos = <String>{}; // Track played videos

  final Map<String, List<String>> videoToKeywordsMap = {
    'assets/videos/sample.mp4': ['fever', 'bukhar', 'jwar', 'tap'], // Fever
    'assets/videos/sample2.mp4': ['pain', 'dard', 'peeda'], // Pain
    'assets/videos/cough.mp4': ['cough', 'khansi', 'khasi'], // Cough
    'assets/videos/headache.mp4': [
      'headache',
      'sirdard',
      'sar dard',
    ], // Headache
    'assets/videos/cold.mp4': ['cold', 'sardi', 'zukaam'], // Cold
    'assets/videos/fatigue.mp4': ['fatigue', 'thakan', 'thakavat'], // Fatigue
    'assets/videos/stomachache.mp4': [
      'stomachache',
      'pet dard',
      'udar dard',
    ], // Stomachache
    'assets/videos/sorethroat.mp4': [
      'sore throat',
      'gala kharab',
      'galey mein dard',
    ], // Sore throat
    'assets/videos/nausea.mp4': ['nausea', 'ulti', 'matli'], // Nausea
    'assets/videos/allergy.mp4': ['allergy', 'elergy', 'ruj'], // Allergy
  };

  @override
  void initState() {
    super.initState();
    _startSpeechRecognition();
  }

  Future<void> _startSpeechRecognition() async {
    await _speechService.init();

    _speechService.onTextResult = (text) async {
      setState(() => _spokenText = text);
    };

    _speechService.onStatus = (status) async {
      setState(() => _status = status);

      // When speech recognition stops, process the spoken text
      if (status == 'done' || status == 'notListening') {
        if (_videoShown || _spokenText == "Listening...") return;

        // Collect all matching video paths
        List<String> matchedVideos = [];
        for (var entry in videoToKeywordsMap.entries) {
          final videoPath = entry.key;
          final keywords = entry.value;
          for (var word in keywords) {
            if (_spokenText.toLowerCase().contains(word.toLowerCase())) {
              // Only add video if not in queue or already played
              if (!matchedVideos.contains(videoPath) &&
                  !_videoQueue.contains(videoPath) &&
                  !_playedVideos.contains(videoPath)) {
                matchedVideos.add(videoPath);
              }
              break; // Move to next video
            }
          }
        }

        // Add matched videos to queue
        if (matchedVideos.isNotEmpty) {
          _videoShown = true;
          _videoQueue.addAll(matchedVideos);
          _speechService.stopListening();
          await _playNextVideo();
        }
      }
    };

    _speechService.startListening();
  }

  Future<void> _playNextVideo() async {
    if (_videoQueue.isEmpty) {
      setState(() {
        _videoShown = false;
        _spokenText = "Listening..."; // Reset spoken text
        _status = "Starting..."; // Reset status
      });
      _playedVideos.clear(); // Reset played videos
      _speechService.resumeListening();
      return;
    }

    final nextVideo = _videoQueue.removeFirst();
    _playedVideos.add(nextVideo); // Mark video as played
    await _playInlineVideo(nextVideo);
  }

  Future<void> _playInlineVideo(String path) async {
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
          _stopInlineVideo();
        }
      });
    } catch (e) {
      print("Error initializing video: $e");
      setState(() {
        _isVideoVisible = false;
        _videoShown = false;
        _spokenText = "Listening..."; // Reset on error
        _status = "Starting..."; // Reset on error
      });
      _videoQueue.clear(); // Clear queue on error
      _playedVideos.clear(); // Reset played videos on error
      _speechService.resumeListening();
    }
  }

  Future<void> _stopInlineVideo() async {
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
    if (!mounted) return;
    setState(() {
      _isVideoVisible = false;
    });
    // Play next video in queue
    await _playNextVideo();
  }

  @override
  void dispose() {
    _speechService.stopListening();
    _videoController?.dispose();
    _videoQueue.clear();
    _playedVideos.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isVideoVisible ? Colors.black : null,
      body: Stack(
        children: [
          // 🔈 Speech text section
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

          // 🎥 Inline Video Section
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
