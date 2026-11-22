import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// F1: Release signing is read from android/key.properties (git-ignored, never committed):
//   storeFile=<path to upload keystore .jks, relative to android/app or absolute>
//   storePassword=...
//   keyAlias=...
//   keyPassword=...
// Debug builds never need it. Release builds fail with a clear message if it is missing.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val requiredSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}
val missingSigningKeys = requiredSigningKeys.filter { keystoreProperties.getProperty(it).isNullOrBlank() }
val hasReleaseSigning = keystorePropertiesFile.exists() && missingSigningKeys.isEmpty()

android {
    namespace = "com.sleepyhead.packbuddy"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.sleepyhead.packbuddy"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        multiDexEnabled = true
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Never sign release with debug keys. Without key.properties the release
            // build is stopped below with an explicit error (no fake keystore is generated).
            signingConfig = if (hasReleaseSigning) signingConfigs.getByName("release") else null
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// Fail release packaging (assembleRelease / bundleRelease) loudly when signing is not configured;
// debug and profile builds are unaffected.
gradle.taskGraph.whenReady {
    val releaseTasks = allTasks.filter {
        it.project == project &&
            (it.name.startsWith("assemble") || it.name.startsWith("bundle") || it.name.startsWith("package")) &&
            it.name.endsWith("Release")
    }
    if (releaseTasks.isNotEmpty() && !hasReleaseSigning) {
        val reason = if (!keystorePropertiesFile.exists()) {
            "android/key.properties was not found"
        } else {
            "android/key.properties is missing: ${missingSigningKeys.joinToString()}"
        }
        throw GradleException(
            "Release signing is not configured ($reason). Create android/key.properties with " +
                "storeFile, storePassword, keyAlias and keyPassword pointing to your Play upload keystore. " +
                "Debug builds do not need it."
        )
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
