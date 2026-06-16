import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/features/sos/domain/entities/alert_entity.dart';
import 'package:safe_signal/features/sos/presentation/providers/sos_provider.dart';
import 'package:video_player/video_player.dart';

class AlertDetailScreen extends ConsumerWidget {
  final String alertId;

  const AlertDetailScreen({super.key, required this.alertId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertAsync = ref.watch(alertProvider(alertId));
    final theme = Theme.of(context);
    final ssColors = theme.extension<SafeSignalColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Деталі тривоги')),
      body: alertAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Помилка: $e')),
        data: (alert) {
          if (alert == null) {
            return const Center(child: Text('Тривогу не знайдено'));
          }

          final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (alert.videoUrl != null) ...[
                _VideoPlayerWidget(videoUrl: alert.videoUrl!),
                const SizedBox(height: AppSpacing.lg),
              ],
              _InfoCard(
                title: 'Інформація',
                children: [
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Час',
                    value: dateFormat.format(alert.triggeredAt),
                  ),
                  _InfoRow(
                    icon: Icons.touch_app,
                    label: 'Тригер',
                    value: switch (alert.triggerType) {
                      TriggerType.manual => 'Ручний',
                      TriggerType.immobility => 'Нерухомість',
                      TriggerType.wearable => 'Пристрій',
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (alert.latitude != 0.0 || alert.longitude != 0.0)
                _InfoCard(
                  title: 'Локація',
                  children: [
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Координати',
                      value:
                          '${alert.latitude.toStringAsFixed(6)}, ${alert.longitude.toStringAsFixed(6)}',
                    ),
                    if (alert.locationAddress != null)
                      _InfoRow(
                        icon: Icons.map,
                        label: 'Адреса',
                        value: alert.locationAddress!,
                      ),
                  ],
                ),
              if (alert.latitude != 0.0 || alert.longitude != 0.0)
                const SizedBox(height: AppSpacing.lg),
              _InfoCard(
                title: 'Статус доставки',
                children: alert.deliveryStatus.entries.map((entry) {
                  final channelParts = entry.key.split('_');
                  final channel = channelParts.first.toUpperCase();
                  final statusColor = entry.value == DeliveryStatus.sent
                      ? ssColors.deliverySuccess
                      : entry.value == DeliveryStatus.failed
                          ? ssColors.deliveryFailed
                          : ssColors.statusWarning;
                  final statusText = switch (entry.value) {
                    DeliveryStatus.sent => 'Надіслано',
                    DeliveryStatus.failed => 'Помилка',
                    DeliveryStatus.pending => 'Очікує',
                  };

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(
                          entry.value == DeliveryStatus.sent
                              ? Icons.check_circle
                              : entry.value == DeliveryStatus.failed
                                  ? Icons.error
                                  : Icons.hourglass_empty,
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            channel,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
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
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
              size: 56,
              color: Colors.white.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
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
