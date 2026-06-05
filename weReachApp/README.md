# Wereach Flutter Application

Wereach is a premium, startup-quality location-alert mobile application designed to help users avoid missing their stops during bus, train, metro, or car rides. Featuring a sleek Apple and Linear-inspired dark mode UI with glassmorphism styling, clean animations, and a real-time Mapbox HUD.

---

## Architecture Overview

- **State Management**: Riverpod (`flutter_riverpod`)
- **Database**: Isar DB for local persistence (recents, favorites, preferences)
- **Networking**: Dio
- **Routing**: GoRouter with custom sliding page transitions
- **Structure**: Feature-based Clean Architecture

---

## Getting Started

Since this project contains the Flutter source files and package declarations but no native wrapper templates, you must first generate the platform directories and build the database adapter files.

### 1. Initialize Native Project Files
Run the following command inside `weReachApp/` to generate platform-specific folders (`android/`, `ios/`, `web/`, etc.):
```bash
flutter create .
```

### 2. Fetch Dependencies
Install the required packages declared in `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Generate Database Adapters
This project utilizes Isar Database, which requires compiling helper classes for type safety. Run the code generator:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Mapbox Setup & Configuration

This project integrates `mapbox_maps_flutter` for beautiful vector map rendering. To configure maps:

### 1. Configure Mapbox Access Tokens
1. Obtain an access token from [Mapbox Dashboard](https://account.mapbox.com/).
2. Create a configuration file in `lib/core/config/mapbox_config.dart` or supply it directly.
3. Configure credentials:
   - **Android**: Add your public access token to `android/app/src/main/AndroidManifest.xml` under `<meta-data android:name="com.mapbox.token" android:value="YOUR_PUBLIC_TOKEN"/>`.
   - **iOS**: Add your token as `MBXAccessToken` key in `ios/Runner/Info.plist`.

Refer to the official [Mapbox Flutter Installation Guide](https://docs.mapbox.com/flutter/maps/guides/install/) to configure the secret downloads token in your global Gradle configuration (`~/.gradle/gradle.properties` / `netrc` file on macOS).

---

## Custom Assets

We have configured a default alarm sound asset in `pubspec.yaml` at:
- `assets/alarm.mp3`

Please add your custom wake-up audio file (in MP3 format) inside the `assets/` directory at the root of the project to ensure the alarm plays correctly.
