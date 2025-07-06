import 'package:flutter/material.dart';
import 'package:sign_language_interpreter/background_icons.dart';
import 'package:sign_language_interpreter/recognition/recognition_camera.dart';
import 'package:sign_language_interpreter/recognition/recognition_model.dart';

class RecognitionScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const RecognitionScreen({super.key, this.onBack});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  late RecognitionModelController _modelController;
  late RecognitionCameraXController _cameraController;

  String? _cameraError;
  bool _isStreaming = false;
  String? _recognizedSign;

  @override
  void initState() {
    super.initState();
    _modelController = RecognitionModelController();
    _modelController.initModel().then((_) {
      setState(() {});
    });

    _cameraController = RecognitionCameraXController();
    _cameraController.setResultHandler((result) {
      if (result is Map && result['error'] != null) {
        setState(() {
          _cameraError = result['error'].toString();
          _isStreaming = false;
        });
      } else {
        setState(() {
          _recognizedSign = result.toString();
          print('Recognized sign: ${_recognizedSign}');
          _isStreaming = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double titleFontSize = size.width / 18;
    final double subtitleFontSize = size.width / 24;
    final double iconFontSize = size.width / 12;

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Camera Recognition',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _cameraError != null && !_isStreaming
                    ? Center(
                      child: Text(
                        _cameraError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        height: constraints.maxHeight * 0.68,
                        width: double.infinity,
                        child: CameraXView(),
                      ),
                    ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed:
                        !_isStreaming
                            ? () async {
                              setState(() {
                                _isStreaming = true;
                                _recognizedSign = null;
                              });
                              await _cameraController.startDetection();
                            }
                            : () async {
                              setState(() {
                                _isStreaming = false;
                              });
                              await _cameraController.stopDetection();
                            },
                    icon: Icon(Icons.play_circle_fill, size: iconFontSize),
                    label: Text(
                      _isStreaming
                          ? 'Stop Real-Time Recognition'
                          : 'Start Real-Time Recognition',
                      style: TextStyle(fontSize: subtitleFontSize),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E22CE),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                if (_isStreaming)
                  Text(
                    'Detecting...',
                    style: TextStyle(
                      color: const Color(0xFF7E22CE),
                      fontWeight: FontWeight.bold,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                if (!_isStreaming && _recognizedSign != null)
                  Text(
                    'Detection complete.',
                    style: TextStyle(
                      color: const Color(0xFF7E22CE),
                      fontWeight: FontWeight.bold,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                const SizedBox(height: 5),
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
                      _recognizedSign ?? '(No result yet)',
                      style: TextStyle(
                        color: const Color(0xFF5B21B6),
                        fontSize: subtitleFontSize,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: const Color(0xFF7E22CE),
                  ),
                  onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                ),
                SizedBox(height: 2),
              ],
            ),
          );
        },
      ),
    );
  }
}
