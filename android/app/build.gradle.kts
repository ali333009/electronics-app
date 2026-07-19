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

// Load local keystore properties (for local development only)
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
            // --- Codemagic: keystore uploaded via "Android code signing" UI ---
            val cmKeystorePath = System.getenv("CM_KEYSTORE_PATH")
            // --- Codemagic: keystore passed as base64 env variable ---
            val cmKeystoreBase64 = System.getenv("CM_KEYSTORE")

            when {
                cmKeystorePath != null && cmKeystorePath.isNotEmpty() -> {
                    // Codemagic "Android code signing" UI — file written automatically
                    storeFile = file(cmKeystorePath)
                    storePassword = System.getenv("CM_KEYSTORE_PASSWORD") ?: ""
                    keyAlias = System.getenv("CM_KEY_ALIAS_USERNAME") ?: System.getenv("CM_KEY_ALIAS") ?: ""
                    keyPassword = System.getenv("CM_KEY_ALIAS_PASSWORD") ?: System.getenv("CM_KEY_PASSWORD") ?: ""
                }
                cmKeystoreBase64 != null && cmKeystoreBase64.isNotEmpty() -> {
                    // Codemagic custom env variables — decode base64 keystore
                    val keystoreFile = rootProject.file("release.jks")
                    keystoreFile.writeBytes(Base64.getDecoder().decode(cmKeystoreBase64))
                    storeFile = keystoreFile
                    storePassword = System.getenv("CM_KEYSTORE_PASSWORD") ?: ""
                    keyAlias = System.getenv("CM_KEY_ALIAS_USERNAME") ?: System.getenv("CM_KEY_ALIAS") ?: ""
                    keyPassword = System.getenv("CM_KEY_ALIAS_PASSWORD") ?: System.getenv("CM_KEY_PASSWORD") ?: ""
                }
                else -> {
                    // Local development — read from local.properties
                    keyAlias = localKeystoreProperties.getProperty("keyAlias") ?: ""
                    keyPassword = localKeystoreProperties.getProperty("keyPassword") ?: ""
                    storeFile = localKeystoreProperties.getProperty("storeFile")?.let { file(it) }
                    storePassword = localKeystoreProperties.getProperty("storePassword") ?: ""
                }
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
            val hasReleaseKeystore = System.getenv("CM_KEYSTORE_PATH") != null || System.getenv("CM_KEYSTORE") != null || localKeystoreProperties.getProperty("storeFile") != null
            signingConfig = signingConfigs.getByName(if (hasReleaseKeystore) "release" else "debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
