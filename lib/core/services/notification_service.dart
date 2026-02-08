import 'package:firebase_messaging/firebase_messaging.dart';

/// FCM setup is centralized here to keep UI layers clean.
class NotificationService {
  NotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<void> initialize() async {
    await _messaging.requestPermission();
    await _messaging.getToken();
  }
}
