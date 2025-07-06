import 'package:tflite_flutter/tflite_flutter.dart';

class RecognitionModelController {
  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  String? modelError;

  Interpreter? get interpreter => _interpreter;
  IsolateInterpreter? get isolateInterpreter => _isolateInterpreter;

  /// Initialize the TFLite model and isolate interpreter
  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/Alphabetmodel.tflite');
      _isolateInterpreter = await IsolateInterpreter.create(
        address: _interpreter!.address,
      );
      modelError = null;
    } catch (e) {
      modelError = 'Model loading error: \n$e';
    }
  }

  /// Dispose interpreters
  void dispose() {
    _interpreter?.close();
    _isolateInterpreter?.close();
    _interpreter = null;
    _isolateInterpreter = null;
    modelError = null;
  }
}
