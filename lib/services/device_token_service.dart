
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import '../screens/appointments/appointments_screen.dart';
import 'device_token_service.dart';

class PushNotificationService {
  PushNotificationService._();

  // Recuperiamo l'istanza solo dopo aver inizializzato Firebase.
  static FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  static bool _initialized = false;

  static Future<void> initialize(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      return;
    }

    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      _initialized = true;

      await DeviceTokenService.registerCurrentDevice();

      _messaging.onTokenRefresh.listen((token) async {
        await DeviceTokenService.registerCurrentDevice(token: token);
      });

      FirebaseMessaging.onMessage.listen((message) {
        _showForegroundMessage(navigatorKey, message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _openAppointments(navigatorKey);
      });

      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openAppointments(navigatorKey);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM non inizializzato: $e');
      }
    }
  }

  static bool get isInitialized => _initialized;

  static void _openAppointments(
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => const AppointmentsScreen(),
      ),
    );
  }

  static void _showForegroundMessage(
    GlobalKey<NavigatorState> navigatorKey,
    RemoteMessage message,
  ) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final notification = message.notification;
    final title = notification?.title ?? 'AF Beauty Art';
    final body = notification?.body ?? 'Hai ricevuto una nuova notifica.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(body),
          ],
        ),
      ),
    );
  }
}
