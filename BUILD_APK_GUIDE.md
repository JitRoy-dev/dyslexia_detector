# Build APK Guide for Dyslexia Detector App

## Prerequisites

Before building the APK, ensure you have:

1. **Flutter SDK** installed and in PATH
2. **Android SDK** installed (via Android Studio or command line tools)
3. **Java JDK 11 or higher** installed

## Quick Build Commands

### Option 1: Build Release APK (Recommended)

```bash
cd d:\DYS_app\dyslexia_detector
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be located at:
```
d:\DYS_app\dyslexia_detector\build\app\outputs\flutter-apk\app-release.apk
```

### Option 2: Build Split APKs (Smaller file size)

```bash
flutter build apk --split-per-abi --release
```

This creates separate APKs for different CPU architectures:
- `app-armeabi-v7a-release.apk` (32-bit ARM - most common)
- `app-arm64-v8a-release.apk` (64-bit ARM - newer devices)
- `app-x86_64-release.apk` (64-bit x86 - rare)

### Option 3: Build Debug APK (For testing only)

```bash
flutter build apk --debug
```

## Step-by-Step Instructions

### 1. Verify Flutter Installation

```bash
flutter doctor
```

Ensure all checkmarks are green, especially:
- ✓ Flutter
- ✓ Android toolchain
- ✓ Android Studio (optional but recommended)

### 2. Clean Previous Builds

```bash
cd d:\DYS_app\dyslexia_detector
flutter clean
```

### 3. Get Dependencies

```bash
flutter pub get
```

### 4. Build the APK

```bash
flutter build apk --release
```

This process may take 5-10 minutes on first build.

### 5. Locate Your APK

After successful build, find your APK at:
```
d:\DYS_app\dyslexia_detector\build\app\outputs\flutter-apk\app-release.apk
```

## APK Size Optimization

### Current Build (~50-60 MB)

To reduce size, use split APKs:

```bash
flutter build apk --split-per-abi --release
```

Each APK will be ~20-25 MB.

### Further Optimization

Add to `android/app/build.gradle.kts`:

```kotlin
android {
    buildTypes {
        release {
            shrinkResources = true
            minifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

## Installing the APK

### On Physical Device

1. Copy APK to your phone
2. Enable "Install from Unknown Sources" in Settings
3. Tap the APK file to install

### Using ADB

```bash
adb install build\app\outputs\flutter-apk\app-release.apk
```

## Troubleshooting

### "Flutter not found"

Add Flutter to PATH:
```bash
# Add to System Environment Variables
C:\path\to\flutter\bin
```

### "Android SDK not found"

Set ANDROID_HOME environment variable:
```bash
ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
```

### "Gradle build failed"

```bash
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### "Out of memory" error

Add to `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m
```

## Build Variants

### Release APK (Production)
- Optimized and minified
- No debug information
- Smaller file size
- Ready for distribution

```bash
flutter build apk --release
```

### Debug APK (Testing)
- Includes debug symbols
- Larger file size
- Easier to debug

```bash
flutter build apk --debug
```

### Profile APK (Performance Testing)
- Optimized but with profiling enabled
- For performance analysis

```bash
flutter build apk --profile
```

## App Signing (For Play Store)

To publish on Google Play Store, you need to sign the APK:

### 1. Create a keystore

```bash
keytool -genkey -v -keystore d:\DYS_app\dyslexia-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dyslexia
```

### 2. Create `android/key.properties`

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=dyslexia
storeFile=d:/DYS_app/dyslexia-key.jks
```

### 3. Update `android/app/build.gradle.kts`

Add before `android` block:
```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Update `signingConfigs`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

### 4. Build signed APK

```bash
flutter build apk --release
```

## App Bundle (For Play Store)

Google Play Store prefers App Bundles over APKs:

```bash
flutter build appbundle --release
```

Output: `build\app\outputs\bundle\release\app-release.aab`

## Quick Reference

| Command | Output | Use Case |
|---------|--------|----------|
| `flutter build apk --release` | Single APK (~50MB) | General distribution |
| `flutter build apk --split-per-abi` | Multiple APKs (~20MB each) | Smaller downloads |
| `flutter build appbundle` | AAB file | Google Play Store |
| `flutter build apk --debug` | Debug APK | Testing only |

## Next Steps After Building

1. Test the APK on multiple devices
2. Verify all features work (camera, gallery, API connection)
3. Update API URL in `lib/services/api_service.dart` for production
4. Consider publishing to Google Play Store
5. Set up proper app signing for production

## Important Notes

- The debug signing is used by default (not secure for production)
- Update the `applicationId` in `build.gradle.kts` to your own package name
- Test on both physical devices and emulators
- Ensure backend API is accessible from the internet for production use
