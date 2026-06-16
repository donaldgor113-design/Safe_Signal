import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/features/sos/data/models/alert_model.dart';
import 'package:safe_signal/features/sos/domain/entities/alert_entity.dart';
import 'package:safe_signal/features/sos/presentation/providers/sos_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsStreamProvider);
    final theme = Theme.of(context);
    final ssColors = theme.extension<SafeSignalColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Історія')),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Помилка: $e')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Немає тривог', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Тут будуть ваші SOS оповіщення',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return _AlertCard(
                alert: alerts[index],
                ssColors: ssColors,
              );
            },
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  final SafeSignalColors ssColors;

  const _AlertCard({required this.alert, required this.ssColors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    final hasFailures = alert.deliveryStatus.values
        .any((s) => s == DeliveryStatus.failed);
    final allSent = alert.deliveryStatus.values
        .every((s) => s == DeliveryStatus.sent);

    final statusColor = hasFailures
        ? ssColors.deliveryFailed
        : allSent
            ? ssColors.deliverySuccess
            : ssColors.statusWarning;

    final statusText = hasFailures
        ? 'Частково надіслано'
        : allSent
            ? 'Надіслано'
            : 'В процесі';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/history/${alert.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  alert.videoUrl != null
                      ? Icons.videocam
                      : Icons.warning_amber_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOS — ${_triggerLabel(alert.triggerType)}',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      dateFormat.format(alert.triggeredAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (alert.locationAddress != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        alert.locationAddress!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _triggerLabel(TriggerType type) {
    return switch (type) {
      TriggerType.manual => 'Ручний',
      TriggerType.immobility => 'Нерухомість',
      TriggerType.wearable => 'Пристрій',
    };
  }
}
