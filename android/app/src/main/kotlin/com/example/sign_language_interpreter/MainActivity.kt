package com.example.sign_language_interpreter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "camerax_view",
            CameraXFactory(
                flutterEngine.dartExecutor.binaryMessenger,
                this
            )
        )
    }
}
