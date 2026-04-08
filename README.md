# ParaFare Application

Driver-first online MVP for ParaFare mobile testing on real phones.

## Current MVP Flow (phone-testable)

## Routing Design Clarification

- Road graph nodes/edges are internal only; normal users do **not** interact with graph nodes directly.
- Users interact with map taps/GPS coordinates; the app snaps them internally to nearest graph nodes.
- Total route distance includes:
  - graph shortest-path distance between snapped nodes
  - + start coordinate to snapped start-node offset
  - + destination coordinate to snapped destination-node offset
- Optional debug overlay can show snapped points for developers only.


1. First launch onboarding (once only): welcome → role → driver registration → seat config.
2. Driver dashboard: top online map + passenger slot cards.
3. Empty slot: tap to add ride (origin/destination + route preview + estimated distance/time + fare).
4. Occupied slot: tap to manage and finish ride.
5. Final fare step: manual adjustment then confirm.
6. Earnings/history: daily summary + completed rides stored locally.

Fare rule used everywhere in MVP:
- PHP 15 for first 4 km
- + ceil(distanceKm - 4) beyond 4 km
- clamped to PHP 10–100 after adjustment

## What is implemented now

- Feature-first Flutter architecture with Riverpod + GoRouter.
- Firebase/Firestore dispatch scaffolding for rider and driver flows.
- Node-based trip simulator for testing fare/routing logic without GPS.
- Live Trip Mode that captures start/end from GPS, snaps to nearest nodes, computes shortest path, then fare.
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


## Legacy / Extended Flows

This mode mirrors the hardware trip logic sequence:

1. Capture trip start from live GPS.
2. Capture trip end from live GPS.
3. Snap both coordinates to nearest graph nodes (haversine).
4. Compute shortest path distance on local graph.
5. If start/end snap to same node, fallback to direct haversine distance.
6. Compute fare using the same hardware-aligned formula.
7. Save completed trip to local on-device history.

Open it from mode selection via **Live Trip Mode (GPS)**.

## Online + Offline map strategy

The map layer currently supports two modes:

- **Online**: OpenStreetMap tiles (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`)
- **Offline/local**: placeholder local tile URL (`http://127.0.0.1:8080/{z}/{x}/{y}.png`)

For production offline maps, replace the local tile source with your chosen offline tile host or MBTiles-backed provider.


## OSM → Gensan intersection nodes workflow

Yes, you can build the node graph from OpenStreetMap data.

A generator script is included:

```bash
python scripts/generate_gensan_network.py --from-overpass --anchor-spacing-meters 40
```

If Overpass access is blocked on your network, fetch/save the Overpass JSON externally and run:

```bash
python scripts/generate_gensan_network.py --from-file <path-to-overpass-json> --anchor-spacing-meters 30
```

This rewrites:

- `lib/features/dispatch/simulation/generated/gensan_network_data.dart`

The app then uses those generated intersection nodes and weighted edges for shortest-path simulation/fare calculation.

### Binary graph converter path

If your graph source is local binary node/edge files, convert it with:

```bash
python scripts/convert_binary_graph_to_json.py --nodes-bin <nodes.bin> --edges-bin <edges.bin> --out assets/graph/gensan_graph.json
```

Expected binary format (little-endian):

- `nodes.bin` record (24 bytes): `uint64 node_id`, `double latitude`, `double longitude`
- `edges.bin` record (20 bytes): `uint64 from_node_id`, `uint64 to_node_id`, `float distance_meters`

The app graph loader tries `assets/graph/gensan_graph.json` first, then falls back to generated Dart graph data.


`--anchor-spacing-meters` controls node granularity (smaller value = denser/smaller nodes like your firmware graph approach).

Fare logic is preserved and unchanged from your hardware rule set (`<=4km => PHP15`, then `+ceil(distance-4)`, with discount/adjustment bounds).

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

### 2.1) Quick sanity checks

Before running on-device, you can verify setup with:

```bash
flutter analyze
flutter test
```

If tests are still being added in your branch, `flutter analyze` is the minimum recommended check.

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
