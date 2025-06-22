// lib/services/reservasi_management_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ReservasiManagementService {
  static const String _baseUrl = 'https://kost-kita.my.id/api/v1/reservasi';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Headers dengan token
  static Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all reservations by kost ID (for pengelola)
  static Future<Map<String, dynamic>> getReservasiByKost(String kostId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pengelola/$kostId'),
        headers: await _headers,
      );

      debugPrint('GET Reservasi by Kost - URL: $_baseUrl/pengelola/$kostId');
      debugPrint('GET Reservasi by Kost - Status: ${response.statusCode}');
      debugPrint('GET Reservasi by Kost - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch reservations');
      }
    } catch (e) {
      debugPrint('Error fetching reservations by kost: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Get reservation detail by ID - FIXED ENDPOINT
  static Future<Map<String, dynamic>> getReservasiDetail(
    String reservasiId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/detail/$reservasiId'), // Updated endpoint
        headers: await _headers,
      );

      debugPrint('GET Reservasi Detail - URL: $_baseUrl/detail/$reservasiId');
      debugPrint('GET Reservasi Detail - Status: ${response.statusCode}');
      debugPrint('GET Reservasi Detail - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch reservation detail',
        );
      }
    } catch (e) {
      debugPrint('Error fetching reservation detail: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Update reservation status (approve/reject)
  static Future<Map<String, dynamic>> updateReservasiStatus(
    String reservasiId, {
    required String status, // 'APPROVED' or 'REJECTED'
    String? rejectionReason,
  }) async {
    try {
      final Map<String, dynamic> body = {'status': status};
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        body['rejection_reason'] = rejectionReason;
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/$reservasiId/status'),
        headers: await _headers,
        body: jsonEncode(body),
      );

      debugPrint('PATCH Update Status - URL: $_baseUrl/$reservasiId/status');
      debugPrint('PATCH Update Status - Status: ${response.statusCode}');
      debugPrint('PATCH Update Status - Body: ${jsonEncode(body)}');
      debugPrint('PATCH Update Status - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to update reservation status',
        );
      }
    } catch (e) {
      debugPrint('Error updating reservation status: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }
}
