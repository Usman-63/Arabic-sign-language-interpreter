import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class RecognitionCameraXController {
  static const MethodChannel _channel = MethodChannel('camerax_channel');

  void setResultHandler(Function(dynamic) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onResults') {
        handler(call.arguments);
      } else if (call.method == 'onError') {
        handler({'error': call.arguments});
      }
    });
  }

  Future<void> startDetection() async {
    await _channel.invokeMethod('startDetection');
  }

  Future<void> stopDetection() async {
    await _channel.invokeMethod('stopDetection');
  }

  Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
  }
}

class CameraXView extends StatefulWidget {
  final String cameraFacing;
  final bool model;
  const CameraXView({
    super.key,
    required this.cameraFacing,
    required this.model,
  });

  @override
  State<CameraXView> createState() => _CameraXViewState();
}

class _CameraXViewState extends State<CameraXView> {
  late Future<bool> _permissionFuture;

  @override
  void initState() {
    super.initState();
    _permissionFuture = checkCameraPermission();
  }

  Future<bool> checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  void _requestPermissionAndReload() async {
    if (await checkCameraPermission()) {
      setState(() {
        _permissionFuture = Future.value(true);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _permissionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == true) {
          return AndroidView(
            viewType: 'camerax_view',
            creationParams: {
              'cameraFacing': widget.cameraFacing,
              "model": widget.model,
            },
            creationParamsCodec: const StandardMessageCodec(),
          );
        } else {
          return Center(
            child: ElevatedButton(
              onPressed: _requestPermissionAndReload,
              child: const Text('Grant Camera Permission'),
            ),
          );
        }
      },
    );
  }
}
