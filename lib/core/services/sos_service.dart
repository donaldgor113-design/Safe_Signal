import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:safe_signal/core/errors/exceptions.dart';
import 'package:safe_signal/core/services/location_service.dart';
import 'package:safe_signal/core/services/storage_service.dart';
import 'package:safe_signal/core/services/video_service.dart';
import 'package:safe_signal/features/sos/data/models/alert_model.dart';
import 'package:safe_signal/features/sos/data/repositories/alert_repository.dart';
import 'package:safe_signal/features/sos/domain/entities/alert_entity.dart';
import 'package:uuid/uuid.dart';

enum SosPhase { countdown, recording, sending, done, cancelled, error }

class SosProgress {
  final SosPhase phase;
  final int countdownValue;
  final int recordingSecondsLeft;
  final bool gpsObtained;
  final bool videoUploaded;
  final bool alertSaved;
  final bool offlineQueued;
  final String? errorMessage;
  final String? alertId;

  const SosProgress({
    required this.phase,
    this.countdownValue = 3,
    this.recordingSecondsLeft = 30,
    this.gpsObtained = false,
    this.videoUploaded = false,
    this.alertSaved = false,
    this.offlineQueued = false,
    this.errorMessage,
    this.alertId,
  });

  SosProgress copyWith({
    SosPhase? phase,
    int? countdownValue,
    int? recordingSecondsLeft,
    bool? gpsObtained,
    bool? videoUploaded,
    bool? alertSaved,
    bool? offlineQueued,
    String? errorMessage,
    String? alertId,
  }) {
    return SosProgress(
      phase: phase ?? this.phase,
      countdownValue: countdownValue ?? this.countdownValue,
      recordingSecondsLeft: recordingSecondsLeft ?? this.recordingSecondsLeft,
      gpsObtained: gpsObtained ?? this.gpsObtained,
      videoUploaded: videoUploaded ?? this.videoUploaded,
      alertSaved: alertSaved ?? this.alertSaved,
      offlineQueued: offlineQueued ?? this.offlineQueued,
      errorMessage: errorMessage ?? this.errorMessage,
      alertId: alertId ?? this.alertId,
    );
  }
}

class SosService {
  final AlertRepository _alertRepository;
  final LocationService _locationService;
  final VideoService _videoService;
  final StorageService _storageService;
  final FirebaseAuth _auth;

  final _progressController = StreamController<SosProgress>.broadcast();
  Stream<SosProgress> get progressStream => _progressController.stream;

  SosProgress _progress = const SosProgress(phase: SosPhase.countdown);
  bool _isCancelled = false;
  Timer? _countdownTimer;
  Timer? _recordingTimer;

  SosService({
    required AlertRepository alertRepository,
    required LocationService locationService,
    required VideoService videoService,
    required StorageService storageService,
    FirebaseAuth? auth,
  })  : _alertRepository = alertRepository,
        _locationService = locationService,
        _videoService = videoService,
        _storageService = storageService,
        _auth = auth ?? FirebaseAuth.instance;

  void _emit(SosProgress progress) {
    _progress = progress;
    _progressController.add(progress);
  }

