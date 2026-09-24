import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/appointment.dart';
import '../models/availability.dart';
import 'storage_service.dart';

class AppointmentService {
  Future<String> _token() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) throw Exception('Token non trovato.');
    return token;
  }

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<List<Appointment>> getMyAppointments() async {
    final token = await _token();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/appointments'),
      headers: _headers(token),
    );

    if (response.statusCode == 401) {
      await StorageService.clearToken();
      throw Exception('Sessione scaduta.');
    }
    _check(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (data['appointments'] as List? ?? const []);
    return list.map((e) => Appointment.fromJson(
      (e as Map).cast<String, dynamic>(),
    )).toList();
  }

  Future<List<Availability>> getAvailability({
    required int serviceId,
    required int providerId,
    required String date,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/availability').replace(
      queryParameters: {
        'service_id': '$serviceId',
        'provider_id': '$providerId',
        'date': date,
      },
    );
    final response = await http.get(uri);
    _check(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (data['slots'] ?? data['availability'] ?? const []) as List;
    return list.map((e) {
      if (e is String) return Availability(date: date, time: e);
      return Availability.fromJson((e as Map).cast<String, dynamic>());
    }).toList();
  }

  Future<Map<String, dynamic>> createAppointment({
    required int serviceId,
    required int providerId,
    required String date,
    required String time,
  }) async {
    final token = await _token();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/appointments'),
      headers: _headers(token),
      body: jsonEncode({
        'service_id': serviceId,
        'provider_id': providerId,
        'date': date,
        'time': time,
      }),
    );

    if (response.statusCode == 401) {
      await StorageService.clearToken();
      throw Exception('Sessione scaduta.');
    }
    _check(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Prenotazione non riuscita.');
    }
    return data;
  }

  void _check(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      String message = 'Errore API: ${r.statusCode}';
      try {
        final data = jsonDecode(r.body) as Map<String, dynamic>;
        message = data['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }
}
