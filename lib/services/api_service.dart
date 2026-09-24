import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/employee.dart';
import '../models/service.dart';

class ApiService {
  Future<List<Service>> getServices() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/services'),
    );
    _check(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (data['services'] as List? ?? const []);
    return list.map((e) => Service.fromJson(
      (e as Map).cast<String, dynamic>(),
    )).toList();
  }

  Future<List<Employee>> getEmployees() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/employees'),
    );
    _check(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (data['employees'] as List? ?? const []);
    return list.map((e) => Employee.fromJson(
      (e as Map).cast<String, dynamic>(),
    )).toList();
  }

  void _check(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('Errore API: ${r.statusCode} ${r.body}');
    }
  }
}
