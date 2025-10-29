import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Function to read local properties
fun readProperties(projectRootDir: File, fileName: String = "local.properties"): Properties {
    val properties = Properties()
    val propertiesFile = File(projectRootDir, fileName)
    if (propertiesFile.isFile) {
        FileInputStream(propertiesFile).use { fis -> properties.load(fis) }
    }
    return properties
}

// Read properties ONLY for version codes/names
val localProperties = readProperties(rootProject.rootDir)
val flutterVersionCode: String = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName: String = localProperties.getProperty("flutter.versionName") ?: "1.0"

// Flutter plugin section
flutter {
    source = "../.."
}

android {
    namespace = "com.example.aura_health_companion"
    // +++ FIX 1: Update compileSdk +++
    compileSdk = 36 // Use the highest required version

    ndkVersion = flutter.ndkVersion // Keep reading from Flutter plugin

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")

    defaultConfig {
        applicationId = "com.example.aura_health_companion"
        minSdk = flutter.minSdkVersion // Keep minimum SDK (or use flutter.minSdkVersion if it works)
        // Target SDK usually matches compile SDK, or use flutter.targetSdkVersion
        targetSdk = 34 // Often kept lower than compileSdk, 34 is common. Let's try this.
        // targetSdk = 36 // Alternatively, match compileSdk
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Dependencies block inside android {}
    dependencies {
        // +++ FIX 2: Update Desugar Library Version +++
        add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:2.1.4") // Use the required version
    }
}

// Top-level dependencies block
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:${project.properties["kotlinVersion"]}")
    // Add other app dependencies here
}

