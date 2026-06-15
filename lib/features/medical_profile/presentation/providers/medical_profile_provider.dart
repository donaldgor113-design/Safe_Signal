import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_signal/features/medical_profile/data/models/medical_profile_model.dart';
import 'package:safe_signal/features/medical_profile/data/repositories/medical_profile_repository.dart';

final medicalProfileRepositoryProvider =
    Provider<MedicalProfileRepository>((ref) {
  return MedicalProfileRepository();
});

final medicalProfileStreamProvider =
    StreamProvider<MedicalProfileModel>((ref) {
  return ref.watch(medicalProfileRepositoryProvider).watchMedicalProfile();
});

final medicalProfileProvider =
    FutureProvider<MedicalProfileModel>((ref) async {
  return ref.watch(medicalProfileRepositoryProvider).getMedicalProfile();
});
