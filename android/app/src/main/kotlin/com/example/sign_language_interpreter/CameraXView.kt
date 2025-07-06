package com.example.demo

import android.content.Context
import android.util.Log
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.example.sign_language_interpreter.HandLandMarkHelper
import com.google.mediapipe.tasks.vision.core.RunningMode
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.Executors
import java.util.concurrent.ExecutorService

class CameraXView(
    private val context: Context,
    messenger: BinaryMessenger,
    private val lifecycleOwner: LifecycleOwner
) : PlatformView,
    MethodChannel.MethodCallHandler,
    HandLandMarkHelper.LandmarkerListener,
    DefaultLifecycleObserver {

    private val channel = MethodChannel(messenger, "camerax_channel")
    private val cameraExecutor = Executors.newSingleThreadExecutor()
    private var camera: Camera? = null
    private val previewView = PreviewView(context)
    private var analysisUseCase: ImageAnalysis? = null
    private var isDetectionActive=false

    // Background executor for MediaPipe operations
    private val backgroundExecutor: ExecutorService = Executors.newSingleThreadExecutor()

    // Initialize the MediaPipe helper in LIVE_STREAM mode, passing this as the listener.
    private lateinit var handLandMarkHelper: HandLandMarkHelper

    init {
        channel.setMethodCallHandler(this)
        // Instantiate MediaPipeHelper with LIVE_STREAM mode and listener.
        handLandMarkHelper = HandLandMarkHelper(
            context = context,
            runningMode = RunningMode.LIVE_STREAM,
            handLandmarkerHelperListener = this
        )
        initializeCamera()
        lifecycleOwner.lifecycle.addObserver(this)
    }

    private fun initializeCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()

            // Setup preview use case.
            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }

            // Setup image analysis use case.
            val imageAnalysis = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                .build()
                .also {
                    it.setAnalyzer(cameraExecutor, FrameAnalyzer { image ->
                        processFrame(image)
                        // Do NOT close image here because detectLiveStream() handles it.
                    })
                }

            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

            try {
                cameraProvider.unbindAll()
                camera = cameraProvider.bindToLifecycle(
                    lifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalysis
                )
                analysisUseCase = imageAnalysis
            } catch (exc: Exception) {
                exc.printStackTrace()
            }
        }, ContextCompat.getMainExecutor(context))
    }

    // Lifecycle callback: when resumed, ensure the hand landmarker is set up.
    override fun onResume(owner: LifecycleOwner) {
        backgroundExecutor.execute {
            if (handLandMarkHelper.isClose()) {
                handLandMarkHelper.setupHandLandmarker()
            }
        }
    }

    // Lifecycle callback: when paused, clear the hand landmarker to free resources.
    override fun onPause(owner: LifecycleOwner) {
        backgroundExecutor.execute {
            handLandMarkHelper.clearHandLandmarker()
        }
    }


    override fun getView() = previewView

    // Process each camera frame.
    private fun processFrame(image: ImageProxy) {
        // For a back camera, isFrontCamera is false.
        if( !isDetectionActive ) {
            image.close() // Close the image if detection is not active.
            return
        }
        try {
            handLandMarkHelper.detectLiveStream(image, isFrontCamera = false)
        } catch (e: Exception) {
            Log.e("CameraXView", "Error processing frame: ${e.message}")
            // If detectLiveStream throws an error, you can handle it or notify Flutter.
        }
    }



    override fun dispose() {
        analysisUseCase?.clearAnalyzer()
        cameraExecutor.shutdown()
        backgroundExecutor.shutdown()
        channel.setMethodCallHandler(null)
        lifecycleOwner.lifecycle.removeObserver(this)
        handLandMarkHelper.clearHandLandmarker()
        isDetectionActive = false
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startDetection" -> {
                if (!isDetectionActive) {
                    isDetectionActive = true
                    handLandMarkHelper.setupHandLandmarker()
                    result.success("Detection started")
                } else {
                    result.error("ALREADY_ACTIVE", "Detection is already active", null)
                }
            }
            "stopDetection" -> {
                if (isDetectionActive) {
                    isDetectionActive = false
                    handLandMarkHelper.clearHandLandmarker()
                    result.success("Detection stopped")
                } else {
                    result.error("NOT_ACTIVE", "Detection is not active", null)
                }
            }

        }
    }


    private class FrameAnalyzer(
        private val onFrame: (ImageProxy) -> Unit
    ) : ImageAnalysis.Analyzer {
        override fun analyze(image: ImageProxy) {
            onFrame(image)
        }
    }

    // Callback from MediapipeHelper when a detection error occurs.
    override fun onError(error: String, errorCode: Int) {
        Log.e("CameraXView", "Mediapipe error: $error (Code: $errorCode)")
        // Optionally, you can pass this error to Flutter.
    }

    // Callback from MediapipeHelper when hand landmark results are available.
    override fun onResults(resultBundle: HandLandMarkHelper.ResultBundle) {
        Log.d("CameraXView", "Hand landmarks detected: ${resultBundle.combinedLandmarks}")

        // Optionally, send these results to Flutter using:
        // channel.invokeMethod("onResults", resultData)
    }
}
