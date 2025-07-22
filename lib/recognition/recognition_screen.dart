import 'package:flutter/material.dart';
import 'package:sign_language_interpreter/recognition/camera_select.dart';
import 'package:sign_language_interpreter/recognition/model_select.dart';
import 'package:sign_language_interpreter/recognition/recognition_camera.dart';

class RecognitionScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const RecognitionScreen({super.key, this.onBack});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  late RecognitionCameraXController _cameraController;

  String? _cameraError;
  bool _isStreaming = false;
  String? _recognizedSignLabel = "No sign recognized";
  String? _recognizedSignConfidence = "N/A";
  String? _cameraDiretion;
  String? _selectedModel;

  @override
  void initState() {
    super.initState();

    _cameraController = RecognitionCameraXController();
    _cameraController.setResultHandler((result) {
      if (result is Map && result['error'] != null) {
        setState(() {
          _cameraError = result['error'].toString();
          _isStreaming = false;
        });
      } else {
        setState(() {
          _recognizedSignLabel =
              result['label']?.toString() ?? 'No sign recognized';

          _recognizedSignConfidence = result['confidence']?.toString() ?? 'N/A';
        });
      }
    });
  }

  Future cameraSelect() {
    return showDialog(
      context: context,
      builder:
          (context) => SelectCamera(
            onCameraSelected: (String direction) {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder:
                    (context) => SelectModel(
                      onModelSelected: (String model) {
                        setState(() {
                          _cameraDiretion = direction;
                          _selectedModel = model;
                        });
                      },
                    ),
              );
            },
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double titleFontSize = size.width / 18;
    final double subtitleFontSize = size.width / 24;
    final double iconFontSize = size.width / 12;

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
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: constraints.maxHeight * 0.65,
                        width: double.infinity,
                        child:
                            (_cameraDiretion == null || _selectedModel == null)
                                ? Center(
                                  child: ElevatedButton(
                                    onPressed: cameraSelect,
                                    child: const Text('Select Camera & Model'),
                                  ),
                                )
                                : CameraXView(
                                  cameraFacing: _cameraDiretion!,
                                  model: _selectedModel == "word",
                                ),
                      ),
                    ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton.icon(
                    onPressed:
                        (_cameraDiretion == null || _selectedModel == null)
                            ? null
                            : !_isStreaming
                            ? () async {
                              setState(() {
                                _isStreaming = true;
                                _recognizedSignLabel = "No sign recognized";
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
                const SizedBox(height: 1),
                if (_isStreaming)
                  Text(
                    'Detecting...',
                    style: TextStyle(
                      color: const Color(0xFF7E22CE),
                      fontWeight: FontWeight.bold,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                if (!_isStreaming && _recognizedSignLabel != null)
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
                      'Recognized Sign: ',
                      style: TextStyle(
                        color: const Color(0xFF7E22CE),
                        fontWeight: FontWeight.bold,
                        fontSize: subtitleFontSize,
                      ),
                    ),
                    subtitle: Text(
                      "$_recognizedSignLabel  $_recognizedSignConfidence",
                      style: TextStyle(
                        color: const Color(0xFF5B21B6),
                        fontSize: subtitleFontSize,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF7E22CE)),
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
