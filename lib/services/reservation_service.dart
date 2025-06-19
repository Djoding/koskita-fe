import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ReservationService {
  static const String _baseUrl = 'http://localhost:3000/api/v1/reservasi';
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

  MediaType _getMediaTypeForFile(File file) {
    final String extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return {
        'status': true,
        'data': responseBody['data'],
        'message': responseBody['message'],
      };
    } else if (response.statusCode == 401) {
      debugPrint('Unauthorized: Token might be expired or invalid.');
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
    required int durasiPerpanjanganBulan,
    required String metodeBayar,
    String? catatan,
    required File buktiBayarFile,
  }) async {
    final String? token = await _getAccessToken();

    if (token == null) {
      debugPrint('No access token found. User might not be logged in.');
      throw Exception('Unauthorized. Please log in.');
    }

    final Uri requestUri = Uri.parse('$_baseUrl/$reservasiId/extend');

    final http.MultipartRequest request = http.MultipartRequest(
      'PUT',
      requestUri,
    );
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['durasi_perpanjangan_bulan'] =
        durasiPerpanjanganBulan.toString();
    request.fields['metode_bayar'] = metodeBayar;
    if (catatan != null) {
      request.fields['catatan'] = catatan;
    }

    final MediaType contentType = _getMediaTypeForFile(buktiBayarFile);
    request.files.add(
      await http.MultipartFile.fromPath(
        'bukti_bayar',
        buktiBayarFile.path,
        filename: buktiBayarFile.path.split('/').last,
        contentType: contentType,
      ),
    );

    try {
      final http.StreamedResponse streamedResponse = await request.send();
      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error extending reservation: $e");
      throw Exception(
        'Failed to connect to the server or extend reservation: $e',
      );
    }
  }
}
