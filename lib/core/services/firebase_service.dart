import 'package:firebase_core/firebase_core.dart';

/// Centralized Firebase bootstrap to keep main.dart lean and testable.
class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
}
