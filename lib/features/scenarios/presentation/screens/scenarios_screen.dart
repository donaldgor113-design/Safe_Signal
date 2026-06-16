import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/features/scenarios/data/models/scenario_model.dart';
import 'package:safe_signal/features/scenarios/presentation/providers/scenarios_provider.dart';

class ScenariosScreen extends ConsumerWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenariosStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Сценарії')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scenarios/add'),
        child: const Icon(Icons.add),
      ),
      body: scenariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Помилка: $e')),
        data: (scenarios) {
          if (scenarios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.playlist_play_outlined,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Немає сценаріїв',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Створіть сценарій для налаштування оповіщень',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => context.push('/scenarios/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('Створити сценарій'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: scenarios.length,
            itemBuilder: (context, index) {
              return _ScenarioCard(scenario: scenarios[index]);
            },
          );
        },
      ),
    );
  }
}

class _ScenarioCard extends ConsumerWidget {
  final ScenarioModel scenario;

  const _ScenarioCard({required this.scenario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: scenario.isDefault
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.playlist_play,
            color: scenario.isDefault
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(scenario.name),
            ),
            if (scenario.isDefault)
              Chip(
                label: const Text('Основний'),
                labelStyle: const TextStyle(fontSize: 10),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${scenario.contactIds.length} контактів',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Запис: ${scenario.recordDurationSeconds} сек',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (scenario.autoTriggerEnabled)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Авто-тригер: ${scenario.immobilityTimeoutSeconds} сек',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () {
                context.push('/scenarios/${scenario.id}');
              },
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Редагувати'),
                ],
              ),
            ),
            if (!scenario.isDefault)
              PopupMenuItem(
                onTap: () async {
                  await ref
                      .read(scenariosRepositoryProvider)
                      .setDefaultScenario(scenario.id);
                  ref.invalidate(scenariosStreamProvider);
                },
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 18),
                    SizedBox(width: 8),
                    Text('Зробити основним'),
                  ],
                ),
              ),
            if (scenario.contactIds.isNotEmpty)
              PopupMenuItem(
                onTap: () {
                  _showScenarioPreview(context, scenario);
                },
                child: const Row(
                  children: [
                    Icon(Icons.preview, size: 18),
                    SizedBox(width: 8),
                    Text('Переглянути'),
                  ],
                ),
              ),
            PopupMenuItem(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Видалити сценарій?'),
                    content: Text('${scenario.name} буде видалено'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Скасувати'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Видалити'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await ref
                      .read(scenariosRepositoryProvider)
                      .deleteScenario(scenario.id);
                  ref.invalidate(scenariosStreamProvider);
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Видалити', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScenarioPreview(BuildContext context, ScenarioModel scenario) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${scenario.name} — деталі'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Контакти: ${scenario.contactIds.length}'),
              const SizedBox(height: 8),
              Text('Запис: ${scenario.recordDurationSeconds} сек'),
              const SizedBox(height: 8),
              Text(
                'Авто-тригер: ${scenario.autoTriggerEnabled ? "ВКЛ (${scenario.immobilityTimeoutSeconds} сек)" : "ВИМ"}',
              ),
              const SizedBox(height: 16),
              const Text('Шаблон повідомлення:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scenario.messageTemplate,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрити'),
          ),
        ],
      ),
    );
  }
}
