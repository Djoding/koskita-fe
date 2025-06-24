import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class OrderLaundryService {
  static const String _baseUrl = 'https://kost-kita.my.id/api/v1/order/laundry';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'accessToken';

  Future<String?> _getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
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

  Future<Map<String, dynamic>> createLaundryOrderWithPayment({
    required Map<String, dynamic> laundryData,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl);
      final String? accessToken = await _getAccessToken();

      if (accessToken == null) {
        throw Exception('Access token not found. Please log in.');
      }

      debugPrint(
        'DEBUG Flutter Service: Calling POST Catering Order: ${uri.toString()}',
      );
      debugPrint(
        'DEBUG Flutter Service: Request Body (JSON): ${jsonEncode(laundryData)}',
      );

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(laundryData),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error creating catering order with payment: $e');
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
