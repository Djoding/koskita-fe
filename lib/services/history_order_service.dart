import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrderHistoryService {
  static const String _baseUrl = 'https://kost-kita.my.id/api/v1/history';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'accessToken';

  static Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: _accessTokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return {
        'status': true,
        'data': responseBody['data'] ?? {},
        'message': responseBody['message'] ?? 'Success',
      };
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      final errorBody = jsonDecode(response.body);
      debugPrint('Backend Error Response Body: ${jsonEncode(errorBody)}');
      if (errorBody['status'] == 'fail' || errorBody['status'] == 'error') {
        throw Exception(
          errorBody['message'] ??
              'API call failed with status: ${response.statusCode}',
        );
      }
      throw Exception(
        errorBody['message'] ??
            'API call failed with status: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> getReservationDetail(String reservasiId) async {
    try {
      final uri = Uri.parse('$_baseUrl/reservations/$reservasiId');
      final response = await http.get(uri, headers: await _headers);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error fetching reservation detail: $e');
      if (e is SocketException) {
        throw Exception('No internet connection. Please check your network.');
      }
      if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
