import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sign_language_interpreter/background_icons.dart';

class RecognitionScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const RecognitionScreen({super.key, this.onBack});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isStreaming = false;
  int _frameCount = 0;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      if (kIsWeb) {
        _cameras = await availableCameras();
        if (_cameras != null && _cameras!.isNotEmpty) {
          _controller = CameraController(
            _cameras![0],
            ResolutionPreset.medium,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.bgra8888,
          );
          await _controller!.initialize();
          setState(() {
            _isCameraInitialized = true;
          });
        } else {
          setState(() {
            _cameraError = 'No camera found on this device.';
          });
        }
      } else {
        _cameras = await availableCameras();
        if (_cameras != null && _cameras!.isNotEmpty) {
          _controller = CameraController(
            _cameras![0],
            ResolutionPreset.medium,
            enableAudio: false,
          );
          await _controller!.initialize();
          setState(() {
            _isCameraInitialized = true;
          });
        } else {
          setState(() {
            _cameraError = 'No camera found on this device.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _cameraError = 'Camera error: \n$e';
      });
    }
  }

  Future<void> _startStreaming() async {
    if (_controller != null && !_isStreaming && !kIsWeb) {
      setState(() {
        _isStreaming = true;
        _frameCount = 0;
      });
      await _controller!.startImageStream((CameraImage image) {
        _frameCount++;
        if (_frameCount >= 30) {
          _controller!.stopImageStream();
          setState(() {
            _isStreaming = false;
          });
        }
      });
    } else if (kIsWeb) {
      setState(() {
        _isStreaming = true;
        _frameCount = 30;
      });
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isStreaming = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double titleFontSize = size.width / 16;
    final double subtitleFontSize = size.width / 24;
    final double iconFontSize = size.width / 12;

    // Decorative icons config (same for appbar and body)
    final List<BackgroundIconData> decorativeIcons = [
      BackgroundIconData(
        icon: Icons.front_hand,
        size: size.width / 3.5,
        angle: 0.2,
        left: -30,
        top: 120,
        color: Colors.deepPurple.withOpacity(0.07),
      ),
      BackgroundIconData(
        icon: Icons.pan_tool_alt_rounded,
        size: size.width / 2.5,
        angle: -0.4,
        right: -60,
        top: 300,
        color: Colors.deepPurpleAccent.withOpacity(0.06),
      ),
      BackgroundIconData(
        icon: Icons.back_hand,
        size: size.width / 5,
        angle: 0.7,
        left: 80,
        bottom: 100,
        color: Colors.deepPurple.withOpacity(0.05),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Decorative icons behind everything
          BackgroundIcons(icons: decorativeIcons),
          LayoutBuilder(
            builder: (context, constraints) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed:
                          widget.onBack ??
                          () => Navigator.of(context).maybePop(),
                    ),
                    expandedHeight:
                        size.height >= 800
                            ? size.height * 0.17
                            : size.height * 0.2,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Camera Recognition',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: true,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Gradient background
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF5B21B6), Color(0xFF7E22CE)],
                              ),
                            ),
                          ),
                          // Decorative icons for the app bar
                          BackgroundIcons(
                            icons: [
                              BackgroundIconData(
                                icon: Icons.front_hand,
                                size: size.width / 7,
                                angle: 0.3,
                                left: -30,
                                top: 20,
                                color: Colors.white.withOpacity(0.09),
                              ),
                              BackgroundIconData(
                                icon: Icons.pan_tool_alt_rounded,
                                size: size.width / 5,
                                angle: -0.4,
                                right: -20,
                                top: 60,
                                color: Colors.white.withOpacity(0.07),
                              ),
                              BackgroundIconData(
                                icon: Icons.back_hand,
                                size: size.width / 10,
                                angle: 0.2,
                                left: 40,
                                bottom: -20,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ],
                          ),
                          // Optional: subtle overlay for depth
                          Container(color: Colors.black.withOpacity(0.04)),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 32),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7E22CE).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              height: constraints.maxWidth < 400 ? 180 : 240,
                              width: constraints.maxWidth < 400 ? 240 : 320,
                              child:
                                  _cameraError != null
                                      ? Center(
                                        child: Text(
                                          _cameraError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                      : _isCameraInitialized &&
                                          _controller != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: AspectRatio(
                                          aspectRatio:
                                              _controller!.value.aspectRatio,
                                          child: CameraPreview(_controller!),
                                        ),
                                      )
                                      : const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                            ),
                            ElevatedButton.icon(
                              onPressed:
                                  _isCameraInitialized && !_isStreaming
                                      ? _startStreaming
                                      : null,
                              icon: Icon(
                                Icons.play_circle_fill,
                                size: iconFontSize,
                              ),
                              label: Text(
                                _isStreaming
                                    ? 'Streaming...'
                                    : kIsWeb
                                    ? 'Show Camera Preview (Web)'
                                    : 'Start Real-Time Recognition',
                                style: TextStyle(fontSize: subtitleFontSize),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7E22CE),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isStreaming)
                              Text(
                                'Streaming 30 frames...',
                                style: TextStyle(
                                  color: const Color(0xFF7E22CE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: subtitleFontSize,
                                ),
                              ),
                            if (!_isStreaming && _frameCount > 0)
                              Text(
                                'Streamed 30 frames.',
                                style: TextStyle(
                                  color: const Color(0xFF7E22CE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: subtitleFontSize,
                                ),
                              ),
                            const SizedBox(height: 32),
                            Card(
                              color: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.check_circle,
                                  color: const Color(0xFF7E22CE),
                                  size: iconFontSize,
                                ),
                                title: Text(
                                  'Recognized Sign:',
                                  style: TextStyle(
                                    color: const Color(0xFF7E22CE),
                                    fontWeight: FontWeight.bold,
                                    fontSize: subtitleFontSize,
                                  ),
                                ),
                                subtitle: Text(
                                  '(Demo)',
                                  style: TextStyle(
                                    color: const Color(0xFF5B21B6),
                                    fontSize: subtitleFontSize,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
