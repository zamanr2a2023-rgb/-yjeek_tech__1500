import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:yjeek_app/app.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/cache_service.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/core/utils/app_logger.dart';
import 'package:yjeek_app/features/notifications/model/notifications_repository.dart';
import 'package:yjeek_app/features/notifications/service/push_notification_service.dart';
import 'package:yjeek_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppImageCaches();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (error, stack) {
    appLogger.e('Firebase init failed', error: error, stackTrace: stack);
  }

  // Fixes blank / clipped Google Maps PlatformViews on many Android devices.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    final mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(),
    GoogleFonts.notoSansArabic(),
  ]);

  final storage = await StorageService.init();
  Get.put<StorageService>(storage, permanent: true);
  Get.put<ApiClient>(ApiClient(storage: storage), permanent: true);

  appLogger.i('Yjeek app starting');

  runApp(
    const ProviderScope(
      child: YjeekApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await PushNotificationService.instance.start(
        repo: NotificationsRepository(Get.find<ApiClient>(), storage),
        storage: storage,
      );
    } catch (error, stack) {
      appLogger.e('Push start failed', error: error, stackTrace: stack);
    }
  });
}
