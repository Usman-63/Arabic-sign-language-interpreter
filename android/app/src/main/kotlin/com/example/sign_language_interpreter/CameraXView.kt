package com.example.sign_language_interpreter

import android.content.Context
import android.os.Handler
import android.os.Looper
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
    private val lifecycleOwner: LifecycleOwner,
    creationParams: Map<String?, Any?>?
) : PlatformView,
    MethodChannel.MethodCallHandler,
    LandMarkHelper.LandmarkerListener,

    DefaultLifecycleObserver {
    private val cameraFacing = creationParams?.get("cameraFacing") as? String ?: "back"
    private val modelSelection = creationParams?.get("model") as? Boolean ?: false
    private val channel = MethodChannel(messenger, "camerax_channel")
    private val cameraExecutor = Executors.newSingleThreadExecutor()
    private var camera: Camera? = null
    private val previewView = PreviewView(context)
    private var analysisUseCase: ImageAnalysis? = null
    private var isDetectionActive=false
    private val recognizer = ModelRecognize(
        context,
        modelSelection =  modelSelection 
    )
    private val detectionLock = Any()

    // Background executor for MediaPipe operations
    private val backgroundExecutor: ExecutorService = Executors.newSingleThreadExecutor()

    // Initialize the MediaPipe helper in LIVE_STREAM mode, passing this as the listener.
    private lateinit var landMarkHelper: LandMarkHelper

    init {
        channel.setMethodCallHandler(this)
        // Instantiate MediaPipeHelper with LIVE_STREAM mode and listener.
        landMarkHelper = LandMarkHelper(
            context = context,
            runningMode = RunningMode.LIVE_STREAM,
            handLandmarkerHelperListener = this,
            modelSelection=modelSelection,

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
                it.surfaceProvider = previewView.surfaceProvider
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
            val cameraSelector = if (cameraFacing == "front") {
                CameraSelector.DEFAULT_FRONT_CAMERA
            } else {
                CameraSelector.DEFAULT_BACK_CAMERA
            }

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
            if (landMarkHelper.isClose()) {
                landMarkHelper.setupHandLandmarker()
                if(modelSelection)
                landMarkHelper.setupPoseLandmarker()
            }
        }
    }

    // Lifecycle callback: when paused, clear the hand landmarker to free resources.
    override fun onPause(owner: LifecycleOwner) {
        backgroundExecutor.execute {
            landMarkHelper.clearLandmarker()
        }
    }


    override fun getView() = previewView

  private fun processFrame(image: ImageProxy) {
        synchronized(detectionLock) {
            if (!isDetectionActive || landMarkHelper.isClose()) {
                image.close()
                return
            }
            
            try {
                backgroundExecutor.execute {
                    landMarkHelper.detectLiveStream(image,isFrontCamera = (cameraFacing == "front"))
                }
            } catch (e: Exception) {
                Log.e("CameraXView", "Frame processing error", e)
                image.close()
            }
        }
    }



  override fun dispose() {
        synchronized(detectionLock) {
            isDetectionActive = false
            analysisUseCase?.clearAnalyzer()
            landMarkHelper.clearLandmarker()
            recognizer.close()
        }
        cameraExecutor.shutdown()
        backgroundExecutor.shutdown()

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
        "dispose" ->{
            synchronized(detectionLock){
                dispose()
            }
        }

        "startDetection" -> {
            synchronized(detectionLock) {
                if (!isDetectionActive) {
                    try {
                        isDetectionActive = true
                        landMarkHelper.setupHandLandmarker()
                        if(modelSelection)
                            landMarkHelper.setupPoseLandmarker()
                        bindAnalyzer()
                        result.success("Detection started")
                    } catch (e: Exception) {
                        isDetectionActive = false
                        result.error("START_FAILED", e.message, null)
                    }
                }
            }
        }
        
        "stopDetection" -> {
            synchronized(detectionLock) {
                if (isDetectionActive) {
                    try {
                        isDetectionActive = false
                        unbindAnalyzer()
                        landMarkHelper.clearLandmarker()
                        result.success("Detection stopped")
                    } catch (e: Exception) {
                        result.error("STOP_FAILED", e.message, null)
                    }
                }
            }
        }
    }
}
    private fun bindAnalyzer() {
        analysisUseCase?.setAnalyzer(cameraExecutor, FrameAnalyzer { image ->
            processFrame(image)
        })
    }

    private fun unbindAnalyzer() {
        analysisUseCase?.clearAnalyzer()
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
    override fun onResults(resultBundle: LandMarkHelper.ResultBundle) {
        if (!isDetectionActive) return
        if(resultBundle.landmarks.all { it == 0f }) return
        var combinedLandmarks=resultBundle.landmarks


       if(modelSelection){

           combinedLandmarks=combinedLandmarks+ resultBundle.poseLandmarks
           if(combinedLandmarks.size<162) return
       }


        val predictionMap = recognizer.addFrame(combinedLandmarks.toFloatArray())
        println(message = "wordLabel is" + predictionMap?.get("label"))
        // Only send results if we have a valid prediction
        predictionMap?.let {
            val resultMap = mapOf(
                "landmarks" to combinedLandmarks,
                "inferenceTime" to resultBundle.inferenceTime,
                "inputImageHeight" to resultBundle.inputImageHeight,
                "inputImageWidth" to resultBundle.inputImageWidth,
                "label" to it["label"],
                "confidence" to it["confidence"]
            )

            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onResults", resultMap)
            }
        }
    }
    

    }