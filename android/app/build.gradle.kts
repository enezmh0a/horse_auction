plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // ✅ must be here
    id("dev.flutter.flutter-gradle-plugin")
}


android {
    namespace = "com.enezmh0a.horse_auction"   // ✅ match your Firebase android package name
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
        applicationId = "com.enezmh0a.horse_auction"   // ✅ must match namespace
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }
}

dependencies {
    classpath("com.google.gms:google-services:4.4.2")
}

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }


flutter {
    source = "../.."
}
