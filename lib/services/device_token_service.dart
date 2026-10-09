
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'storage_service.dart';

class DeviceTokenService {
  DeviceTokenService._();

  static String? get _platformName {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return null;
    }
  }

  static Future<void> registerCurrentDevice({String? token}) async {
    final authToken = await StorageService.getToken();
    if (authToken == null || authToken.isEmpty) return;

    final platform = _platformName;
    if (platform == null) return;

    try {
      final fcmToken =
          token ?? await FirebaseMessaging.instance.getToken();

      if (fcmToken == null || fcmToken.isEmpty) return;

      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/notifications/device-token',
        ),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': fcmToken,
          'platform': platform,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Registrazione dispositivo fallita: '
          '${response.statusCode} ${response.body}',
        );
      }

      if (kDebugMode) {
        debugPrint('AFBA: dispositivo registrato correttamente.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AFBA: errore registrazione dispositivo: $e');
      }
    }
  }

  static Future<void> unregisterCurrentDevice() async {
    final authToken = await StorageService.getToken();
    if (authToken == null || authToken.isEmpty) return;

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      final response = await http.delete(
        Uri.parse(
          '${ApiConfig.baseUrl}/notifications/device-token',
        ),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': fcmToken}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Disattivazione dispositivo fallita: '
          '${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AFBA: errore disattivazione dispositivo: $e');
      }
    }
  }
}
