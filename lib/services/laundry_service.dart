// lib/services/laundry_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class LaundryService {
  static const String _baseUrl = 'https://kost-kita.my.id/api/v1';
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

  // Get laundries by kost ID
  static Future<Map<String, dynamic>> getLaundriesByKost(String kostId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/laundry?kost_id=$kostId'),
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
        throw Exception(errorData['message'] ?? 'Failed to fetch laundries');
      }
    } catch (e) {
      debugPrint('Error fetching laundries: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  // PERBAIKAN: Create laundry dengan dua langkah - JSON request dulu, lalu upload gambar
  static Future<Map<String, dynamic>> createLaundry(
    Map<String, dynamic> laundryData,
    File? qrisImageFile,
  ) async {
    try {
      // LANGKAH 1: Buat laundry tanpa gambar menggunakan JSON request
      debugPrint('=== SENDING JSON DATA ===');
      debugPrint('Data: $laundryData');

      final response = await http.post(
        Uri.parse('$_baseUrl/laundry'),
        headers: await _headers,
        body: jsonEncode(laundryData),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final laundryId = data['data']['laundry_id'];

        // LANGKAH 2: Upload gambar QRIS jika ada
        if (qrisImageFile != null && laundryId != null) {
          await _uploadQrisImage(laundryId, qrisImageFile);
        }

        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create laundry');
      }
    } catch (e) {
      debugPrint('Error creating laundry: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Helper method untuk upload QRIS image
  static Future<void> _uploadQrisImage(
    String laundryId,
    File qrisImageFile,
  ) async {
    try {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseUrl/laundry/$laundryId'),
      );

      // Add headers
      final headers = await _multipartHeaders;
      request.headers.addAll(headers);

      // Tambahkan gambar QRIS
      request.files.add(
        await http.MultipartFile.fromPath(
          'qris_image',
          qrisImageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        debugPrint('Failed to upload QRIS image: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error uploading QRIS image: $e');
    }
  }

  // Update laundry - Gunakan pendekatan yang sama
  static Future<Map<String, dynamic>> updateLaundry(
    String laundryId,
    Map<String, dynamic> laundryData,
    File? qrisImageFile,
  ) async {
    try {
      // LANGKAH 1: Update data laundry menggunakan JSON request
      if (laundryData.isNotEmpty) {
        final response = await http.put(
          Uri.parse('$_baseUrl/laundry/$laundryId'),
          headers: await _headers,
          body: jsonEncode(laundryData),
        );

        if (response.statusCode != 200) {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to update laundry');
        }
      }

      // LANGKAH 2: Upload gambar QRIS jika ada
      if (qrisImageFile != null) {
        await _uploadQrisImage(laundryId, qrisImageFile);
      }

      // Get updated data
      final getResponse = await http.get(
        Uri.parse('$_baseUrl/laundry/$laundryId'),
        headers: await _headers,
      );

      if (getResponse.statusCode == 200) {
        final data = jsonDecode(getResponse.body);
        return {
          'status': true,
          'data': data['data'],
          'message': 'Laundry updated successfully',
        };
      } else {
        return {'status': true, 'message': 'Laundry updated successfully'};
      }
    } catch (e) {
      debugPrint('Error updating laundry: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Get laundry services
  static Future<Map<String, dynamic>> getLaundryServices(
    String laundryId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/laundry/$laundryId/services'),
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
        throw Exception(errorData['message'] ?? 'Failed to fetch services');
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Create laundry service
  static Future<Map<String, dynamic>> createLaundryService(
    String laundryId,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/laundry/$laundryId/services'),
        headers: await _headers,
        body: jsonEncode(serviceData),
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
        throw Exception(errorData['message'] ?? 'Failed to create service');
      }
    } catch (e) {
      debugPrint('Error creating service: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Update laundry service
  static Future<Map<String, dynamic>> updateLaundryService(
    String laundryId,
    String layananId,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/laundry/$laundryId/services/$layananId'),
        headers: await _headers,
        body: jsonEncode(serviceData),
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
        throw Exception(errorData['message'] ?? 'Failed to update service');
      }
    } catch (e) {
      debugPrint('Error updating service: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Delete laundry service
  static Future<Map<String, dynamic>> deleteLaundryService(
    String laundryId,
    String layananId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/laundry/$laundryId/services/$layananId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'status': true, 'message': data['message']};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete service');
      }
    } catch (e) {
      debugPrint('Error deleting service: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Get laundry orders
  static Future<Map<String, dynamic>> getLaundryOrdersByKost({
    required String kostId,
    String? status,
    String? laundryId,
  }) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final queryParams = <String, String>{};

      if (kostId.isNotEmpty) {
        queryParams['kost_id'] = kostId;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (laundryId != null && laundryId.isNotEmpty) {
        queryParams['laundry_id'] = laundryId;
      }

      final uri = Uri.parse(
        '$_baseUrl/laundry/orders',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'data': data['data'] ?? [],
          'message': data['message'] ?? 'Success',
        };
      } else {
        return {
          'status': false,
          'message': data['message'] ?? 'Failed to fetch orders',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  // Get laundry order detail
  static Future<Map<String, dynamic>> getLaundryOrderDetail(
    String orderId,
  ) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/laundry/orders/$orderId'),
        headers: headers,
      );

      debugPrint('=== GET ORDER DETAIL DEBUG ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Response kosong dari server'};
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      bool isSuccess = false;
      String message = '';
      dynamic data;

      if (response.statusCode == 200) {
        if (responseData.containsKey('status')) {
          isSuccess =
              responseData['status'] == true ||
              responseData['status'] == 'true' ||
              responseData['status'] == 'success';
        } else if (responseData.containsKey('success')) {
          isSuccess =
              responseData['success'] == true ||
              responseData['success'] == 'true';
        } else {
          isSuccess = true;
        }

        message = responseData['message']?.toString() ?? 'Data berhasil dimuat';
        data = responseData['data'] ?? responseData;
      } else {
        isSuccess = false;
        message = responseData['message']?.toString() ?? 'Gagal memuat data';
      }

      return {'success': isSuccess, 'message': message, 'data': data};
    } catch (e) {
      debugPrint('=== ERROR IN GET ORDER DETAIL ===');
      debugPrint('Error: $e');

      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // Update laundry order status
  static Future<Map<String, dynamic>> updateLaundryOrderStatus(
    String orderId,
    Map<String, dynamic> statusData,
  ) async {
    try {
      final headers = await _headers;
      final response = await http.patch(
        Uri.parse('$_baseUrl/laundry/orders/$orderId/status'),
        headers: headers,
        body: json.encode(statusData),
      );

      debugPrint('=== UPDATE STATUS DEBUG ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true, 'message': 'Status berhasil diperbarui'};
        } else {
          return {
            'success': false,
            'message': 'Gagal memperbarui status (${response.statusCode})',
          };
        }
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      bool isSuccess = false;
      String message = '';

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData.containsKey('status')) {
          isSuccess =
              responseData['status'] == true ||
              responseData['status'] == 'true' ||
              responseData['status'] == 'success';
        } else if (responseData.containsKey('success')) {
          isSuccess =
              responseData['success'] == true ||
              responseData['success'] == 'true';
        } else {
          isSuccess = true;
        }

        message =
            responseData['message']?.toString() ?? 'Status berhasil diperbarui';
      } else {
        isSuccess = false;
        message =
            responseData['message']?.toString() ?? 'Gagal memperbarui status';
      }

      return {
        'success': isSuccess,
        'message': message,
        'data': responseData['data'],
      };
    } catch (e) {
      debugPrint('=== ERROR IN UPDATE STATUS ===');
      debugPrint('Error: $e');

      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // Get available layanan
  static Future<Map<String, dynamic>> getAvailableLayanan() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/master/layanan-laundry'),
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
        throw Exception(errorData['message'] ?? 'Failed to fetch layanan');
      }
    } catch (e) {
      debugPrint('Error fetching layanan: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }
}
