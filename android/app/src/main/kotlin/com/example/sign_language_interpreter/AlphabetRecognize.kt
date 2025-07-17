package com.example.sign_language_interpreter

import android.content.Context
import android.util.Log
import org.tensorflow.lite.Interpreter
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

class AlphabetRecognize (
context: Context
){
    private  var interpreter: Interpreter

    init {
        val model = loadModelFile(context, "Alphabetmodel.tflite")
        interpreter = Interpreter(model)

      
        // Verify shapes match expectations
        val inputShape = interpreter.getInputTensor(0).shape()
        Log.d("ModelInput", "Model expects shape: ${inputShape.contentToString()}")
        require(inputShape.contentEquals(intArrayOf(1, 63, 1))) {
            "Model expects shape [1, 63, 1] but got ${inputShape.contentToString()}"
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
    private var frameCounter = 0

    fun addFrame(frame: FloatArray): Map<String, Any>? {
        frameCounter++

        // Only process every 5th frame
        if (frameCounter % 5 == 0) {
           val result=predictSingleFrame(frame)
            return if (result["confidence"] as Float > 0.5f) result else null
        }
        return null
    }

    private fun predictSingleFrame(frame: FloatArray): Map<String, Any> {
        // Reshape to [1, 63, 1] as model expects
        val input = Array(1) { Array(63) { FloatArray(1) } }
        for (i in 0 until 63) {
            input[0][i][0] = frame[i]
        }

        val output = Array(1) { FloatArray(ALPHABET_LABELS.size) }

        return try {
            interpreter.run(input, output)
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
                "success" to false,

            )
        }
    }

    companion object{
        val ALPHABET_LABELS= listOf(
            "Ayn"
        , "alif"
        , "baa"
        , "daal"
        , "Daad"
        , "thal"
        , "faa"
       , "qaaf"
       , "ghayn"
        , "haaw"
        , "Haa"
        , "Jiim"
        , "kaaf"
       , "kha"
        , "laam"
       , "miim"
        , "noon"
        , "raa"
        , "Saad"
        , "siin"
        , "shiin"
        , "ta"
       , "Taa"
        , "tha"
        , "thal"
       , "waaw"
        , "yaa" ,
        "zay"
            )
    }

}

