# ─────────────────────────────────────────────────────────────
# FLUTTER & DART
# ─────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# ─────────────────────────────────────────────────────────────
# CAMERAX & ANDROIDX
# ─────────────────────────────────────────────────────────────
-keep class androidx.camera.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class androidx.concurrent.futures.** { *; }

# ─────────────────────────────────────────────────────────────
# MEDIAPIPE TASKS & PROTO
# ─────────────────────────────────────────────────────────────
-keep class com.google.mediapipe.** { *; }
-keep class com.google.mediapipe.tasks.** { *; }
-keep class com.google.mediapipe.framework.** { *; }
-keep class com.google.mediapipe.proto.** { *; }

# ─────────────────────────────────────────────────────────────
# TENSORFLOW LITE
# ─────────────────────────────────────────────────────────────
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.** { *; }

# ─────────────────────────────────────────────────────────────
# JNI / REFLECTION / ANNOTATION
# ─────────────────────────────────────────────────────────────
-keepclassmembers class * {
    native <methods>;
}
-keepclassmembers class * {
    @androidx.annotation.Keep <fields>;
    @androidx.annotation.Keep <methods>;
}

# ─────────────────────────────────────────────────────────────
# GSON (OPTIONAL)
# ─────────────────────────────────────────────────────────────
-keep class com.google.gson.** { *; }

# ─────────────────────────────────────────────────────────────
# SAFE TO SUPPRESS WARNINGS (DO NOT REMOVE NEEDED CLASSES)
# ─────────────────────────────────────────────────────────────
-dontwarn com.google.protobuf.**
-dontwarn com.google.mediapipe.**
-dontwarn com.google.android.play.core.**
-dontwarn javax.annotation.**
-dontwarn javax.lang.model.**
-keep class android.os.Build$VERSION { *; }
