package com.example.sign_language_interpreter

import android.content.Context
import android.util.Log
import org.tensorflow.lite.Interpreter
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

class ModelRecognize(
    context: Context,
    private val modelSelection: Boolean // true for word model, false for alphabet model
) {
    private var interpreter: Interpreter?=null
    private var wordInterpreter: Interpreter? = null
    private var frameCounter = 0

    private val alphabetBuffer = mutableListOf<FloatArray>()
    private val wordBuffer = mutableListOf<FloatArray>()

    init {
        if (modelSelection) {
            val wordModel = loadModelFile(context, "Wordmodel.tflite")
            wordInterpreter = Interpreter(wordModel)
            val inputShape = wordInterpreter!!.getInputTensor(0).shape()
            Log.d("WordModelInput", "Word model expects shape: ${inputShape.contentToString()}")
            require(inputShape.contentEquals(intArrayOf(1, 30, 162))) {
                "Model expects shape [1, 30, 162] but got ${inputShape.contentToString()}"
            }

        } else {
            val model = loadModelFile(context, "Alphabetmodel.tflite")
            interpreter = Interpreter(model)
            val inputShape = interpreter!!.getInputTensor(0).shape()
            Log.d("ModelInput", "Alphabet model expects shape: ${inputShape.contentToString()}")
            require(inputShape.contentEquals(intArrayOf(1, 63, 1))) {
                "Model expects shape [1, 63, 1] but got ${inputShape.contentToString()}"
            }
        }


    }

    private fun loadModelFile(context: Context, modelName: String): MappedByteBuffer {
        val fileDescriptor = context.assets.openFd(modelName)
        val inputStream = fileDescriptor.createInputStream()
        val fileChannel = inputStream.channel
        val startOffset = fileDescriptor.startOffset
        val declaredLength = fileDescriptor.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    }



    fun addFrame(frame: FloatArray): Map<String, Any>? {
        return if (modelSelection) {
            wordBuffer.add(frame)
            if (wordBuffer.size >= 30) {
                val sequence = wordBuffer.takeLast(30)

                val merged = sequence.flatMap { it.toList() }.toFloatArray()
                val prediction=predictWordFrame(merged).takeIf {  (it["confidence"] as Float) > 0.5f }
                wordBuffer.clear()
                return prediction
            } else {
                null // not enough frames yet
            }
        } else {
            // ALPHABET model logic (predict every 5th frame)
            frameCounter++
            if (frameCounter % 5 == 0) {
                predictAlphabetFrame(frame).takeIf {
                    (it["confidence"] as Float) > 0.5f
                }
            } else null
        }
    }

    // For alphabet model (hand landmarks only)
    private fun predictAlphabetFrame(frame: FloatArray): Map<String, Any> {
        val input = Array(1) { Array(63) { FloatArray(1) } }
        for (i in 0 until 63) {
            input[0][i][0] = frame[i]
        }
        val output = Array(1) { FloatArray(ALPHABET_LABELS.size) }
        return try {
            interpreter!!.run(input, output)
            val probabilities = output[0]
            val maxIdx = probabilities.indices.maxByOrNull { probabilities[it] } ?: -1
            if (maxIdx != -1) {
                mapOf(
                    "label" to ALPHABET_LABELS[maxIdx],
                    "confidence" to probabilities[maxIdx],
                    "success" to true
                )
            } else {
                mapOf(
                    "label" to "Unknown",
                    "confidence" to 0f,
                    "success" to false
                )
            }
        } catch (_: Exception) {
            mapOf(
                "label" to "Error",
                "confidence" to 0f,
                "success" to false
            )
        }
    }
    fun close() {
    interpreter?.close()
    wordInterpreter?.close()
}

    // For word model (hand +  pose landmarks)
    private fun predictWordFrame(frame: FloatArray): Map<String, Any> {
        val input = Array(1) { Array(30) { FloatArray(162) } }

        for (i in 0 until 30) {
            for (j in 0 until 162) {
                input[0][i][j] = frame[i * 162 + j]
            }
        }

        val output = Array(1) { FloatArray(WORD_LABELS.size) }

        return try {
            wordInterpreter?.run(input, output)
            val probabilities = output[0]
            val maxIdx = probabilities.indices.maxByOrNull { probabilities[it] } ?: -1

            if (maxIdx != -1) {
                mapOf(
                    "label" to WORD_LABELS[maxIdx],
                    "confidence" to probabilities[maxIdx],
                    "success" to true
                )
            } else {
                mapOf(
                    "label" to "Unknown",
                    "confidence" to 0f,
                    "success" to false
                )
            }
        } catch (_: Exception) {
            mapOf(
                "label" to "Error",
                "confidence" to 0f,
                "success" to false
            )
        }
    }
    companion object {
        val WORD_LABELS = listOf(
            "thanks",
            "alhumdulillah",
            "come here",
            "salam",
            "what",
            "how are you",
            "i am fine"
        )
        val ALPHABET_LABELS = listOf(
            "Ayn", "alif", "baa", "daal", "Daad", "thal", "faa", "qaaf", "ghayn", "haaw",
            "Haa", "Jiim", "kaaf", "kha", "laam", "miim", "noon", "raa", "Saad", "siin",
            "shiin", "ta", "Taa", "tha", "thal", "waaw", "yaa", "zay"
        )
       
    }
}

