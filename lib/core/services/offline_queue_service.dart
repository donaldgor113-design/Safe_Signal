import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:safe_signal/core/constants/app_constants.dart';
import 'package:safe_signal/core/errors/exceptions.dart';
import 'package:safe_signal/features/sos/data/models/alert_model.dart';
import 'package:safe_signal/features/sos/data/repositories/alert_repository.dart';

class OfflineQueueService {
  final AlertRepository _alertRepository;
  final Connectivity _connectivity;

  OfflineQueueService({
    required AlertRepository alertRepository,
    Connectivity? connectivity,
  })  : _alertRepository = alertRepository,
        _connectivity = connectivity ?? Connectivity();

  Future<void> retryOfflineQueue() async {
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return;
    }

    final box = Hive.box('offline_queue');
    final entries = box.values.toList();

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i] as Map<dynamic, dynamic>;
      final attempts = (entry['attempts'] as int?) ?? 0;

      if (attempts >= AppConstants.offlineQueueMaxAttempts) {
        await box.deleteAt(i);
        continue;
      }

      try {
        final alert = AlertModel(
          id: '',
          userId: entry['userId'] as String,
          scenarioId: entry['scenarioId'] as String,
          triggeredAt: DateTime.parse(entry['createdAt'] as String),
          triggerType: TriggerType.manual,
          latitude: (entry['latitude'] as num).toDouble(),
          longitude: (entry['longitude'] as num).toDouble(),
          locationAddress: entry['locationAddress'] as String?,
          videoUrl: null,
          sentChannels: const [],
          deliveryStatus: const {},
        );

        await _alertRepository.createAlert(alert);
        await box.deleteAt(i);
      } catch (e) {
        entry['attempts'] = attempts + 1;
        await box.putAt(i, entry);
      }
    }
  }

  Future<void> setupAutoRetry() async {
    _connectivity.onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        retryOfflineQueue();
      }
    });
  }

  int get queueLength {
    try {
      return Hive.box('offline_queue').length;
    } catch (_) {
      return 0;
    }
  }
}
