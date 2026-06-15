import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safe_signal/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp();
  await Hive.initFlutter();

  await Future.wait([
    Hive.openBox('app_settings'),
    Hive.openBox('offline_queue'),
    Hive.openBox('gps_log'),
  ]);

  runApp(
    const ProviderScope(
      child: SafeSignalApp(),
    ),
  );
}
