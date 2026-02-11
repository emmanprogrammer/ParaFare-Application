import 'package:firebase_core/firebase_core.dart';

/// Centralized Firebase bootstrap to keep main.dart lean and testable.
class FirebaseService {
  static Future<FirebaseInitResult> initializeSafely() async {
    try {
      await Firebase.initializeApp();
      return const FirebaseInitResult(isReady: true);
    } on Exception catch (error) {
      // We intentionally keep the app bootable even when Firebase setup is incomplete,
      // so local UI/pathfinding/fare simulation can still be tested.
      return FirebaseInitResult(
        isReady: false,
        errorMessage: 'Firebase unavailable: $error',
      );
    }
  }
}

class FirebaseInitResult {
  const FirebaseInitResult({
    required this.isReady,
    this.errorMessage,
  });

  final bool isReady;
  final String? errorMessage;
}
