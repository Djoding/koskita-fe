import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //untuk device physical
  // static const String baseUrl = 'http://192.168.100.111:3000/api';
  static const String baseUrl = 'http://10.0.2.2:3000/api';

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
    // try {
    //   final uri = Uri.parse(
    //     '$baseUrl$endpoint',
    //   ).replace(queryParameters: query);
    //   final response = await http.get(uri, headers: await headers);
    //   return _processResponse(response);
    // } catch (e) {
    //   throw Exception('Terjadi kesalahan: $e');
    // }
    // --- OFFLINE MODE: return dummy data ---
    return {'status': true, 'data': [], 'message': 'Offline dummy get'};
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    // debugPrint("HEADER $headers");
    // try {
    //   final response = await http.post(
    //     Uri.parse('$baseUrl$endpoint'),
    //     headers: await headers,
    //     body: jsonEncode(body),
    //   );
    //   return _processResponse(response);
    // } catch (e) {
    //   throw Exception('Terjadi kesalahan: $e');
    // }
    // --- OFFLINE MODE: return dummy data ---
    return {'status': true, 'message': 'Offline dummy post'};
  }

  static Future<dynamic> put(String endpoint, Map<String, String> query) async {
    // try {
    //   final response = await http.put(
    //     Uri.parse('$baseUrl$endpoint'),
    //     headers: await headers,
    //   );
    //   return _processResponse(response);
    // } catch (e) {
    //   throw Exception('Terjadi kesalahan: $e');
    // }
    // --- OFFLINE MODE: return dummy data ---
    return {'status': true, 'message': 'Offline dummy put'};
  }

  static Future<dynamic> delete(String endpoint) async {
    // try {
    //   final response = await http.delete(
    //     Uri.parse('$baseUrl$endpoint'),
    //     headers: await headers,
    //   );
    //   return _processResponse(response);
    // } catch (e) {
    //   throw Exception('Terjadi kesalahan: $e');
    // }
    // --- OFFLINE MODE: return dummy data ---
    return {'status': true, 'message': 'Offline dummy delete'};
  }

  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 500) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Request gagal dengan status: ${response.statusCode}, message: ${response.body}',
      );
    }
  }
}
