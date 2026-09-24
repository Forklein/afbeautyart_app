import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/customer.dart';
import 'storage_service.dart';

class AuthResult {
  final String? token;
  final Customer? customer;
  const AuthResult({this.token, this.customer});
}

class AuthService {
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    String phone = '',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
      }),
    );
    return _parse(response);
  }

  Future<void> requestCode({required String email}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/request-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    _throwIfError(response);
  }

  Future<AuthResult> verifyCode({
    required String email,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    final result = _parse(response);
    if (result.token != null && result.token!.isNotEmpty) {
      await StorageService.saveToken(result.token!);
    }
    return result;
  }

  Future<Customer> getMe() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) throw Exception('Token non trovato.');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      await StorageService.clearToken();
      throw Exception('Sessione scaduta.');
    }

    _throwIfError(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true || data['customer'] == null) {
      throw Exception(data['message'] ?? 'Impossibile recuperare il profilo.');
    }

    return Customer.fromJson(
      (data['customer'] as Map).cast<String, dynamic>(),
    );
  }

  Future<void> logout() => StorageService.clearToken();

  AuthResult _parse(http.Response response) {
    _throwIfError(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final c = data['customer'];
    return AuthResult(
      token: data['token']?.toString(),
      customer: c is Map
          ? Customer.fromJson(c.cast<String, dynamic>())
          : null,
    );
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Errore API: ${response.statusCode}';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        message = data['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }
}
