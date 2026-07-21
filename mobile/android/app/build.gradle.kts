plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.wipel5"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // AGP 8+ menonaktifkan resValue per-flavor secara default — tanpa ini
    // build gagal keras di configuration phase ("Product Flavor ... contains
    // custom resource values, but the feature is disabled"), sebelum sempat
    // menyentuh kode Dart sama sekali. Dibutuhkan oleh resValue("app_name", …)
    // di productFlavors di bawah (nama aplikasi berbeda per flavor).
    buildFeatures {
        resValues = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.wipel5"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Dua aplikasi terpisah dari satu codebase. Pasangkan flavor dengan
    // entrypoint-nya saat build/run:
    //   flutter run  --flavor publik  -t lib/main_publik.dart
    //   flutter run  --flavor petugas -t lib/main_petugas.dart
    //   flutter build apk --flavor petugas -t lib/main_petugas.dart
    flavorDimensions += "app"
    productFlavors {
        create("publik") {
            dimension = "app"
            applicationId = "id.tirtawening.publik"
            resValue("string", "app_name", "Tirtawening")
        }
        create("petugas") {
            dimension = "app"
            applicationId = "id.tirtawening.petugas"
            resValue("string", "app_name", "Tirtawening Petugas")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // Tanpa ini, R8 menggagalkan SETIAP build release (kedua flavor)
            // karena referensi ML Kit yang memang tidak terpasang — lihat
            // alasan lengkapnya di proguard-rules.pro.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
