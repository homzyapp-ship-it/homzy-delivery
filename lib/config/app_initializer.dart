import 'dart:io';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyper_local/config/global.dart';
import 'package:hyper_local/firebase_options.dart';
import 'package:hyper_local/config/injection_container.dart';

// Since `main.dart` contains initializeService inside it or other places
// we can keep the local dependencies decoupled by invoking the locator here.
class AppInitializer {
  static Future<void> initialize() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await Hive.initFlutter();
    await Global.initializeToken();
    await Global.initializeSettings();
    await Global.initializeLocationRequest();
    await Global.initializeOnboardingComplete();
    await Global.initializeLoggedinOnce();

    // Dependency Injection

    // Firebase
    try {
      log('🔥 Initializing Firebase...');
      // Android reads android/app/google-services.json; other platforms use firebase_options.dart.
      if (Platform.isAndroid) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      log('✅ Firebase initialized successfully');
    } catch (e) {
      log('❌ Firebase initialization error: $e');
    }
    await initDependencies();
  }
}
