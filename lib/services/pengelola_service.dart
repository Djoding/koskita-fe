import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

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

  // Create new kost
  static Future<Map<String, dynamic>> createKost(
    Map<String, dynamic> formData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/kost'),
        headers: await _headers,
        body: jsonEncode({
          ...formData,
          'is_approved': true,
        }), // Langsung kirim formData tanpa mapping ulang
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
    Map<String, dynamic> kostData, {
    List<String>? existingFotoKost,
    List<File>? newFotoKost,
    String? existingFotoQris,
    File? newFotoQris,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_baseUrl/kost/$kostId'),
      );

      // Add headers
      final headers = await _headers;
      request.headers.addAll(headers);

      // Add basic kost data
      kostData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add existing foto kost as JSON
      if (existingFotoKost != null) {
        request.fields['existing_foto_kost'] = jsonEncode(existingFotoKost);
      }

      // Add existing foto qris
      if (existingFotoQris != null && existingFotoQris.isNotEmpty) {
        request.fields['existing_qris_image'] = existingFotoQris;
      }

      // Add new foto kost files
      if (newFotoKost != null && newFotoKost.isNotEmpty) {
        for (int i = 0; i < newFotoKost.length; i++) {
          var file = await http.MultipartFile.fromPath(
            'new_foto_kost[]',
            newFotoKost[i].path,
          );
          request.files.add(file);
        }
      }

      // Add new foto qris file
      if (newFotoQris != null) {
        var qrisFile = await http.MultipartFile.fromPath(
          'new_qris_image',
          newFotoQris.path,
        );
        request.files.add(qrisFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Update Kost Status Code: ${response.statusCode}');
      debugPrint('Update Kost Response: ${response.body}');

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

  // Delete kost (admin only)
  static Future<Map<String, dynamic>> deleteKost(String kostId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/kost/$kostId'),
        headers: await _headers,
      );

      debugPrint('Delete Kost Status Code: ${response.statusCode}');
      debugPrint('Delete Kost Response: ${response.body}');

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

  // Helper methods
  static String _buildDescription(Map<String, dynamic> formData) {
    final List<String> descriptions = [];

    if (formData['fasilitasKamar'] != null) {
      descriptions.add('Fasilitas Kamar: ${formData['fasilitasKamar']}');
    }
    if (formData['fasilitasKamarMandi'] != null) {
      descriptions.add(
        'Fasilitas Kamar Mandi: ${formData['fasilitasKamarMandi']}',
      );
    }
    if (formData['kebijakanProperti'] != null) {
      descriptions.add('Kebijakan Properti: ${formData['kebijakanProperti']}');
    }
    if (formData['deskripsiProperti'] != null) {
      descriptions.add('Deskripsi: ${formData['deskripsiProperti']}');
    }
    if (formData['informasiJarak'] != null) {
      descriptions.add('Informasi Jarak: ${formData['informasiJarak']}');
    }

    return descriptions.join('\n\n');
  }

  static double _parsePrice(dynamic price) {
    if (price is String) {
      // Remove non-numeric characters except decimal point
      final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanPrice) ?? 0.0;
    }
    if (price is num) {
      return price.toDouble();
    }
    return 0.0;
  }
}
