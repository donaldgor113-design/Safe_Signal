import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_signal/core/services/location_service.dart';
import 'package:safe_signal/core/services/sos_service.dart';
import 'package:safe_signal/core/services/storage_service.dart';
import 'package:safe_signal/core/services/video_service.dart';
import 'package:safe_signal/features/sos/data/models/alert_model.dart';
import 'package:safe_signal/features/sos/data/repositories/alert_repository.dart';
import 'package:safe_signal/core/services/offline_queue_service.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository();
});

final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  final service = OfflineQueueService(
    alertRepository: ref.watch(alertRepositoryProvider),
  );
  service.setupAutoRetry();
  ref.onDispose(() => service.dispose());
  return service;
});

final alertsStreamProvider = StreamProvider<List<AlertModel>>((ref) {
  return ref.watch(alertRepositoryProvider).watchAlerts();
});

final alertProvider =
    FutureProvider.family<AlertModel?, String>((ref, alertId) {
  return ref.watch(alertRepositoryProvider).getAlert(alertId);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final sosServiceProvider = Provider<SosService>((ref) {
  return SosService(
    alertRepository: ref.watch(alertRepositoryProvider),
    locationService: ref.watch(locationServiceProvider),
    videoService: ref.watch(videoServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});
