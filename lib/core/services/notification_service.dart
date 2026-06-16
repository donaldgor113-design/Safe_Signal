import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_signal/core/constants/firebase_constants.dart';

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FlutterSecureStorage _secureStorage;

  static const String _fcmTokenKey = 'fcm_token';

  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FlutterSecureStorage? secureStorage,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _updateToken();
      _messaging.onTokenRefresh.listen(_onTokenRefresh);
    }
  }

  Future<void> _updateToken() async {
    final token = await _messaging.getToken();
    if (token == null) return;

    final storedToken = await _secureStorage.read(key: _fcmTokenKey);
    if (storedToken == token) return;

    await _secureStorage.write(key: _fcmTokenKey, value: token);
    await _syncTokenToFirestore(token);
  }

  Future<void> _onTokenRefresh(String token) async {
    await _secureStorage.write(key: _fcmTokenKey, value: token);
    await _syncTokenToFirestore(token);
  }

  Future<void> _syncTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .update({'fcmToken': token});
  }

  Future<String?> getStoredToken() async {
    return _secureStorage.read(key: _fcmTokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _fcmTokenKey);
    await _messaging.deleteToken();
  }
}
