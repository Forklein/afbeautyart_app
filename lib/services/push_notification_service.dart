import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/appointments/appointments_screen.dart';

/// Gestisce Firebase Cloud Messaging lato app.
///
/// Nota: il backend deve registrare il token FCM associato al customer e
/// inviare la notifica quando lo stato della prenotazione cambia.
class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    // Firebase Messaging non viene inizializzato durante i test Windows.
    // L'app continua quindi a funzionare normalmente su Windows.
    if (defaultTargetPlatform == TargetPlatform.windows) return;

    try {
      await Firebase.initializeApp();

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

      // Il token va registrato sul backend associandolo al customer autenticato.
      // Per ora lo stampiamo in debug: il prossimo passaggio è collegarlo
      // all'endpoint WordPress dedicato ai device token.
      final token = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('AFBA FCM TOKEN: $token');
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          debugPrint('AFBA FCM TOKEN REFRESH: $newToken');
        }
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
      // Le notifiche non devono impedire l'avvio dell'app.
      if (kDebugMode) {
        debugPrint('FCM non inizializzato: $e');
      }
    }
  }

  static bool get isInitialized => _initialized;

  static void _openAppointments(GlobalKey<NavigatorState> navigatorKey) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    // Importante: qui non facciamo push automatici di route se l'utente non è
    // autenticato. In caso contrario la schermata di prenotazioni è il punto
    // naturale da aprire dopo il tap sulla notifica.
    navigator.push(
      MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(body),
          ],
        ),
      ),
    );
  }
}
