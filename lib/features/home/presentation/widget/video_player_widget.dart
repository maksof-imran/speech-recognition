import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'dart:async';

class VideoPlayerWidget extends StatefulWidget {
  final List<String> initialQueue;

  const VideoPlayerWidget({super.key, required this.initialQueue});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  List<String> _videoQueue = [];
  int _currentIndex = 0;
  int _skipCountdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _videoQueue = List.from(widget.initialQueue);
    _initializeController();
  }

  void _initializeController() {
    if (_videoQueue.isNotEmpty) {
      _videoPlayerController =
          VideoPlayerController.asset(_videoQueue[_currentIndex])
            ..initialize()
                .then((_) {
                  if (mounted) {
                    setState(() {});
                    _videoPlayerController.setLooping(
                      false,
                    ); // Controlled by queue
                    _videoPlayerController.play();
                    _customVideoPlayerController = CustomVideoPlayerController(
                      context: context,
                      videoPlayerController: _videoPlayerController,
                      customVideoPlayerSettings:
                          const CustomVideoPlayerSettings(
                            showPlayButton: false,
                            showSeekButtons: false,
                            showFullscreenButton: false,
                          ),
                    );
                    _startSkipTimer();
                  }
                })
                .catchError((error) {
                  if (mounted) {
                    print("Error loading video: $error");
                    _nextVideo();
                  }
                });
    }
  }

  void _startSkipTimer() {
    _timer?.cancel();
    _skipCountdown = 5;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_skipCountdown > 0) {
            _skipCountdown--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  void _nextVideo() {
    _timer?.cancel();
    _customVideoPlayerController.dispose();
    _videoPlayerController.dispose();
    if (_currentIndex + 1 < _videoQueue.length) {
      _currentIndex++;
    } else {
      _currentIndex = 0; // Loop back to start
    }
    _initializeController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _customVideoPlayerController.dispose();
    _videoPlayerController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _videoPlayerController.value.isInitialized
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CustomVideoPlayer(
                customVideoPlayerController: _customVideoPlayerController,
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
