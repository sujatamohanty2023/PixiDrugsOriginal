# Google Play Services
-keep class com.google.android.gms.** { *; }

# Keep all ML Kit text recognition classes
-keep class com.google.mlkit.vision.text.** { *; }

# Ignore missing ML Kit optional languages
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# AndroidX Lifecycle
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Kotlin
-dontwarn kotlin.**
-dontwarn kotlinx.**
