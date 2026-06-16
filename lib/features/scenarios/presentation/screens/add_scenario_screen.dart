import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:safe_signal/features/scenarios/data/models/scenario_model.dart';
import 'package:safe_signal/features/scenarios/domain/entities/scenario_entity.dart';
import 'package:safe_signal/features/scenarios/presentation/providers/scenarios_provider.dart';

class AddScenarioScreen extends ConsumerStatefulWidget {
  final String? scenarioId;

  const AddScenarioScreen({super.key, this.scenarioId});

  @override
  ConsumerState<AddScenarioScreen> createState() => _AddScenarioScreenState();
}

class _AddScenarioScreenState extends ConsumerState<AddScenarioScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _loaded = false;

  late TextEditingController _nameController;
  late TextEditingController _templateController;
  late TextEditingController _recordDurationController;
  late TextEditingController _immobilityTimeoutController;

  late List<String> _selectedContactIds;
  late bool _autoTriggerEnabled;

  bool get _isEditing => widget.scenarioId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _templateController = TextEditingController(
      text: ScenarioEntity.defaultTemplate,
    );
    _recordDurationController = TextEditingController(text: '30');
    _immobilityTimeoutController = TextEditingController(text: '60');
    _selectedContactIds = [];
    _autoTriggerEnabled = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _templateController.dispose();
    _recordDurationController.dispose();
    _immobilityTimeoutController.dispose();
    super.dispose();
  }

  void _populateFromScenario(ScenarioModel scenario) {
    if (_loaded) return;
    _loaded = true;
    _nameController.text = scenario.name;
    _templateController.text = scenario.messageTemplate;
    _recordDurationController.text = scenario.recordDurationSeconds.toString();
    _immobilityTimeoutController.text =
        scenario.immobilityTimeoutSeconds.toString();
    _selectedContactIds = List.from(scenario.contactIds);
    _autoTriggerEnabled = scenario.autoTriggerEnabled;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedContactIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оберіть хоча б один контакт')),
      );
      return;
    }

    if (_templateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Шаблон повідомлення не може бути порожнім')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final scenario = ScenarioModel(
        id: widget.scenarioId ?? '',
        userId: '',
        name: _nameController.text.trim(),
        contactIds: _selectedContactIds,
        messageTemplate: _templateController.text.trim(),
        recordDurationSeconds: int.tryParse(_recordDurationController.text) ?? 30,
        autoTriggerEnabled: _autoTriggerEnabled,
        immobilityTimeoutSeconds: int.tryParse(_immobilityTimeoutController.text) ?? 60,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(scenariosRepositoryProvider);
      if (_isEditing) {
        await repo.updateScenario(scenario);
      } else {
        await repo.createScenario(scenario);
      }

      ref.invalidate(scenariosStreamProvider);
      if (mounted) context.pop();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactsAsync = ref.watch(contactsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редагувати сценарій' : 'Створити сценарій'),
      ),
      body: _isEditing
          ? ref.watch(scenarioProvider(widget.scenarioId!)).when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Помилка: $e')),
                data: (scenario) {
                  if (scenario == null) {
                    return const Center(child: Text('Сценарій не знайдено'));
                  }
                  _populateFromScenario(scenario);
                  return _buildForm(theme, contactsAsync);
                },
              )
          : _buildForm(theme, contactsAsync),
    );
  }

  Widget _buildForm(ThemeData theme, AsyncValue contactsAsync) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Ім'я сценарію *"),
            validator: (v) => v?.trim().isEmpty ?? true ? "Обов'язкове поле" : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Контакти для оповіщення *',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          contactsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Text('Помилка: $e'),
            data: (contacts) {
              if (contacts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Спочатку додайте контакти',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                );
              }

              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: contacts.map((contact) {
                  final isSelected = _selectedContactIds.contains(contact.id);
                  return FilterChip(
                    label: Text(contact.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedContactIds.add(contact.id);
                        } else {
                          _selectedContactIds.remove(contact.id);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Налаштування запису',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _recordDurationController,
            decoration: const InputDecoration(
              labelText: 'Тривалість запису (сек) *',
              hintText: '30',
            ),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v?.trim().isEmpty ?? true) return "Обов'язкове поле";
              if (int.tryParse(v!) == null) return 'Має бути число';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Авто-тригер (опційно)',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            value: _autoTriggerEnabled,
            onChanged: (v) => setState(() => _autoTriggerEnabled = v ?? false),
            title: const Text('Увімкнути автоматичний тригер'),
            subtitle: const Text('Срабатывает при нерухомості'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_autoTriggerEnabled) ...[
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _immobilityTimeoutController,
              decoration: const InputDecoration(
                labelText: 'Час затримки нерухомості (сек)',
                hintText: '60',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return "Обов'язкове поле";
                if (int.tryParse(v!) == null) return 'Має бути число';
                return null;
              },
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Шаблон повідомлення',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Доступні змінні: {{userName}}, {{address}}, {{location}}, {{timestamp}}, {{diagnoses}}, {{videoUrl}}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _templateController,
            decoration: const InputDecoration(
              labelText: 'Текст повідомлення',
              border: OutlineInputBorder(),
            ),
            minLines: 5,
            maxLines: 10,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => context.pop(),
                  child: const Text('Скасувати'),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Зберегти'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
