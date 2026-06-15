import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_signal/core/constants/firebase_constants.dart';
import 'package:safe_signal/core/errors/exceptions.dart';
import 'package:safe_signal/features/medical_profile/data/models/medical_profile_model.dart';

class MedicalProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MedicalProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  DocumentReference get _docRef => _firestore
      .collection(FirebaseConstants.medicalProfilesCollection)
      .doc(_userId);

  Future<MedicalProfileModel> getMedicalProfile() async {
    try {
      final doc = await _docRef.get();
      if (!doc.exists) {
        return MedicalProfileModel.empty();
      }
      return MedicalProfileModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    } catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    }
  }

  Stream<MedicalProfileModel> watchMedicalProfile() {
    return _docRef.snapshots().map((doc) {
      if (!doc.exists) {
        return MedicalProfileModel.empty();
      }
      return MedicalProfileModel.fromFirestore(doc);
    });
  }

  Future<void> saveMedicalProfile(MedicalProfileModel profile) async {
    try {
      await _docRef.set(profile.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    } catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    }
  }
}
