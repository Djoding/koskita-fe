// lib/services/pengelola_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class PengelolaService {
  static const String _baseUrl = 'http://localhost:3000/api/v1';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Headers dengan token
  static Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Headers untuk multipart (tanpa Content-Type)
  static Future<Map<String, String>> get _multipartHeaders async {
    final token = await _storage.read(key: 'accessToken');
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  // Get all kost by owner (pengelola)
  static Future<Map<String, dynamic>> getKostByOwner({String? namaKost}) async {
    try {
      final Map<String, String> queryParams = {};
      if (namaKost != null && namaKost.isNotEmpty) {
        queryParams['nama_kost'] = namaKost;
      }

      final uri = Uri.parse(
        '$_baseUrl/kost/owner',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch kost data');
      }
    } catch (e) {
      debugPrint('Error fetching kost by owner: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  // Get kost detail by ID
  static Future<Map<String, dynamic>> getKostById(String kostId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/kost/$kostId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch kost detail');
      }
    } catch (e) {
      debugPrint('Error fetching kost detail: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Get master data
  static Future<Map<String, dynamic>> getTipeKamar() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/master/tipe-kamar'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch tipe kamar');
      }
    } catch (e) {
      debugPrint('Error fetching tipe kamar: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getFasilitas() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/master/fasilitas'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch fasilitas');
      }
    } catch (e) {
      debugPrint('Error fetching fasilitas: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getPeraturan() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/master/peraturan'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch peraturan');
      }
    } catch (e) {
      debugPrint('Error fetching peraturan: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  // Create new kost
  static Future<Map<String, dynamic>> createKost(
    Map<String, dynamic> formData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/kost'),
        headers: await _headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create kost');
      }
    } catch (e) {
      debugPrint('Error creating kost: $e');
      return {'status': false, 'message': 'Failed to create kost: $e'};
    }
  }

  // Update kost
  static Future<Map<String, dynamic>> updateKost(
    String kostId,
    Map<String, dynamic> kostData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/kost/$kostId'),
        headers: await _headers,
        body: jsonEncode(kostData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'] ?? 'Kost berhasil diperbarui',
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update kost');
      }
    } catch (e) {
      debugPrint('Error updating kost: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Delete kost (soft delete)
  static Future<Map<String, dynamic>> deleteKost(String kostId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/kost/$kostId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'message': data['message'] ?? 'Kost berhasil dihapus',
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete kost');
      }
    } catch (e) {
      debugPrint('Error deleting kost: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }
}
