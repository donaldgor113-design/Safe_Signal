class ScenarioEntity {
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

  const ScenarioEntity({
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

  static const String defaultTemplate = '''
🆘 {{userName}} потребує допомоги!

📍 {{address}}
🗺 {{location}}
🕐 {{timestamp}}
{{diagnoses}}
{{videoUrl}}
''';

  ScenarioEntity copyWith({
    String? name,
    List<String>? contactIds,
    String? messageTemplate,
    int? recordDurationSeconds,
    bool? autoTriggerEnabled,
    int? immobilityTimeoutSeconds,
    bool? isDefault,
  }) {
    return ScenarioEntity(
      id: id,
      userId: userId,
      name: name ?? this.name,
      contactIds: contactIds ?? this.contactIds,
      messageTemplate: messageTemplate ?? this.messageTemplate,
      recordDurationSeconds: recordDurationSeconds ?? this.recordDurationSeconds,
      autoTriggerEnabled: autoTriggerEnabled ?? this.autoTriggerEnabled,
      immobilityTimeoutSeconds: immobilityTimeoutSeconds ?? this.immobilityTimeoutSeconds,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
