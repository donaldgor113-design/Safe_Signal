import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_signal/core/constants/firebase_constants.dart';
import 'package:safe_signal/core/errors/exceptions.dart';
import 'package:safe_signal/features/sos/data/models/alert_model.dart';

class AlertRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AlertRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _alertsRef =>
      _firestore.collection(FirebaseConstants.alertsCollection);

  Future<String> createAlert(AlertModel alert) async {
    try {
      final doc = await _alertsRef.add(alert.toMap());
      return doc.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Future<void> updateAlert(String alertId, Map<String, dynamic> data) async {
    try {
      await _alertsRef.doc(alertId).update(data);
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Stream<List<AlertModel>> watchAlerts() {
    return _alertsRef
        .where('userId', isEqualTo: _userId)
        .orderBy('triggeredAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AlertModel.fromFirestore(d)).toList());
  }

  Future<List<AlertModel>> getAlerts() async {
    try {
      final snap = await _alertsRef
          .where('userId', isEqualTo: _userId)
          .orderBy('triggeredAt', descending: true)
          .get();
      return snap.docs.map((d) => AlertModel.fromFirestore(d)).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Future<AlertModel?> getAlert(String alertId) async {
    try {
      final doc = await _alertsRef.doc(alertId).get();
      if (!doc.exists) return null;
      return AlertModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }
}
