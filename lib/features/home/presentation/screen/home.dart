import 'dart:async';
import 'package:dawaadost_ads/features/home/data/service/speech_service.dart';
import 'package:dawaadost_ads/features/home/presentation/widget/video_player_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late SpeechService _speechService;
  List<String> _currentQueue = [];
  Timer? _queueTimer;

  @override
  void initState() {
    super.initState();
    _speechService = SpeechService();

    _speechService.initialize().then((_) {
      _queueTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        final updatedQueue = _speechService.getVideoQueue();

        // Only update UI if queue actually changed
        if (!listEquals(_currentQueue, updatedQueue)) {
          if (mounted) {
            setState(() {
              _currentQueue = updatedQueue;
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _queueTimer?.cancel();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentQueue.isNotEmpty
            ? VideoPlayerWidget(initialQueue: _currentQueue)
            : const Center(
                child: Text(
                  'Listening for keywords...',
                  style: TextStyle(fontSize: 18),
                ),
              ),
      ),
    );
  }
}
