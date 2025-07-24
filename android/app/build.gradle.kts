plugins {
    id("com.android.application")
    id("kotlin-android")

    id ("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.medico.pixidrugs"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.medico.pixidrugs"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            storeFile = file("PixiDrugs.jks")
            storePassword = "Skinskin@123"
            keyAlias = "PixiDrugs"
            keyPassword = "Skinskin@123"
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    //flutter build apk --split-per-abi --release
    //flutter build appbundle --release
    //flutter build apk --target-platform android-arm64 --analyze-size  --release
    //flutter build apk  --release
}

dependencies {
    implementation("com.google.firebase:firebase-installations:17.1.2")
    implementation(platform("com.google.firebase:firebase-bom:33.11.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-messaging")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core:1.7.0")
    implementation("com.google.firebase:firebase-appcheck-playintegrity:17.1.1")
}

flutter {
    source = "../.."
}
