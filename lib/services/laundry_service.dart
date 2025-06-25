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

  // Common response handler
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

  // Get laundries by kost ID
  static Future<Map<String, dynamic>> getLaundriesByKost(String kostId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/laundry?kost_id=$kostId'),
        headers: await _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error fetching laundries: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> createLaundry(
    Map<String, dynamic> laundryData,
    File? qrisImageFile,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/laundry'),
        headers: await _headers,
        body: jsonEncode(laundryData),
      );

      final result = _handleResponse(response);

      if (result['status'] && qrisImageFile != null) {
        final laundryId = result['data']['laundry_id'];
        if (laundryId != null) {
          await _uploadQrisImage(laundryId, qrisImageFile);
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error creating laundry: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Update laundry - Gunakan pendekatan yang sama
  static Future<Map<String, dynamic>> updateLaundry({
    required String laundryId,
    required String kostId,
    required String namalaundry,
    required String alamat,
    String? whatsappNumber,
    File? qrisImage,
    Map<String, dynamic>? rekeningInfo,
    bool? isPartner,
    String?
    existingQrisImageUrl, // Added to handle existing image without re-upload
  }) async {
    debugPrint('Attempting to update laundry (frontend call)');
    debugPrint('laundry ID: $laundryId');
    debugPrint('Nama laundry: $namalaundry');
    debugPrint('Existing QRIS URL: $existingQrisImageUrl');
    debugPrint('New QRIS File: ${qrisImage?.path}');

    try {
      String? finalQrisImageUrl = existingQrisImageUrl;
      if (qrisImage != null) {
        // Only upload if a new file is provided
        try {
          // Upload the QRIS image first and get the URL
          await _uploadQrisImage(laundryId, qrisImage);
          // After successful upload, we'll use the existing URL in the response
          // The backend should handle storing and returning the image URL
        } catch (e) {
          throw Exception('Failed to upload QRIS image: $e');
        }
      }

      final Map<String, dynamic> body = {
        'kost_id':
            kostId, // Include kost_id, though typically not changed for update
        'nama_laundry': namalaundry,
        'alamat': alamat,
        'whatsapp_number': whatsappNumber,
        'qris_image': finalQrisImageUrl, // Send the final URL
        'rekening_info': rekeningInfo,
        'is_partner': isPartner,
      };

      // NOTE: There is no backend PUT/PATCH endpoint for `/laundry/:id` in the provided backend code.
      // This call will likely fail until that endpoint is implemented on the backend.
      final response = await http.put(
        // Using PUT as an assumption for update
        Uri.parse(
          '$_baseUrl/laundry/$laundryId',
        ), // Assuming this endpoint for update
        headers: await _headers,
        body: jsonEncode(body),
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
        throw Exception(
          'Backend Error: ${errorData['message'] ?? 'Failed to update laundry'}',
        );
      }
    } catch (e) {
      debugPrint('Error updating laundry: $e');
      // Explicitly state that backend endpoint might be missing
      return {
        'status': false,
        'message':
            'Failed to update laundry. Ensure backend endpoint for updating laundry exists and is correctly implemented. Error: $e',
      };
    }
  }

  // Helper method to upload/update QRIS image
  static Future<void> _uploadQrisImage(
    String laundryId,
    File qrisImageFile,
  ) async {
    try {
      final request = http.MultipartRequest(
        'PUT', // Use PUT for updating an existing resource
        Uri.parse(
          '$_baseUrl/laundry/$laundryId',
        ), // Endpoint to update specific laundry
      );

      // Add headers
      final headers = await _multipartHeaders;
      request.headers.addAll(headers);

      // Add QRIS image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'qris_image', // Field name for the image in the backend
          qrisImageFile.path,
          contentType: MediaType(
            'image',
            'jpeg',
          ), // Adjust content type if needed
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        debugPrint('Failed to upload/update QRIS image: ${response.body}');
        throw Exception('Failed to upload/update QRIS image: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error uploading/updating QRIS image: $e');
      throw e; // Re-throw to be caught by the calling function
    }
  }

  // Delete laundry (soft delete)
  static Future<Map<String, dynamic>> deleteLaundry(String laundryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/laundry/$laundryId'),
        headers: await _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error deleting laundry: $e');
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

      return _handleResponse(response);
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

      return _handleResponse(response);
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

      return _handleResponse(response);
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

      return _handleResponse(response);
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

      return _handleResponse(response);
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

      return _handleResponse(response);
    } catch (e) {
      debugPrint('=== ERROR IN GET ORDER DETAIL ===');
      debugPrint('Error: $e');

      return {'status': false, 'message': 'Gagal terhubung ke server: $e'};
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

      return _handleResponse(response);
    } catch (e) {
      debugPrint('=== ERROR IN UPDATE STATUS ===');
      debugPrint('Error: $e');

      return {'status': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // Get available layanan
  static Future<Map<String, dynamic>> getAvailableLayanan() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/master/layanan-laundry'),
        headers: await _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error fetching layanan: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }
}
