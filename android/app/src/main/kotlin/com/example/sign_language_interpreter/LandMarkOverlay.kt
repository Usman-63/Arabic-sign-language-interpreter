    // LandmarkOverlayView.kt
package com.example.sign_language_interpreter

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.View

class LandmarkOverlayView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = 0
) : View(context, attrs, defStyle) {

    // A list to store landmark coordinates in screen pixels
    var landmarks: List<Pair<Float, Float>> = emptyList()

    private val paint = Paint().apply {
        color = Color.RED
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        // Draw each landmark as a circle on the canvas
        landmarks.forEach { (x, y) ->
            canvas.drawCircle(x, y, 8f, paint)
        }
    }
}
