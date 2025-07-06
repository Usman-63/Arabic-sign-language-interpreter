package com.example.sign_language_interpreter

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.SystemClock
import android.util.Log
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult


class HandLandMarkHelper(
    var minHandDetectionConfidence: Float = DEFAULT_HAND_DETECTION_CONFIDENCE,
    var minHandTrackingConfidence: Float = DEFAULT_HAND_TRACKING_CONFIDENCE,
    var minHandPresenceConfidence: Float = DEFAULT_HAND_PRESENCE_CONFIDENCE,
    var maxNumHands: Int = DEFAULT_NUM_HANDS,
    var currentDelegate: Int = DELEGATE_CPU,
    var runningMode: RunningMode = RunningMode.LIVE_STREAM,
    val context: Context,
    val handLandmarkerHelperListener: LandmarkerListener? = null
) {

    private var handLandmarker: HandLandmarker? = null
    private var poseLandmarker: PoseLandmarker? = null

    init {
        setupHandLandmarker()
        setupPoseLandmarker()
    }

    fun clearHandLandmarker() {
        handLandmarker?.close()
        handLandmarker = null
        poseLandmarker?.close()
        poseLandmarker = null
    }

    fun isClose(): Boolean {
        return handLandmarker == null || poseLandmarker == null
    }

    fun setupHandLandmarker() {
        val baseOptionBuilder = BaseOptions.builder()
            .setModelAssetPath(MP_HAND_LANDMARKER_TASK)

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
            if (handLandmarkerHelperListener == null) {
                throw IllegalStateException("handLandmarkerHelperListener must be set when runningMode is LIVE_STREAM.")
            }
            optionsBuilder
                .setResultListener(this::returnLivestreamResult)
                .setErrorListener(this::returnLivestreamError)
        }

        handLandmarker = HandLandmarker.createFromOptions(context, optionsBuilder.build())
    }

    fun setupPoseLandmarker() {
        val baseOptions = BaseOptions.builder()
            .setModelAssetPath(MP_POSE_LANDMARKER_TASK)
            .setDelegate(Delegate.CPU)
            .build()

        val optionsBuilder = PoseLandmarker.PoseLandmarkerOptions.builder()
            .setBaseOptions(baseOptions)
            .setRunningMode(runningMode)

        if (runningMode == RunningMode.LIVE_STREAM) {
            if (handLandmarkerHelperListener == null) {
                throw IllegalStateException("handLandmarkerHelperListener must be set when runningMode is LIVE_STREAM.")
            }
            optionsBuilder
                .setResultListener { result, input -> returnPoseLivestreamResult(result, input) }
                .setErrorListener { error -> returnLivestreamError(error) }
        }

        val options = optionsBuilder.build()
        poseLandmarker = PoseLandmarker.createFromOptions(context, options)
    }
    private fun returnPoseLivestreamResult(result: PoseLandmarkerResult, input: MPImage) {
        // ignore don't need pose-only results.
        // Or update some state here if needed.
    }
    fun detectLiveStream(imageProxy: ImageProxy, isFrontCamera: Boolean) {
        if (runningMode != RunningMode.LIVE_STREAM) {
            throw IllegalArgumentException("detectLiveStream requires LIVE_STREAM mode")
        }

        val frameTime = SystemClock.uptimeMillis()

        val bitmapBuffer = Bitmap.createBitmap(
            imageProxy.width, imageProxy.height, Bitmap.Config.ARGB_8888
        )
        imageProxy.use { bitmapBuffer.copyPixelsFromBuffer(imageProxy.planes[0].buffer) }
        imageProxy.close()

        val matrix = Matrix().apply {
            postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
            if (isFrontCamera) {
                postScale(-1f, 1f)
            }
        }

        val rotatedBitmap = Bitmap.createBitmap(
            bitmapBuffer, 0, 0, bitmapBuffer.width, bitmapBuffer.height, matrix, true
        )

        val mpImage = BitmapImageBuilder(rotatedBitmap).build()

        poseLandmarker?.detect(mpImage)
        handLandmarker?.detectAsync(mpImage, frameTime)
    }

    private fun returnLivestreamResult(result: HandLandmarkerResult, input: MPImage) {
        val finishTimeMs = SystemClock.uptimeMillis()
        val inferenceTime = finishTimeMs - result.timestampMs()

        val poseResult = poseLandmarker?.detect(input)

        val handLandmarks = result.landmarks().flatMap { hand ->
            hand.map { listOf(it.x(), it.y(), it.z()) }.flatten()
        }

        val armIndices = listOf(11, 12, 13, 14, 15, 16, 21, 22, 19, 20, 17, 18)

        val poseLandmarks = if (poseResult?.landmarks()?.isNotEmpty() == true) {
            armIndices.flatMap { idx ->
                val lm = poseResult.landmarks()[0][idx]
                listOf(lm.x(), lm.y(), lm.z())
            }
        } else {
            List(armIndices.size * 3) { 0.0f }
        }

        val combinedLandmarks = (handLandmarks + poseLandmarks).map { it.toFloat() }.toFloatArray()

        handLandmarkerHelperListener?.onResults(
            ResultBundle(
                combinedLandmarks.toList(),
                inferenceTime,
                input.height,
                input.width
            )
        )
    }

    private fun returnLivestreamError(error: RuntimeException) {
        handLandmarkerHelperListener?.onError(error.message ?: "Unknown error")
    }

    companion object {
        private const val MP_HAND_LANDMARKER_TASK = "hand_landmarker.task"
        private const val MP_POSE_LANDMARKER_TASK = "pose_landmarker.task"

        const val DELEGATE_CPU = 0
        const val DELEGATE_GPU = 1
        const val DEFAULT_HAND_DETECTION_CONFIDENCE = 0.5F
        const val DEFAULT_HAND_TRACKING_CONFIDENCE = 0.5F
        const val DEFAULT_HAND_PRESENCE_CONFIDENCE = 0.5F
        const val DEFAULT_NUM_HANDS = 1
        const val OTHER_ERROR = 0
        const val GPU_ERROR = 1
    }

    data class ResultBundle(
        val combinedLandmarks: List<Float>,
        val inferenceTime: Long,
        val inputImageHeight: Int,
        val inputImageWidth: Int
    )

    interface LandmarkerListener {
        fun onError(error: String, errorCode: Int = OTHER_ERROR)
        fun onResults(resultBundle: ResultBundle)
    }
}
