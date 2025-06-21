import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class LaundryService {
  static const String _baseUrl = 'http://localhost:3000/api/v1';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> get _multipartHeaders async {
    final token = await _storage.read(key: 'accessToken');
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

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

  static Future<Map<String, dynamic>> createLaundry(
    Map<String, dynamic> laundryData,
    File? qrisImageFile,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/laundry'),
      );

      // Add headers
      final headers = await _multipartHeaders;
      request.headers.addAll(headers);

      request.fields.addAll({
        'kost_id': laundryData['kost_id'],
        'nama_laundry': laundryData['nama_laundry'],
        'alamat': laundryData['alamat'],
        if (laundryData['whatsapp_number'] != null)
          'whatsapp_number': laundryData['whatsapp_number'],
        if (laundryData['rekening_info'] != null)
          'rekening_info': jsonEncode(laundryData['rekening_info']),
        'is_partner': laundryData['is_partner']?.toString() ?? 'false',
      });

      if (qrisImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'qris_image',
            qrisImageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
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
  static Future<Map<String, dynamic>> getLaundryOrders(
    String kostId, {
    String? status,
    String? laundryId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (laundryId != null) queryParams['laundry_id'] = laundryId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse(
        '$_baseUrl/owner/kosts/$kostId/laundry-orders',
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
        throw Exception(errorData['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getAllLaundryOrders({
    String? status,
    String? laundryId,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (laundryId != null) queryParams['laundry_id'] = laundryId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse(
        '$_baseUrl/laundry/orders',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'pagination': data['pagination'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch all orders');
      }
    } catch (e) {
      debugPrint('Error fetching all orders: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getLaundryOrderById(
    String orderId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/laundry/orders/$orderId'),
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
        throw Exception(errorData['message'] ?? 'Failed to fetch order detail');
      }
    } catch (e) {
      debugPrint('Error fetching order detail: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateLaundryOrderStatus(
    String orderId,
    Map<String, dynamic> statusData,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/laundry/orders/$orderId/status'),
        headers: await _headers,
        body: jsonEncode(statusData),
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
          errorData['message'] ?? 'Failed to update order status',
        );
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // DEPRECATED: Get laundry order detail (gunakan getLaundryOrderById)
  @deprecated
  static Future<Map<String, dynamic>> getLaundryOrderDetail(
    String orderId,
  ) async {
    return await getLaundryOrderById(orderId);
  }

  // DEPRECATED: Update order status (gunakan updateLaundryOrderStatus)
  @deprecated
  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    Map<String, dynamic> statusData,
  ) async {
    return await updateLaundryOrderStatus(orderId, statusData);
  }

  // Get master layanan laundry
  static Future<Map<String, dynamic>> getMasterLayananLaundry() async {
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
        throw Exception(
          errorData['message'] ?? 'Failed to fetch master layanan',
        );
      }
    } catch (e) {
      debugPrint('Error fetching master layanan: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  // Get available layanan untuk owner
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

  // Update laundry
  static Future<Map<String, dynamic>> updateLaundry(
    String laundryId,
    Map<String, dynamic> laundryData,
    File? qrisImageFile,
  ) async {
    try {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseUrl/laundry/$laundryId'),
      );

      // Add headers
      final headers = await _multipartHeaders;
      request.headers.addAll(headers);

      // Add fields
      if (laundryData['nama_laundry'] != null) {
        request.fields['nama_laundry'] = laundryData['nama_laundry'];
      }
      if (laundryData['alamat'] != null) {
        request.fields['alamat'] = laundryData['alamat'];
      }
      if (laundryData['whatsapp_number'] != null) {
        request.fields['whatsapp_number'] = laundryData['whatsapp_number'];
      }
      if (laundryData['rekening_info'] != null) {
        request.fields['rekening_info'] = jsonEncode(
          laundryData['rekening_info'],
        );
      }
      if (laundryData['is_partner'] != null) {
        request.fields['is_partner'] = laundryData['is_partner'].toString();
      }

      // Add QRIS image if provided
      if (qrisImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'qris_image',
            qrisImageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update laundry');
      }
    } catch (e) {
      debugPrint('Error updating laundry: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // Delete laundry
  static Future<Map<String, dynamic>> deleteLaundry(String laundryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/laundry/$laundryId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'status': true, 'message': data['message']};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete laundry');
      }
    } catch (e) {
      debugPrint('Error deleting laundry: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }
}
