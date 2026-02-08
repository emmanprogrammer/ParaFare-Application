# ParaFare Application

Production-ready Flutter scaffold for a tricycle dispatch and fare platform with Passenger and Driver modes.

## Getting Started

### 1) Prerequisites

- Flutter (latest stable)
- Dart (bundled with Flutter)
- A device or emulator
- Firebase project (Firestore + FCM)

### 2) Install dependencies

Run from the project root (the folder containing `pubspec.yaml`):

```bash
flutter pub get
```

### 3) Configure Firebase

The app initializes Firebase on startup. You must configure Firebase before running it.

**Recommended (FlutterFire CLI):**

```bash
# Install FlutterFire CLI (one time)
dart pub global activate flutterfire_cli

# Install Firebase CLI (one time)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Generate firebase_options.dart and platform configs
flutterfire configure
```

**Manual setup (no FlutterFire CLI):**

1. Create a Firebase project.
2. Add your Android/iOS apps in Firebase console.
3. Download the config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Follow the official guide: https://firebase.google.com/docs/flutter/setup

### 4) Run the app

```bash
flutter run
```

## Common Issues

### `FlutterAppRequiredException` when running `flutterfire configure`

Make sure you are in the project root (where `pubspec.yaml` lives) before running the command.

```bash
cd /path/to/ParaFare-Application
flutterfire configure
```

### `firebase` or `npm` not recognized on Windows

Install Node.js (LTS) from https://nodejs.org, then reopen PowerShell and run:

```bash
npm install -g firebase-tools
firebase login
```

### PowerShell script execution policy blocks `npm`

Run PowerShell as Administrator and execute:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Then rerun:

```powershell
npm install -g firebase-tools
```

## Project Structure

```
lib/
  core/
  data/
  features/
  main.dart
```

## Notes

- This is a scaffold intended for extension. Business logic lives in controllers/repositories, not widgets.
- Firebase initialization is centralized in `lib/core/services/firebase_service.dart`.
