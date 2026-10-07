plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.espadna.adadi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.espadna.adadi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName

    }

    // Release key (upload key for Google Play, signing key for Cafe Bazaar).
    // CI writes it from the repository secrets (see docs/PUBLISH-FA.md); without
    // it, release builds are signed with the debug key and only good for testing.
    val releaseKeystore = System.getenv("ADADI_KEYSTORE")?.let { file(it) }?.takeIf { it.exists() }
    signingConfigs {
        if (releaseKeystore != null) {
            create("release") {
                storeFile = releaseKeystore
                storePassword = System.getenv("ADADI_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ADADI_KEY_ALIAS")
                keyPassword = System.getenv("ADADI_KEY_PASSWORD")
            }
        }
    }

    // `-P adadi.abis=armeabi-v7a,arm64-v8a` (the Cafe Bazaar build): package only these
    // CPUs' native libraries. Plugins otherwise still ship tiny x86_64 libraries without
    // Flutter's engine, and an x86_64 device would pick that folder and crash at launch.
    // (ndk.abiFilters is overridden by Flutter's Gradle plugin, so exclude at packaging.)
    (project.findProperty("adadi.abis") as String?)?.split(",")?.let { keep ->
        val all = listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
        packaging {
            jniLibs { excludes += (all - keep.toSet()).map { "lib/$it/**" } }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (releaseKeystore != null) "release" else "debug")
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
