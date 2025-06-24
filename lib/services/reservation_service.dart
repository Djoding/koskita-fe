import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class ReservationService {
  static const String _baseUrl = 'https://kost-kita.my.id/api/v1/reservasi';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'accessToken';

  Future<Map<String, dynamic>> getReservations({
    String? userId,
    String? status,
    String? kostId,
  }) async {
    final String? token = await _getAccessToken();

    if (token == null) {
      debugPrint('No access token found. User might not be logged in.');
      throw Exception('Unauthorized. Please log in.');
    }

    Uri requestUri = Uri.parse('$_baseUrl/penghuni');

    final Map<String, dynamic> queryParams = {};
    if (userId != null) {
      queryParams['userId'] = userId;
    }
    if (status != null) {
      queryParams['status'] = status;
    }
    if (kostId != null) {
      queryParams['kostId'] = kostId;
    }

    if (queryParams.isNotEmpty) {
      requestUri = requestUri.replace(queryParameters: queryParams);
    }

    debugPrint('Calling GET Reservations: ${requestUri.toString()}');

    try {
      final response = await http.get(
        requestUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error getting reservations: $e");
      throw Exception(
        'Failed to connect to the server or retrieve reservations: $e',
      );
    }
  }

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
      throw Exception(
        errorBody['message'] ??
            'API call failed with status: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> getReservationsByKostAndUser(
    String kostId,
  ) async {
    final String? token = await _getAccessToken();

    if (token == null) {
      debugPrint('No access token found. User might not be logged in.');
      throw Exception('Unauthorized. Please log in.');
    }

    final Uri requestUri = Uri.parse('$_baseUrl/$kostId');

    debugPrint(
      'Calling GET Reservations by Kost and User: ${requestUri.toString()}',
    );

    try {
      final response = await http.get(
        requestUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error getting reservations by kost and user: $e");
      throw Exception(
        'Failed to connect to the server or retrieve reservations: $e',
      );
    }
  }

  Future<Map<String, dynamic>> getReservationDetailById(
    String reservasiId,
  ) async {
    final String? token = await _getAccessToken();

    if (token == null) {
      debugPrint('No access token found. User might not be logged in.');
      throw Exception('Unauthorized. Please log in.');
    }

    final Uri requestUri = Uri.parse('$_baseUrl/detail/$reservasiId');

    debugPrint(
      'Calling GET Reservation Detail by ID: ${requestUri.toString()}',
    );

    try {
      final response = await http.get(
        requestUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error getting reservation detail: $e");
      throw Exception(
        'Failed to connect to the server or retrieve reservation detail: $e',
      );
    }
  }

  Future<Map<String, dynamic>> extendReservation({
    required String reservasiId,
    required Map<String, dynamic> formData,
  }) async {
    final String? token = await _getAccessToken();

    if (token == null) {
      debugPrint('No access token found. User might not be logged in.');
      throw Exception('Unauthorized. Please log in.');
    }

    final Uri requestUri = Uri.parse('$_baseUrl/$reservasiId/extend');

    final http.Response response;
    try {
      debugPrint('Calling PUT Extend Reservation: ${requestUri.toString()}');
      debugPrint('Request Body (JSON): ${jsonEncode(formData)}');

      response = await http.put(
        requestUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(formData),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error extending reservation: $e");
      throw Exception(
        'Failed to connect to the server or extend reservation: $e',
      );
    }
  }

  Future<Map<String, dynamic>> createReservation(
    Map<String, dynamic> formData,
  ) async {
    try {
      final String? token = await _getAccessToken();

      if (token == null) {
        debugPrint('No access token found. User might not be logged in.');
        throw Exception('Unauthorized. Please log in.');
      }
      debugPrint('Calling POST Create Reservation: $_baseUrl');
      debugPrint('Request Body (JSON): ${jsonEncode(formData)}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(formData),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error creating reservation: $e');
      return {'status': false, 'message': 'Failed to create reservation: $e'};
    }
  }
}
