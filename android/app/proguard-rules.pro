# Google Play Services
-keep class com.google.android.gms.** { *; }

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
