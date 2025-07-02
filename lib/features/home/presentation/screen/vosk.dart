import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vosk_flutter_2/vosk_flutter_2.dart';

class SpeechRecognitionScreen extends StatefulWidget {
  const SpeechRecognitionScreen({Key? key}) : super(key: key);

  @override
  _SpeechRecognitionScreenState createState() =>
      _SpeechRecognitionScreenState();
}

class _SpeechRecognitionScreenState extends State<SpeechRecognitionScreen> {
  static const _textStyle = TextStyle(fontSize: 20, color: Colors.black);
  static const _modelAssetPath = 'assets/hindi_model'; // Hindi model path
  static const _sampleRate = 16000;

  final _vosk = VoskFlutterPlugin.instance();
  String? _error;
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;
  bool _recognitionStarted = false;
  bool _isAppActive = true;
  String _partialResult = '';
  String _finalResult = '';

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) => _initVosk());
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));
  }

  Future<void> _requestPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      print('Microphone permission granted');
    } else {
      setState(() => _error = 'Microphone permission denied');
      print('Microphone permission denied');
    }
  }

  Future<void> _initVosk() async {
    try {
      final modelPath = await _copyModelFromAssets(_modelAssetPath);
      print('Model path: $modelPath');

      // Stop and clear any existing SpeechService
      if (_speechService != null) {
        await _speechService!.stop();
        _speechService = null;
        print('Previous SpeechService stopped and cleared');
      }

      _model = await _vosk.createModel(modelPath);
      print('Model created: ${_model != null}');

      _recognizer = await _vosk.createRecognizer(
        model: _model!,
        sampleRate: _sampleRate,
      );
      print('Recognizer created: ${_recognizer != null}');

      _speechService = await _vosk.initSpeechService(_recognizer!);
      print('Speech service initialized: ${_speechService != null}');

      _speechService!.onPartial().listen((result) {
        setState(() => _partialResult = result);
      });

      _speechService!.onResult().listen((result) {
        setState(() => _finalResult = result);
      });

      setState(() {});
    } catch (e, stackTrace) {
      setState(() => _error = 'Error initializing Vosk: $e');
      print('Error initializing Vosk: $e\nStackTrace: $stackTrace');
    }
  }

  static Future<String> _copyModelFromAssets(String modelAssetPath) async {
    try {
      // Get the app's documents directory (writable)
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetPath = '${appDocDir.path}/hindi_model';
      final targetDir = Directory(targetPath);

      // Check if model already exists
      if (await targetDir.exists()) {
        final requiredFiles = [
          'am/final.mdl',
          'conf/model.conf',
          'conf/mfcc.conf',
        ];
        bool allFilesExist = true;
        for (var file in requiredFiles) {
          if (!await File('$targetPath/$file').exists()) {
            allFilesExist = false;
            print('Missing required file: $targetPath/$file');
            break;
          }
        }
        if (allFilesExist) {
          print('Model already exists at: $targetPath');
          return targetPath;
        } else {
          print(
            'Model exists but missing required files. Deleting and recopying...',
          );
          await targetDir.delete(recursive: true);
        }
      }

      // Create target directory
      await targetDir.create(recursive: true);

      // Load asset manifest
      final manifestContent = await DefaultAssetBundle.of(
        WidgetsBinding.instance.rootElement!,
      ).loadString('AssetManifest.json');
      final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

      // Log available assets for debugging
      print(
        'Available assets in $modelAssetPath: ${manifestMap.keys.where((key) => key.startsWith('$modelAssetPath/')).toList()}',
      );

      // Copy all model files
      final assetFiles = manifestMap.keys
          .where((key) => key.startsWith('$modelAssetPath/'))
          .toList();
      if (assetFiles.isEmpty) {
        throw Exception(
          'No model files found in $modelAssetPath. Check assets/hindi_model/ directory and pubspec.yaml.',
        );
      }

      for (final asset in assetFiles) {
        final relativePath = asset.replaceFirst('$modelAssetPath/', '');
        final targetFile = File('$targetPath/$relativePath');

        // Create directories if they don't exist
        await targetFile.parent.create(recursive: true);

        // Copy asset to file
        final data = await DefaultAssetBundle.of(
          WidgetsBinding.instance.rootElement!,
        ).load(asset);
        await targetFile.writeAsBytes(data.buffer.asUint8List());
        print(
          'Copied: $asset -> $targetFile (${await targetFile.length()} bytes)',
        );
      }

      // Verify required files
      final requiredFiles = [
        'am/final.mdl',
        'conf/model.conf',
        'conf/mfcc.conf',
      ];
      for (var file in requiredFiles) {
        if (!await File('$targetPath/$file').exists()) {
          throw Exception('Required model file $file not found in $targetPath');
        }
      }

      // Log all files in target directory for debugging
      print('Files in target directory:');
      await for (final file in targetDir.list(recursive: true)) {
        print(' - $file');
      }

      print('Model successfully copied to: $targetPath');
      return targetPath;
    } catch (e) {
      throw Exception('Error copying model from assets: $e');
    }
  }

  void _startListening() async {
    if (_speechService != null && _isAppActive) {
      try {
        await _speechService!.start();
        setState(() => _recognitionStarted = true);
        print('Listening started');
      } catch (e) {
        setState(() => _error = 'Error starting recognition: $e');
        print('Error starting recognition: $e');
      }
    }
  }

  void _stopListening() async {
    if (_speechService != null) {
      try {
        await _speechService!.stop();
        setState(() => _recognitionStarted = false);
        print('Listening stopped');
      } catch (e) {
        setState(() => _error = 'Error stopping recognition: $e');
        print('Error stopping recognition: $e');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_AppLifecycleObserver(this));
    if (_speechService != null) {
      _speechService!.stop();
      _speechService = null;
      print('SpeechService disposed');
    }
    _recognizer = null;
    _model = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _stopListening();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Speech Recognition')),
        body: Center(
          child: _error != null
              ? Text('Error: $_error', style: _textStyle)
              : _model == null
              ? const Text('Loading model...', style: _textStyle)
              : _speechService == null
              ? const Text('Initializing speech service...', style: _textStyle)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Partial Result: $_partialResult',
                        style: _textStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Final Result: $_finalResult',
                        style: _textStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      'Listening: ${_recognitionStarted ? "ON" : "OFF"}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_recognitionStarted) {
              _isAppActive = false;
              _stopListening();
            } else {
              _isAppActive = true;
              _startListening();
            }
          },
          child: Icon(_recognitionStarted ? Icons.mic : Icons.mic_none),
        ),
      ),
    );
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final _SpeechRecognitionScreenState _state;

  _AppLifecycleObserver(this._state);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _state._isAppActive = true;
      if (!_state._recognitionStarted && _state._speechService != null) {
        _state._startListening();
      }
    } else {
      _state._isAppActive = false;
      _state._stopListening();
    }
  }
}
