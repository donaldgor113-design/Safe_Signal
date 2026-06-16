import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_signal/features/scenarios/domain/entities/scenario_entity.dart';

class ScenarioModel {
  final String id;
  final String userId;
  final String name;
  final List<String> contactIds;
  final String messageTemplate;
  final int recordDurationSeconds;
  final bool autoTriggerEnabled;
  final int immobilityTimeoutSeconds;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScenarioModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.contactIds,
    required this.messageTemplate,
    this.recordDurationSeconds = 30,
    this.autoTriggerEnabled = false,
    this.immobilityTimeoutSeconds = 60,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScenarioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ScenarioModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? 'Сценарій',
      contactIds: (data['contactIds'] as List<dynamic>?)?.cast<String>() ?? [],
      messageTemplate: data['messageTemplate'] as String? ?? ScenarioEntity.defaultTemplate,
      recordDurationSeconds: data['recordDurationSeconds'] as int? ?? 30,
      autoTriggerEnabled: data['autoTriggerEnabled'] as bool? ?? false,
      immobilityTimeoutSeconds: data['immobilityTimeoutSeconds'] as int? ?? 60,
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'contactIds': contactIds,
        'messageTemplate': messageTemplate,
        'recordDurationSeconds': recordDurationSeconds,
        'autoTriggerEnabled': autoTriggerEnabled,
        'immobilityTimeoutSeconds': immobilityTimeoutSeconds,
        'isDefault': isDefault,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        'name': name,
        'contactIds': contactIds,
        'messageTemplate': messageTemplate,
        'recordDurationSeconds': recordDurationSeconds,
        'autoTriggerEnabled': autoTriggerEnabled,
        'immobilityTimeoutSeconds': immobilityTimeoutSeconds,
        'isDefault': isDefault,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  ScenarioEntity toEntity() => ScenarioEntity(
        id: id,
        userId: userId,
        name: name,
        contactIds: contactIds,
        messageTemplate: messageTemplate,
        recordDurationSeconds: recordDurationSeconds,
        autoTriggerEnabled: autoTriggerEnabled,
        immobilityTimeoutSeconds: immobilityTimeoutSeconds,
        isDefault: isDefault,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
