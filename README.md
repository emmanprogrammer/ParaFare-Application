# ParaFare Application

Production-ready Flutter scaffold for a tricycle dispatch and fare platform with Passenger and Driver modes.

## What is implemented now

- Feature-first Flutter architecture with Riverpod + GoRouter.
- Firebase/Firestore dispatch scaffolding for rider and driver flows.
- Node-based trip simulator for testing the fare and shortest-path logic without GPS.
- Map tile source toggle (`online` vs `offline/local`) to prepare for offline map packs.

## Trip Simulation (manual testing mode)

Open **Trip Simulation (Node-Based)** from the mode selector.

This mode lets you test the core function set you requested first:

1. Select origin and destination nodes (manual user input).
2. Compute shortest path using Dijkstra on a tricycle-accessible graph.
3. Calculate fare using the hardware-aligned rules:
   - Base: PHP 15 for 0–4 km
   - Additional: `+ ceil(distance - 4)` beyond 4 km
   - Optional 20% discount, bounded by min fare PHP 10
   - Manual adjustment with final fare clamped to PHP 10–100

## Online + Offline map strategy

The map layer currently supports two modes:

- **Online**: OpenStreetMap tiles (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`)
- **Offline/local**: placeholder local tile URL (`http://127.0.0.1:8080/{z}/{x}/{y}.png`)

For production offline maps, replace the local tile source with your chosen offline tile host or MBTiles-backed provider.

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

### 4) Run

```bash
flutter run
```

## Common Setup Issues


### App stuck on splash/logo

If the app never moves past the launch image, Firebase initialization usually failed before first screen render.

Fix sequence:

```bash
flutter create .
flutterfire configure
flutter clean
flutter pub get
flutter run
```

When `flutterfire configure` asks for Android package name, do not leave it blank (example: `com.emman.parafare`).

### `FlutterAppRequiredException: The current directory does not appear to be a Flutter application project`

You are not in the Flutter project root. Ensure `pubspec.yaml` exists in your current folder.

### `firebase : The term 'firebase' is not recognized`

Install Firebase CLI:

```bash
npm install -g firebase-tools
```

### `npm : ... npm.ps1 cannot be loaded because running scripts is disabled`

On Windows PowerShell, run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Then retry Firebase CLI install.

### `flutterfire : command not recognized`

Add this to your Windows PATH and restart terminal:

```text
C:\Users\<your-user>\AppData\Local\Pub\Cache\bin
```
