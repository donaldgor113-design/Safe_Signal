import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_signal/core/constants/firebase_constants.dart';
import 'package:safe_signal/core/errors/exceptions.dart';
import 'package:safe_signal/core/services/notification_service.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;

      await user.updateDisplayName(displayName);
      await user.sendEmailVerification();

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'fcmToken': null,
      });

      return user;
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirebaseAuthException(
        _mapFirebaseAuthError(e.code),
        technicalDetails: e.toString(),
      );
    } catch (e) {
      throw FirebaseAuthException(
        'Помилка реєстрації. Спробуйте ще раз',
        technicalDetails: e.toString(),
      );
    }
  }

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseException catch (e) {
      throw FirebaseAuthException(
        _mapFirebaseAuthError(e.code),
        technicalDetails: e.toString(),
      );
    } catch (e) {
      throw FirebaseAuthException(
        'Помилка входу. Спробуйте ще раз',
        technicalDetails: e.toString(),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      throw FirebaseAuthException(
        _mapFirebaseAuthError(e.code),
        technicalDetails: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    await NotificationService().clearToken();
    await _auth.signOut();
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Ця пошта вже використовується';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неправильний пароль';
      case 'user-not-found':
        return 'Акаунт з такою поштою не знайдено';
      case 'too-many-requests':
        return 'Забагато спроб. Спробуйте через кілька хвилин';
      case 'network-request-failed':
        return 'Немає підключення до мережі';
      case 'invalid-email':
        return 'Некоректна адреса електронної пошти';
      default:
        return 'Помилка входу. Спробуйте ще раз';
    }
  }
}
