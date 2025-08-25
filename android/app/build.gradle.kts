plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.compudecsi"

    // Em Kotlin DSL use propriedade, e converta para Int se vier como String
    compileSdk = flutter.compileSdkVersion.toInt()

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.compudecsi"

        // Kotlin DSL: use minSdk/targetSdk como propriedades
        minSdk = 23
        targetSdk = flutter.targetSdkVersion.toInt()

        // versionCode precisa ser Int; versionName é String
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Ajuste sua assinatura depois; debug temporário para facilitar build release local
            signingConfig = signingConfigs.getByName("debug")
            // Ex.: habilitar minify se quiser
            // isMinifyEnabled = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
        debug {
            // configs opcionais para debug
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.android.gms:play-services-auth:21.2.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
