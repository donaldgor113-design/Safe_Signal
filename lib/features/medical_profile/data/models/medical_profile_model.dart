import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_signal/features/medical_profile/domain/entities/medical_profile_entity.dart';

class MedicationModel {
  final String name;
  final String dose;
  final String frequency;

  const MedicationModel({
    required this.name,
    required this.dose,
    required this.frequency,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      name: map['name'] as String? ?? '',
      dose: map['dose'] as String? ?? '',
      frequency: map['frequency'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'dose': dose,
        'frequency': frequency,
      };

  MedicationEntity toEntity() => MedicationEntity(
        name: name,
        dose: dose,
        frequency: frequency,
      );

  factory MedicationModel.fromEntity(MedicationEntity entity) {
    return MedicationModel(
      name: entity.name,
      dose: entity.dose,
      frequency: entity.frequency,
    );
  }
}

class MedicalProfileModel {
  final List<String> diagnoses;
  final List<MedicationModel> medications;
  final List<String> allergies;
  final String? bloodType;
  final String? doctorName;
  final String? doctorPhone;
  final String? clinicName;
  final String? clinicPhone;
  final DateTime updatedAt;

  const MedicalProfileModel({
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

  factory MedicalProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MedicalProfileModel.fromMap(data);
  }

  factory MedicalProfileModel.fromMap(Map<String, dynamic> map) {
    return MedicalProfileModel(
      diagnoses: List<String>.from(map['diagnoses'] ?? []),
      medications: (map['medications'] as List<dynamic>?)
              ?.map((e) => MedicationModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      allergies: List<String>.from(map['allergies'] ?? []),
      bloodType: map['bloodType'] as String?,
      doctorName: map['doctorName'] as String?,
      doctorPhone: map['doctorPhone'] as String?,
      clinicName: map['clinicName'] as String?,
      clinicPhone: map['clinicPhone'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'diagnoses': diagnoses,
        'medications': medications.map((m) => m.toMap()).toList(),
        'allergies': allergies,
        'bloodType': bloodType,
        'doctorName': doctorName,
        'doctorPhone': doctorPhone,
        'clinicName': clinicName,
        'clinicPhone': clinicPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  MedicalProfileEntity toEntity() => MedicalProfileEntity(
        diagnoses: diagnoses,
        medications: medications.map((m) => m.toEntity()).toList(),
        allergies: allergies,
        bloodType: bloodType,
        doctorName: doctorName,
        doctorPhone: doctorPhone,
        clinicName: clinicName,
        clinicPhone: clinicPhone,
        updatedAt: updatedAt,
      );

  factory MedicalProfileModel.fromEntity(MedicalProfileEntity entity) {
    return MedicalProfileModel(
      diagnoses: entity.diagnoses,
      medications:
          entity.medications.map((m) => MedicationModel.fromEntity(m)).toList(),
      allergies: entity.allergies,
      bloodType: entity.bloodType,
      doctorName: entity.doctorName,
      doctorPhone: entity.doctorPhone,
      clinicName: entity.clinicName,
      clinicPhone: entity.clinicPhone,
      updatedAt: entity.updatedAt,
    );
  }

  static MedicalProfileModel empty() => MedicalProfileModel(
        diagnoses: const [],
        medications: const [],
        allergies: const [],
        updatedAt: DateTime.now(),
      );
}
