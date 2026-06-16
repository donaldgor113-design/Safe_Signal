import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:safe_signal/core/constants/app_constants.dart';
import 'package:safe_signal/features/sos/data/models/alert_model.dart';
import 'package:safe_signal/features/sos/data/repositories/alert_repository.dart';
import 'package:safe_signal/features/sos/domain/entities/alert_entity.dart';

class OfflineQueueService {
  final AlertRepository _alertRepository;
  final Connectivity _connectivity;
  StreamSubscription? _connectivitySubscription;

  OfflineQueueService({
    required AlertRepository alertRepository,
    Connectivity? connectivity,
  })  : _alertRepository = alertRepository,
        _connectivity = connectivity ?? Connectivity();

  Future<void> retryOfflineQueue() async {
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final box = Hive.box('offline_queue');
    if (box.isEmpty) return;

    final keysToDelete = <dynamic>[];
    final keysToUpdate = <dynamic, Map>{};

    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw == null) continue;

      final entry = Map<dynamic, dynamic>.from(raw as Map);
      final attempts = (entry['attempts'] as int?) ?? 0;

      if (attempts >= AppConstants.offlineQueueMaxAttempts) {
        keysToDelete.add(key);
        continue;
      }

      try {
        final triggerName = entry['triggerType'] as String? ?? 'manual';
        final triggerType = TriggerType.values.firstWhere(
          (t) => t.name == triggerName,
          orElse: () => TriggerType.manual,
        );

        final alert = AlertModel(
          id: '',
          userId: (entry['userId'] as String?) ?? '',
          scenarioId: (entry['scenarioId'] as String?) ?? 'default',
          triggeredAt: DateTime.tryParse(entry['createdAt'] as String? ?? '') ?? DateTime.now(),
          triggerType: triggerType,
          latitude: (entry['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (entry['longitude'] as num?)?.toDouble() ?? 0.0,
          locationAddress: entry['locationAddress'] as String?,
          videoUrl: null,
          sentChannels: const [],
          deliveryStatus: const {},
        );

        await _alertRepository.createAlert(alert);
        keysToDelete.add(key);
      } catch (_) {
        entry['attempts'] = attempts + 1;
        keysToUpdate[key] = entry;
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
    }
    for (final entry in keysToUpdate.entries) {
      await box.put(entry.key, entry.value);
    }
  }

  void setupAutoRetry() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        retryOfflineQueue();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  int get queueLength {
    try {
      return Hive.box('offline_queue').length;
    } catch (_) {
      return 0;
    }
  }
}
