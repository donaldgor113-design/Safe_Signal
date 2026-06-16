import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:hive/hive.dart';

class ShakeDetectionService {
  static const double _shakeThreshold = 15.0;
  static const int _shakeCountThreshold = 3;
  static const Duration _shakeWindow = Duration(milliseconds: 1000);
  static const Duration _cooldown = Duration(seconds: 5);

  StreamSubscription<AccelerometerEvent>? _subscription;
  final List<DateTime> _shakeTimestamps = [];
  DateTime? _lastTrigger;
  void Function()? _onShakeDetected;

  bool get isEnabled {
    final box = Hive.box('app_settings');
    return box.get('shake_sos_enabled', defaultValue: false);
  }

  void start({required void Function() onShakeDetected}) {
    if (!isEnabled) return;
    _onShakeDetected = onShakeDetected;
    _subscription?.cancel();
    _subscription = accelerometerEventStream().listen(_onAccelerometerEvent);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _shakeTimestamps.clear();
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (magnitude > _shakeThreshold) {
      final now = DateTime.now();

      if (_lastTrigger != null && now.difference(_lastTrigger!) < _cooldown) {
        return;
      }

      _shakeTimestamps.add(now);
      _shakeTimestamps.removeWhere(
        (t) => now.difference(t) > _shakeWindow,
      );

      if (_shakeTimestamps.length >= _shakeCountThreshold) {
        _lastTrigger = now;
        _shakeTimestamps.clear();
        _onShakeDetected?.call();
      }
    }
  }
}
