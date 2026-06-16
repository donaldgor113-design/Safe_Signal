import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:hive/hive.dart';

class ImmobilityDetectionService {
  static const double _movementThreshold = 1.5;
  static const double _gravity = 9.8;

  StreamSubscription<AccelerometerEvent>? _subscription;
  Timer? _immobilityTimer;
  DateTime? _lastMovement;
  void Function()? _onImmobilityDetected;

  bool get isEnabled {
    final box = Hive.box('app_settings');
    return box.get('immobility_detection_enabled', defaultValue: false);
  }

  int get timeoutSeconds {
    final box = Hive.box('app_settings');
    return box.get('immobility_timeout_seconds', defaultValue: 60);
  }

  void start({required void Function() onImmobilityDetected}) {
    if (!isEnabled) return;
    _onImmobilityDetected = onImmobilityDetected;
    _lastMovement = DateTime.now();
    _subscription?.cancel();
    _subscription = accelerometerEventStream().listen(_onAccelerometerEvent);
    _startTimer();
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _immobilityTimer?.cancel();
    _immobilityTimer = null;
    _lastMovement = null;
  }

  void _startTimer() {
    _immobilityTimer?.cancel();
    _immobilityTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_lastMovement == null) return;
      final elapsed = DateTime.now().difference(_lastMovement!);
      if (elapsed.inSeconds >= timeoutSeconds) {
        _immobilityTimer?.cancel();
        _onImmobilityDetected?.call();
      }
    });
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    final deviation = (magnitude - _gravity).abs();

    if (deviation > _movementThreshold) {
      _lastMovement = DateTime.now();
    }
  }

  void resetTimer() {
    _lastMovement = DateTime.now();
  }
}
