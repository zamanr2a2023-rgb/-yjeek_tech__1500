import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/core/utils/app_logger.dart';
import 'package:yjeek_app/features/notifications/model/notifications_repository.dart';
import 'package:yjeek_app/firebase_options.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';

const _androidChannelId = 'yjeek_default';
const _androidChannelName = 'Yjeek notifications';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const _androidChannel = AndroidNotificationChannel(
  _androidChannelId,
  _androidChannelName,
  description: 'Order, payment, and account alerts',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await showYjeekTrayNotification(message);
}

Future<void> showYjeekTrayNotification(RemoteMessage message) async {
  final title = message.notification?.title ??
      message.data['title']?.toString() ??
      'Yjeek';
  final body =
      message.notification?.body ?? message.data['body']?.toString() ?? '';
  if (title.isEmpty && body.isEmpty) return;

  await _localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_yjeek'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);

  await _localNotifications.show(
    id: message.hashCode & 0x7fffffff,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: 'Order, payment, and account alerts',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_stat_yjeek',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  NotificationsRepository? _repo;
  StorageService? _storage;
  bool _started = false;
  Map<String, String>? _pendingOpen;

  Future<void> start({
    required NotificationsRepository repo,
    required StorageService storage,
  }) async {
    _repo = repo;
    _storage = storage;
    if (_started) {
      await syncToken();
      return;
    }
    _started = true;

    try {
      await _initLocalNotifications();
    } catch (error, stack) {
      appLogger.e('Local notifications init failed', error: error, stackTrace: stack);
    }

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    appLogger.i('FCM permission=${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      appLogger.w(
        'Notification permission denied — enable it in device settings for Yjeek',
      );
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      unawaited(_register(token));
    });
    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _pendingOpen = _asStringMap(initial.data);
    }

    await syncToken();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      Future<void>.delayed(const Duration(seconds: 2), syncToken);
    }
  }

  Future<void> syncToken() async {
    final storage = _storage;
    if (storage == null || !storage.hasSession) return;
    try {
      final token = await _readFcmToken();
      if (token != null && token.isNotEmpty) {
        await _register(token);
      }
    } catch (error, stack) {
      appLogger.e('FCM getToken failed', error: error, stackTrace: stack);
    }
  }

  void consumePendingOpen() {
    final pending = _pendingOpen;
    if (pending == null) return;
    _pendingOpen = null;
    openFromData(pending);
  }

  void openFromData(Map<String, String> data) {
    final router = AppRouter.instance;
    if (router == null) {
      _pendingOpen = data;
      return;
    }

    final orderId = data['orderId']?.trim() ?? '';
    final type = (data['type'] ?? data['screen'] ?? '').toUpperCase();
    if (orderId.isNotEmpty) {
      router.push('${RouteNames.orderDetails}?id=$orderId');
      return;
    }
    if (type == 'PROMO' || type == 'OFFERS') {
      router.push(RouteNames.exclusiveOffers);
      return;
    }
    router.push(RouteNames.notifications);
  }

  Future<void> _initLocalNotifications() async {
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_yjeek'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onLocalResponse,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
    final granted = await androidPlugin?.requestNotificationsPermission();
    if (granted == false) {
      appLogger.w('POST_NOTIFICATIONS not granted');
    }
  }

  void _onLocalResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        openFromData(
          decoded.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          ),
        );
        return;
      }
    } catch (_) {}
    openFromData(const {'screen': 'notifications'});
  }

  Future<String?> _readFcmToken() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      String? apns;
      for (var attempt = 0; attempt < 12; attempt++) {
        apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns != null && apns.isNotEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      if (apns == null || apns.isEmpty) {
        appLogger.w('FCM skipped — APNs token not ready yet');
        return null;
      }
    }
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> _register(String token) async {
    final repo = _repo;
    final storage = _storage;
    if (repo == null || storage == null || !storage.hasSession) return;
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : defaultTargetPlatform == TargetPlatform.android
            ? 'android'
            : 'web';
    try {
      await repo.registerDevice(token: token, platform: platform);
    } catch (error, stack) {
      appLogger.e('FCM register device failed', error: error, stackTrace: stack);
    }
  }

  void _onForeground(RemoteMessage message) {
    // iOS already presents notification payloads via APNs when
    // setForegroundNotificationPresentationOptions is enabled.
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.iOS &&
        message.notification != null) {
      return;
    }
    unawaited(
      showYjeekTrayNotification(message).catchError((error, stack) {
        appLogger.e('Local notification failed', error: error, stackTrace: stack);
      }),
    );
  }

  void _onOpened(RemoteMessage message) {
    openFromData(_asStringMap(message.data));
  }

  Map<String, String> _asStringMap(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
