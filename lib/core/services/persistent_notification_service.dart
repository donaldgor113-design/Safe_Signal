import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';

class PersistentNotificationService {
  static final _service = FlutterBackgroundService();

  static Future<void> initialize() async {
    await _service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'safe_signal_sos',
        initialNotificationTitle: 'SafeSignal',
        initialNotificationContent: 'SOS захист активний',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
    );
  }

  static Future<void> start() async {
    await _service.startService();
  }

  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  static Future<bool> isRunning() async {
    return await _service.isRunning();
  }
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((_) {
      service.stopSelf();
    });

    service.on('triggerSos').listen((_) {
      service.invoke('sosTriggered');
    });

    await service.setForegroundNotificationInfo(
      title: 'SafeSignal',
      content: 'Натисніть для SOS',
    );
  }
}
