class MedicationEntity {
  final String name;
  final String dose;
  final String frequency;

  const MedicationEntity({
    required this.name,
    required this.dose,
    required this.frequency,
  });
}

class MedicalProfileEntity {
  final List<String> diagnoses;
  final List<MedicationEntity> medications;
  final List<String> allergies;
  final String? bloodType;
  final String? doctorName;
  final String? doctorPhone;
  final String? clinicName;
  final String? clinicPhone;
  final DateTime updatedAt;

  const MedicalProfileEntity({
    required this.diagnoses,
    required this.medications,
    required this.allergies,
    this.bloodType,
    this.doctorName,
    this.doctorPhone,
    this.clinicName,
    this.clinicPhone,
    required this.updatedAt,
  });

  bool get isComplete =>
      diagnoses.isNotEmpty &&
      bloodType != null &&
      bloodType!.isNotEmpty;

  static MedicalProfileEntity empty() => MedicalProfileEntity(
        diagnoses: const [],
        medications: const [],
        allergies: const [],
        updatedAt: DateTime.now(),
      );
}
