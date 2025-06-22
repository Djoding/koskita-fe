// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Sesuaikan dengan IP backend Anda
  static const String baseUrl = 'https://kost-kita.my.id/api/v1/';

  static String? token;

  static Future<Map<String, String>> get headers async {
    Map<String, String> header = {'Content-Type': 'application/json'};

    final prefs = await SharedPreferences.getInstance();
    final tokenShared = prefs.getString('token');

    if (tokenShared != null) {
      header['Authorization'] = 'Bearer $tokenShared';
    }

    return header;
  }

  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? query,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: query);
      final response = await http.get(uri, headers: await headers);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: await headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await headers,
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        errorBody['message'] ??
            'Request gagal dengan status: ${response.statusCode}',
      );
    }
  }
}
