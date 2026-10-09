
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class DeviceTokenService {
  DeviceTokenService._();

  static Future<void> registerCurrentDevice() async {
    final authToken = await StorageService.getToken();
    if (authToken == null || authToken.isEmpty) return;

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/device-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': fcmToken,
          'platform': 'ios',
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Registrazione dispositivo fallita: ${response.statusCode}');
      }
    } catch (_) {
      // La registrazione del token non deve impedire l'accesso all'app.
    }
  }

  static Future<void> unregisterCurrentDevice() async {
    final authToken = await StorageService.getToken();
    if (authToken == null || authToken.isEmpty) return;

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/notifications/device-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': fcmToken}),
      );
    } catch (_) {}
  }
}
