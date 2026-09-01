import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Firma de release — keystore dedicado (android/upload-keystore.jks, fuera de git) en vez
// del de debug. El de debug se regenera solo en cada máquina, así que un APK release firmado
// con él entra en conflicto de firma ("conflicto de paquete") al instalarse sobre una versión
// anterior firmada por otra máquina — ver auth/CLAUDE.md → "Actualización obligatoria".
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    // Sin esto, un build de release en una máquina sin el keystore real cae en
    // silencio a la firma debug (ver buildTypes.release más abajo) y termina
    // "bien" sin ningún aviso — el riesgo real es subir ESE apk a producción
    // pensando que quedó firmado igual que siempre. Este banner es la única
    // señal de que pasó, así que se imprime fuerte y feo a propósito.
    println("")
    println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    println("!!  ADVERTENCIA: no se encontro android/key.properties (keystore de release real).   !!")
    println("!!  Cualquier build de release en ESTA maquina va a quedar firmado con la llave       !!")
    println("!!  DEBUG (distinta en cada maquina) -- NO subir ese APK/AAB a produccion, va a        !!")
    println("!!  romper la actualizacion de los usuarios que ya tienen la app instalada             !!")
    println("!!  ('conflicto de paquete'). Compila el release en la maquina que SI tiene el         !!")
    println("!!  keystore real, o copia key.properties + el .jks a esta antes de subir nada.        !!")
    println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    println("")
}

android {
    namespace = "com.gs1peru.crm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gs1peru.crm"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk = flutter.minSdkVersion
        minSdk = flutter.minSdkVersion  // ✅ fijo, no flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Sin key.properties (máquina de desarrollo) cae a la firma debug para no romper el build.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
