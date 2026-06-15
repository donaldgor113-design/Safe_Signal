import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/core/utils/validators.dart';
import 'package:safe_signal/features/medical_profile/data/models/medical_profile_model.dart';
import 'package:safe_signal/features/medical_profile/presentation/providers/medical_profile_provider.dart';

class MedicalProfileScreen extends ConsumerStatefulWidget {
  const MedicalProfileScreen({super.key});

  @override
  ConsumerState<MedicalProfileScreen> createState() =>
      _MedicalProfileScreenState();
}

class _MedicalProfileScreenState extends ConsumerState<MedicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _bloodTypeController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _doctorPhoneController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicPhoneController = TextEditingController();

  final _diagnosisInputController = TextEditingController();
  final _allergyInputController = TextEditingController();
  final _medNameController = TextEditingController();
  final _medDoseController = TextEditingController();
  final _medFreqController = TextEditingController();

  List<String> _diagnoses = [];
  List<MedicationModel> _medications = [];
  List<String> _allergies = [];
  bool _loaded = false;

  static const _bloodTypes = [
    'O(I) Rh+',
    'O(I) Rh-',
    'A(II) Rh+',
    'A(II) Rh-',
    'B(III) Rh+',
    'B(III) Rh-',
    'AB(IV) Rh+',
    'AB(IV) Rh-',
  ];

  static const _commonAllergies = [
    'Пеніцилін',
    'Аспірин',
    'Йод',
    'Латекс',
    'Арахіс',
    'Молоко',
  ];

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _clinicNameController.dispose();
    _clinicPhoneController.dispose();
    _diagnosisInputController.dispose();
    _allergyInputController.dispose();
    _medNameController.dispose();
    _medDoseController.dispose();
    _medFreqController.dispose();
    super.dispose();
  }

  void _populateFromModel(MedicalProfileModel model) {
    if (_loaded) return;
    _loaded = true;
    _diagnoses = List.from(model.diagnoses);
    _medications = List.from(model.medications);
    _allergies = List.from(model.allergies);
    _bloodTypeController.text = model.bloodType ?? '';
    _doctorNameController.text = model.doctorName ?? '';
    _doctorPhoneController.text = model.doctorPhone ?? '';
    _clinicNameController.text = model.clinicName ?? '';
    _clinicPhoneController.text = model.clinicPhone ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final profile = MedicalProfileModel(
        diagnoses: _diagnoses,
        medications: _medications,
        allergies: _allergies,
        bloodType: _bloodTypeController.text.trim().isEmpty
            ? null
            : _bloodTypeController.text.trim(),
        doctorName: _doctorNameController.text.trim().isEmpty
            ? null
            : _doctorNameController.text.trim(),
        doctorPhone: _doctorPhoneController.text.trim().isEmpty
            ? null
            : _doctorPhoneController.text.trim(),
        clinicName: _clinicNameController.text.trim().isEmpty
            ? null
            : _clinicNameController.text.trim(),
        clinicPhone: _clinicPhoneController.text.trim().isEmpty
            ? null
            : _clinicPhoneController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await ref
          .read(medicalProfileRepositoryProvider)
          .saveMedicalProfile(profile);

      ref.invalidate(medicalProfileStreamProvider);
      ref.invalidate(medicalProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профіль збережено')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addDiagnosis() {
    final text = _diagnosisInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _diagnoses.add(text);
      _diagnosisInputController.clear();
    });
  }

  void _addAllergy(String allergy) {
    if (_allergies.contains(allergy)) return;
    setState(() => _allergies.add(allergy));
  }

  void _addCustomAllergy() {
    final text = _allergyInputController.text.trim();
    if (text.isEmpty || _allergies.contains(text)) return;
    setState(() {
      _allergies.add(text);
      _allergyInputController.clear();
    });
  }

  void _addMedication() {
    final name = _medNameController.text.trim();
    final dose = _medDoseController.text.trim();
    final freq = _medFreqController.text.trim();
    if (name.isEmpty || dose.isEmpty || freq.isEmpty) return;
    setState(() {
      _medications.add(MedicationModel(name: name, dose: dose, frequency: freq));
      _medNameController.clear();
      _medDoseController.clear();
      _medFreqController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(medicalProfileStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Медичний профіль')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Помилка: $e')),
        data: (profile) {
          _populateFromModel(profile);
          return _buildForm(theme);
        },
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (_diagnoses.isEmpty)
            _IncompleteBanner(
              message: 'Заповніть медпрофіль для кращого оповіщення',
            ),
          _SectionHeader(title: 'Діагнози'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _diagnoses
                .map((d) => Chip(
                      label: Text(d),
                      onDeleted: () =>
                          setState(() => _diagnoses.remove(d)),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _diagnosisInputController,
                  decoration: const InputDecoration(
                    labelText: 'Додати діагноз',
                    hintText: 'Наприклад: Епілепсія',
                  ),
                  onFieldSubmitted: (_) => _addDiagnosis(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: _addDiagnosis,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeader(title: 'Ліки'),
          const SizedBox(height: AppSpacing.sm),
          ..._medications.asMap().entries.map((entry) => Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  title: Text(entry.value.name),
                  subtitle:
                      Text('${entry.value.dose} — ${entry.value.frequency}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(
                        () => _medications.removeAt(entry.key)),
                  ),
                ),
              )),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  TextFormField(
                    controller: _medNameController,
                    decoration:
                        const InputDecoration(labelText: 'Назва препарату'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _medDoseController,
                          decoration: const InputDecoration(
                            labelText: 'Дозування',
                            hintText: '12.5мг',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextFormField(
                          controller: _medFreqController,
                          decoration: const InputDecoration(
                            labelText: 'Частота',
                            hintText: '2 рази на день',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      onPressed: _addMedication,
                      icon: const Icon(Icons.add),
                      label: const Text('Додати'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeader(title: 'Алергії'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ..._commonAllergies.map((a) => FilterChip(
                    label: Text(a),
                    selected: _allergies.contains(a),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _addAllergy(a);
                        } else {
                          _allergies.remove(a);
                        }
                      });
                    },
                  )),
              ..._allergies
                  .where((a) => !_commonAllergies.contains(a))
                  .map((a) => Chip(
                        label: Text(a),
                        onDeleted: () =>
                            setState(() => _allergies.remove(a)),
                      )),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _allergyInputController,
                  decoration: const InputDecoration(
                    labelText: 'Інша алергія',
                  ),
                  onFieldSubmitted: (_) => _addCustomAllergy(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: _addCustomAllergy,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeader(title: 'Медичні дані'),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            value: _bloodTypeController.text.isEmpty
                ? null
                : _bloodTypeController.text,
            decoration: const InputDecoration(
              labelText: 'Група крові',
            ),
            items: _bloodTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) {
              _bloodTypeController.text = value ?? '';
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeader(title: 'Контакт лікаря'),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _doctorNameController,
            decoration: const InputDecoration(labelText: "Ім'я лікаря"),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _doctorPhoneController,
            decoration: const InputDecoration(
              labelText: 'Телефон лікаря',
              hintText: '+380501234567',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                return Validators.phone(value);
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _clinicNameController,
            decoration: const InputDecoration(labelText: 'Назва клініки'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _clinicPhoneController,
            decoration: const InputDecoration(
              labelText: 'Телефон клініки',
              hintText: '+380441234567',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                return Validators.phone(value);
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Зберегти'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _IncompleteBanner extends StatelessWidget {
  final String message;
  const _IncompleteBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
