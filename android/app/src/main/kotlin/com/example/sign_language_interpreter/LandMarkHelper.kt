package com.example.sign_language_interpreter

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.SystemClock
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult

class LandMarkHelper(
    var runningMode: RunningMode = RunningMode.LIVE_STREAM,
    val context: Context,
    val handLandmarkerHelperListener: LandmarkerListener? = null,

) {

    var minHandDetectionConfidence: Float = DEFAULT_HAND_DETECTION_CONFIDENCE
    var minHandTrackingConfidence: Float = DEFAULT_HAND_TRACKING_CONFIDENCE
    var minHandPresenceConfidence: Float = DEFAULT_HAND_PRESENCE_CONFIDENCE
    var maxNumHands: Int = DEFAULT_NUM_HANDS
    var currentDelegate: Int = DELEGATE_CPU

    private var aggregatedResult = AggregatedResult()
     private val lock = Any()

    private var handLandmarker: HandLandmarker? = null

    @Volatile
    var isActive = false

    init {
        setupHandLandmarker()
    }

     fun clearHandLandmarker() {
        synchronized(lock) {
            handLandmarker?.close()
            handLandmarker = null
            isActive=false
        }
    }

    fun isClose(): Boolean {
        return handLandmarker == null
    }


    fun setupHandLandmarker() {
        val baseOptionBuilder = BaseOptions.builder().setModelAssetPath(MP_HAND_LANDMARKER_TASK)

        when (currentDelegate) {
            DELEGATE_CPU -> baseOptionBuilder.setDelegate(Delegate.CPU)
            DELEGATE_GPU -> baseOptionBuilder.setDelegate(Delegate.GPU)
        }

        val optionsBuilder = HandLandmarker.HandLandmarkerOptions.builder()
            .setBaseOptions(baseOptionBuilder.build())
            .setMinHandDetectionConfidence(minHandDetectionConfidence)
            .setMinTrackingConfidence(minHandTrackingConfidence)
            .setMinHandPresenceConfidence(minHandPresenceConfidence)
            .setNumHands(maxNumHands)
            .setRunningMode(runningMode)

        if (runningMode == RunningMode.LIVE_STREAM) {
            requireNotNull(handLandmarkerHelperListener) { "handLandmarkerHelperListener must be set when runningMode is LIVE_STREAM." }
            optionsBuilder
                .setResultListener(this::onHandResult)
                .setErrorListener(this::returnLivestreamError)
        }

        handLandmarker = HandLandmarker.createFromOptions(context, optionsBuilder.build())
        isActive=true
    }


    fun detectLiveStream(imageProxy: ImageProxy, isFrontCamera: Boolean) {
        synchronized(lock) {
            if (!isActive || handLandmarker == null) {
                imageProxy.close()
                return
            }
            if (runningMode != RunningMode.LIVE_STREAM) throw IllegalArgumentException("detectLiveStream requires LIVE_STREAM mode")
            try {
                val frameTime = SystemClock.uptimeMillis()

                val bitmapBuffer = Bitmap.createBitmap(imageProxy.width, imageProxy.height, Bitmap.Config.ARGB_8888)
                bitmapBuffer.copyPixelsFromBuffer(imageProxy.planes[0].buffer)

                val matrix = Matrix().apply {
                    postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
                    if (isFrontCamera) postScale(-1f, 1f)
                }

                val rotatedBitmap = Bitmap.createBitmap(bitmapBuffer, 0, 0, bitmapBuffer.width, bitmapBuffer.height, matrix, true)
                val mpImage = BitmapImageBuilder(rotatedBitmap).build()

                aggregatedResult.inputImage = mpImage
                aggregatedResult.timestamp = frameTime

                handLandmarker?.detectAsync(mpImage, frameTime)
            } catch (e: Exception) {
                print(e)
            } finally {
                imageProxy.close()
            }
        }
    }

    private fun onHandResult(result: HandLandmarkerResult, input: MPImage) {
        if (!isActive) return
        aggregatedResult.handResult = result
        checkAndEmitCombinedResult()
    }

    private fun checkAndEmitCombinedResult() {
        if (!aggregatedResult.isComplete()) return

        val handLandmarks = aggregatedResult.handResult?.landmarks()?.firstOrNull()?.flatMap { landmark ->
            listOf(landmark.x(), landmark.y(), landmark.z())
        } ?: List(21 * 3) { 0.0f }


        val inferenceTime = SystemClock.uptimeMillis() - aggregatedResult.timestamp

        handLandmarkerHelperListener?.onResults(
            ResultBundle(
                handLandmarks,
                inferenceTime,
                aggregatedResult.inputImage?.height ?: 0,
                aggregatedResult.inputImage?.width ?: 0
            )
        )

        aggregatedResult = AggregatedResult()
    }

    private fun returnLivestreamError(error: RuntimeException) {
        handLandmarkerHelperListener?.onError(error.message ?: "Unknown error")
    }


    companion object {
        private const val MP_HAND_LANDMARKER_TASK = "hand_landmarker.task"
      //  private const val MP_POSE_LANDMARKER_TASK = "pose_landmarker.task"

        const val DELEGATE_CPU = 0
        const val DELEGATE_GPU = 1
        const val DEFAULT_HAND_DETECTION_CONFIDENCE = 0.5F
        const val DEFAULT_HAND_TRACKING_CONFIDENCE = 0.5F
        const val DEFAULT_HAND_PRESENCE_CONFIDENCE = 0.5F
        const val DEFAULT_NUM_HANDS = 1
        const val OTHER_ERROR = 0
    }

    data class ResultBundle(
        val landmarks: List<Float>,
        val inferenceTime: Long,
        val inputImageHeight: Int,
        val inputImageWidth: Int
    )

    interface LandmarkerListener {
        fun onError(error: String, errorCode: Int = OTHER_ERROR)
        fun onResults(resultBundle: ResultBundle)
    }

    data class AggregatedResult(

        var handResult: HandLandmarkerResult? = null,
        var inputImage: MPImage? = null,
        var timestamp: Long = 0
    ) {
        fun isComplete() = handResult != null
    }



}
