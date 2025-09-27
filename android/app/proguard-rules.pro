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

# Flutter TextInput and EditableText
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.plugin.editing.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter TextField and TextEditingController
-keep class ** extends io.flutter.plugin.common.MethodChannel { *; }
-keep class ** extends io.flutter.plugin.common.EventChannel { *; }

# Prevent obfuscation of text input methods
-keepclassmembers class * {
    @io.flutter.plugin.common.MethodChannel.Result *;
    @io.flutter.plugin.common.EventChannel.StreamHandler *;
}
