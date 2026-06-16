import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_signal/core/constants/firebase_constants.dart';
import 'package:safe_signal/core/errors/exceptions.dart';
import 'package:safe_signal/features/scenarios/data/models/scenario_model.dart';
import 'package:safe_signal/features/scenarios/domain/entities/scenario_entity.dart';

class ScenariosRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ScenariosRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _scenariosRef =>
      _firestore.collection(FirebaseConstants.scenariosCollection);

  Future<String> createScenario(ScenarioModel scenario) async {
    try {
      final docRef = await _scenariosRef
          .doc(_userId)
          .collection(FirebaseConstants.scenarioItemsSubcollection)
          .add(scenario.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Future<void> updateScenario(ScenarioModel scenario) async {
    try {
      await _scenariosRef
          .doc(_userId)
          .collection(FirebaseConstants.scenarioItemsSubcollection)
          .doc(scenario.id)
          .update(scenario.toUpdateMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Future<void> deleteScenario(String scenarioId) async {
    try {
      await _scenariosRef
          .doc(_userId)
          .collection(FirebaseConstants.scenarioItemsSubcollection)
          .doc(scenarioId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Stream<List<ScenarioModel>> watchScenarios() {
    return _scenariosRef
        .doc(_userId)
        .collection(FirebaseConstants.scenarioItemsSubcollection)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ScenarioModel.fromFirestore(d)).toList());
  }

  Future<List<ScenarioModel>> getScenarios() async {
    try {
      final snap = await _scenariosRef
          .doc(_userId)
          .collection(FirebaseConstants.scenarioItemsSubcollection)
          .get();
      return snap.docs.map((d) => ScenarioModel.fromFirestore(d)).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Future<ScenarioModel?> getScenario(String scenarioId) async {
    try {
      final doc = await _scenariosRef
          .doc(_userId)
          .collection(FirebaseConstants.scenarioItemsSubcollection)
          .doc(scenarioId)
          .get();
      if (!doc.exists) return null;
      return ScenarioModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Future<ScenarioModel?> getDefaultScenario() async {
    try {
      final snap = await _scenariosRef
          .doc(_userId)
          .collection(FirebaseConstants.scenarioItemsSubcollection)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return ScenarioModel.fromFirestore(snap.docs.first);
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Future<void> setDefaultScenario(String scenarioId) async {
    try {
      final batch = _firestore.batch();
      final collection = _scenariosRef
          .doc(_userId)
          .collection(FirebaseConstants.scenarioItemsSubcollection);

      final allScenarios = await collection.get();
      for (final doc in allScenarios.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      batch.update(collection.doc(scenarioId), {'isDefault': true});
      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.message);
    }
  }

  Future<void> createDefaultScenario() async {
    try {
      final existing = await getDefaultScenario();
      if (existing != null) return;

      final defaultScenario = ScenarioModel(
        id: '',
        userId: _userId,
        name: 'Основний',
        contactIds: const [],
        messageTemplate: ScenarioEntity.defaultTemplate,
        recordDurationSeconds: 30,
        autoTriggerEnabled: false,
        immobilityTimeoutSeconds: 60,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await createScenario(defaultScenario);
    } on FirestoreException {
      rethrow;
    }
  }
}
