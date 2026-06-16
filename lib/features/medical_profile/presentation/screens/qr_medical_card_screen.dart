import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/features/medical_profile/presentation/providers/medical_profile_provider.dart';

class QrMedicalCardScreen extends ConsumerWidget {
  const QrMedicalCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(medicalProfileStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('QR Медична картка')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Помилка: $e')),
        data: (profile) {
          final qrData = jsonEncode({
            'app': 'SafeSignal',
            'diagnoses': profile.diagnoses,
            'allergies': profile.allergies,
            'bloodType': profile.bloodType,
            'medications': profile.medications
                .map((m) => '${m.name} ${m.dose}')
                .toList(),
            'doctorName': profile.doctorName,
            'doctorPhone': profile.doctorPhone,
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Text(
                          'Медична картка',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 250,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Покажіть цей код медпрацівнику',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Інформація в QR',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (profile.diagnoses.isNotEmpty)
                          _DataRow(
                            label: 'Діагнози',
                            value: profile.diagnoses.join(', '),
                          ),
                        if (profile.allergies.isNotEmpty)
                          _DataRow(
                            label: 'Алергії',
                            value: profile.allergies.join(', '),
                          ),
                        if (profile.bloodType != null)
                          _DataRow(
                            label: 'Група крові',
                            value: profile.bloodType!,
                          ),
                        if (profile.medications.isNotEmpty)
                          _DataRow(
                            label: 'Ліки',
                            value: profile.medications
                                .map((m) => '${m.name} (${m.dose})')
                                .join(', '),
                          ),
                        if (profile.doctorName != null)
                          _DataRow(
                            label: 'Лікар',
                            value: profile.doctorName!,
                          ),
                        if (profile.doctorPhone != null)
                          _DataRow(
                            label: 'Тел. лікаря',
                            value: profile.doctorPhone!,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