  Future<void> startSosFlow({int recordDuration = 30}) async {
    _isCancelled = false;
    _emit(const SosProgress(phase: SosPhase.countdown, countdownValue: 3));

    // Phase 1: Countdown
    for (int i = 3; i >= 1; i--) {
      if (_isCancelled) return;
      _emit(_progress.copyWith(countdownValue: i));
      await Future.delayed(const Duration(seconds: 1));
    }

    if (_isCancelled) return;

    // Phase 2: Recording
    _emit(_progress.copyWith(
      phase: SosPhase.recording,
      recordingSecondsLeft: recordDuration,
    ));

    LocationResult? locationResult;
    File? videoFile;

    // Start camera + GPS in parallel
    try {
      await _videoService.initCamera();
      await _videoService.startRecording();
    } on CameraUnavailableException {
      // Continue without video
    }

    // GPS in background
    _getLocation().then((result) {
      locationResult = result;
      if (result != null) {
        _emit(_progress.copyWith(gpsObtained: true));
      }
    });

    // Recording countdown
    int remaining = recordDuration;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      _emit(_progress.copyWith(recordingSecondsLeft: remaining));
      if (remaining <= 0) {
        timer.cancel();
      }
    });

    // Wait for recording duration or early stop
    await Future.delayed(Duration(seconds: recordDuration));
    _recordingTimer?.cancel();

    if (_isCancelled) {
      await _videoService.stopRecording();
      _videoService.dispose();
      return;
    }

    // Stop recording
    videoFile = await _videoService.stopRecording();
    _videoService.dispose();

    await _sendAlert(
      locationResult: locationResult,
      videoFile: videoFile,
    );
  }

  Future<void> stopRecordingEarly() async {
    _recordingTimer?.cancel();
    final videoFile = await _videoService.stopRecording();
    _videoService.dispose();

    LocationResult? locationResult;
    if (_progress.gpsObtained) {
      try {
        locationResult = await _locationService.getCurrentLocation();
      } catch (_) {}
    }

    await _sendAlert(
      locationResult: locationResult,
      videoFile: videoFile,
    );
  }

  Future<void> sendWithoutVideo() async {
    _recordingTimer?.cancel();
    await _videoService.stopRecording();
    _videoService.dispose();

    LocationResult? locationResult;
    try {
      locationResult = await _locationService.getCurrentLocation();
    } catch (_) {}

    await _sendAlert(
      locationResult: locationResult,
      videoFile: null,
    );
  }

  Future<void> _sendAlert({
    LocationResult? locationResult,
    File? videoFile,
  }) async {
    if (_isCancelled) return;

    _emit(_progress.copyWith(phase: SosPhase.sending));

    final userId = _auth.currentUser?.uid ?? '';

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity.contains(ConnectivityResult.none);

    if (isOffline) {
      // Queue offline
      await _queueOffline(
        userId: userId,
        locationResult: locationResult,
        videoFile: videoFile,
      );
      _emit(_progress.copyWith(
        phase: SosPhase.done,
        offlineQueued: true,
      ));
      return;
    }

    // Upload video
    String? videoUrl;
    if (videoFile != null) {
      try {
        videoUrl = await _storageService.uploadVideo(videoFile);
        _emit(_progress.copyWith(videoUploaded: true));
      } on StorageException {
        // Continue without video
      }
    }

    // Save alert to Firestore
    try {
      final alert = AlertModel(
        id: '',
        userId: userId,
        scenarioId: 'default',
        triggeredAt: DateTime.now(),
        triggerType: TriggerType.manual,
        latitude: locationResult?.latitude ?? 0.0,
        longitude: locationResult?.longitude ?? 0.0,
        locationAddress: locationResult?.address,
        videoUrl: videoUrl,
        sentChannels: const [],
        deliveryStatus: const {},
      );

      final alertId = await _alertRepository.createAlert(alert);

      _emit(_progress.copyWith(
        phase: SosPhase.done,
        alertSaved: true,
        alertId: alertId,
      ));
    } on FirestoreException catch (e) {
      // Firestore failed — queue offline
      await _queueOffline(
        userId: userId,
        locationResult: locationResult,
        videoFile: videoFile,
      );
      _emit(_progress.copyWith(
        phase: SosPhase.done,
        offlineQueued: true,
        errorMessage: e.message,
      ));
    }
  }

  Future<LocationResult?> _getLocation() async {
    try {
      return await _locationService.getCurrentLocation();
    } catch (_) {
      return null;
    }
  }

  Future<void> _queueOffline({
    required String userId,
    LocationResult? locationResult,
    File? videoFile,
  }) async {
    final box = Hive.box('offline_queue');
    final entry = {
      'localId': const Uuid().v4(),
      'userId': userId,
      'scenarioId': 'default',
      'triggerType': TriggerType.manual.name,
      'latitude': locationResult?.latitude ?? 0.0,
      'longitude': locationResult?.longitude ?? 0.0,
      'locationAddress': locationResult?.address,
      'videoLocalPath': videoFile?.path,
      'createdAt': DateTime.now().toIso8601String(),
      'attempts': 0,
    };
    await box.add(entry);
  }

  void cancel() {
    _isCancelled = true;
    _countdownTimer?.cancel();
    _recordingTimer?.cancel();
    _emit(_progress.copyWith(phase: SosPhase.cancelled));
    _videoService.dispose();
  }

  void dispose() {
    _countdownTimer?.cancel();
    _recordingTimer?.cancel();
    _progressController.close();
    _videoService.dispose();
  }
}
