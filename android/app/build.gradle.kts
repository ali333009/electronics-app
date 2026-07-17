import java.util.Properties
import java.util.Base64
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load local keystore properties (for local development)
val localKeystoreProperties = Properties()
val localKeystorePropertiesFile = rootProject.file("local.properties")
if (localKeystorePropertiesFile.exists()) {
    localKeystoreProperties.load(FileInputStream(localKeystorePropertiesFile))
}

android {
    namespace = "com.elct.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    signingConfigs {
        create("release") {
            val keystoreBase64 = System.getenv("CM_KEYSTORE")
            if (keystoreBase64 != null && keystoreBase64.isNotEmpty()) {
                // Codemagic CI environment — decode keystore from base64
                val keystoreFile = rootProject.file("release.jks")
                keystoreFile.writeBytes(Base64.getDecoder().decode(keystoreBase64))
                storeFile = keystoreFile
                storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("CM_KEY_ALIAS")
                keyPassword = System.getenv("CM_KEY_PASSWORD")
            } else {
                // Local development environment — read from local.properties
                keyAlias = localKeystoreProperties.getProperty("keyAlias") ?: ""
                keyPassword = localKeystoreProperties.getProperty("keyPassword") ?: ""
                storeFile = localKeystoreProperties.getProperty("storeFile")?.let { file(it) }
                storePassword = localKeystoreProperties.getProperty("storePassword") ?: ""
            }
        }
    }

    defaultConfig {
        applicationId = "com.elct.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
