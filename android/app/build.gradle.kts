import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
>>>>>>> 4d8b6a881f3f4e5fc0e0da43e19a305e08eb6813
>>>>>>> origin/main
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProps = Properties().apply {
    val f = rootProject.file("android/key.properties")
    if (f.exists()) {
        FileInputStream(f).use { load(it) }
    }
}

android {
<<<<<<< HEAD
    namespace = "com.yourcompany.horseauction"
=======
<<<<<<< HEAD
    namespace = "com.example.horse_auction"
=======
    namespace = "com.example.horse_auction_app"
>>>>>>> 4d8b6a881f3f4e5fc0e0da43e19a305e08eb6813
>>>>>>> origin/main
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
<<<<<<< HEAD
        applicationId = "com.yourcompany.horseauction"
=======
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
<<<<<<< HEAD
        applicationId = "com.example.horse_auction"
=======
        applicationId = "com.example.horse_auction_app"
>>>>>>> 4d8b6a881f3f4e5fc0e0da43e19a305e08eb6813
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
>>>>>>> origin/main
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storePath = keystoreProps["storeFile"] as String?
            if (!storePath.isNullOrBlank()) {
                storeFile = file(storePath)
                storePassword = keystoreProps["storePassword"] as String?
                keyAlias = keystoreProps["keyAlias"] as String?
                keyPassword = keystoreProps["keyPassword"] as String?
            }
        }
    }

    buildTypes {
        getByName("release") {
            if (!((keystoreProps["storeFile"] as String?) ?: "").isBlank()) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            // debug keeps default debug signing
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}
