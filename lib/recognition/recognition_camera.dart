import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class RecognitionCameraXController {
  static const MethodChannel _channel = MethodChannel('camerax_channel');

  /// Listen for results from native (hand landmarks, errors, etc.)
  void setResultHandler(Function(dynamic) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onResults') {
        handler(call.arguments);
      } else if (call.method == 'onError') {
        handler({'error': call.arguments});
      }
    });
  }

  /// Start detection (if you implement this on the Kotlin side)
  Future<void> startDetection() async {
    await _channel.invokeMethod('startDetection');
  }

  /// Stop detection (if you implement this on the Kotlin side)
  Future<void> stopDetection() async {
    await _channel.invokeMethod('stopDetection');
  }
}

/// Widget to display the native CameraX preview
class CameraXView extends StatelessWidget {
  const CameraXView({super.key});

  @override
  Widget build(BuildContext context) {
    return AndroidView(viewType: 'camerax_view',);
  }
}
