import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KostService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'accessToken';

  static const String _baseUrl = 'https://kost-kita.my.id/api/v1/kost';

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

  Future<String?> _getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<Map<String, dynamic>> getKostById(String kostId) async {
    try {
      final String? token = await _getAccessToken();

      if (token == null) {
        debugPrint('No access token found. User might not be logged in.');
        throw Exception('Unauthorized. Please log in.');
      }

      final url = Uri.parse('$_baseUrl/$kostId');

      debugPrint('Calling GET Kost by ID: ${url.toString()}');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error getting kost by ID ($kostId): $e");
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAllKost({String? namaKost}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (namaKost != null && namaKost.isNotEmpty) {
        queryParams['nama_kost'] = namaKost;
      }

      Uri url = Uri.parse(_baseUrl);
      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      debugPrint('Calling GET All Kost: ${url.toString()}');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error getting all kost: $e");
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getKostTamuById(String kostId) async {
    try {

      final url = Uri.parse('$_baseUrl/$kostId/tamu');

      debugPrint('Calling GET Kost by ID: ${url.toString()}');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error getting kost by ID ($kostId): $e");
      return {'status': false, 'message': e.toString()};
    }
  }
}
