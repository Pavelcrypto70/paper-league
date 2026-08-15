plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadKeyProperties(file: java.io.File): Map<String, String> {
    if (!file.exists()) return emptyMap()
    val map = mutableMapOf<String, String>()
    file.readLines().forEach { line ->
        val trimmed = line.trim()
        if (trimmed.isEmpty() || trimmed.startsWith("#")) return@forEach
        val idx = trimmed.indexOf('=')
        if (idx <= 0) return@forEach
        map[trimmed.substring(0, idx).trim()] = trimmed.substring(idx + 1).trim()
    }
    return map
}

val keystoreProperties = loadKeyProperties(rootProject.file("key.properties"))
val hasReleaseKeystore = keystoreProperties.isNotEmpty() &&
    keystoreProperties["storeFile"] != null &&
    rootProject.file(keystoreProperties["storeFile"]!!).exists()

android {
    namespace = "com.paperleague.paper_league"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.paperleague.paper_league"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"]
                keyPassword = keystoreProperties["keyPassword"]
                storeFile = rootProject.file(keystoreProperties["storeFile"]!!)
                storePassword = keystoreProperties["storePassword"]
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                println("WARNING: android/key.properties missing — release signed with debug. Do not upload to Play.")
                signingConfig = signingConfigs.getByName("debug")
            }
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
