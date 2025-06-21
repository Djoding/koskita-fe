// lib/services/laundry_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class LaundryService {
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

  static Map<String, dynamic> _formatOrderData(Map<String, dynamic> rawData) {
    return {
      'order_id': rawData['pesanan_id'],
      'user_id': rawData['user_id'],
      'laundry_id': rawData['laundry_id'],
      'reservasi_id': rawData['reservasi_id'],
      'total_estimasi': rawData['total_estimasi'],
      'total_final': rawData['total_final'],
      'total_amount':
          rawData['total_final'] ?? rawData['total_estimasi'], // fallback
      'berat_actual': rawData['berat_actual'],
      'tanggal_antar': rawData['tanggal_antar'],
      'estimasi_selesai': rawData['estimasi_selesais'],
      'pickup_datetime': rawData['tanggal_antar'],
      'delivery_datetime': rawData['estimasi_selesai'],
      'status': rawData['status'],
      'catatan': rawData['catatan'],
      'notes': rawData['catatan'],
      'created_at': rawData['created_at'],
      'updated_at': rawData['updated_at'],
      // Data user
      'user': rawData['user'] ?? {},
      // Data laundry
      'laundry': rawData['laundry'] ?? {},
      // Detail pesanan
      'items': rawData['detail_pesanan_laundry'] ?? [],
      // Pembayaran
      'payment':
          rawData['pembayaran_laundry']?.isNotEmpty == true
              ? rawData['pembayaran_laundry'][0]
              : null,
      'payment_method':
          rawData['pembayaran_laundry']?.isNotEmpty == true
              ? rawData['pembayaran_laundry'][0]['metode']
              : null,
      'payment_proof':
          rawData['pembayaran_laundry']?.isNotEmpty == true
              ? rawData['pembayaran_laundry'][0]['bukti_bayar']
              : null,
    };
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

  // Create laundry
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

      // Add fields
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

      final queryParams = <String, String>{'kost_id': kostId};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (laundryId != null && laundryId.isNotEmpty) {
        queryParams['laundry_id'] = laundryId;
      }

      final uri = Uri.parse(
        '$_baseUrl/laundry/orders',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Format data untuk konsistensi
        final orders =
            (data['data'] as List?)?.map((order) {
              return _formatOrderData(order);
            }).toList() ??
            [];

        return {
          'status': true,
          'data': orders,
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

  static Future<Map<String, dynamic>> getLaundryOrderDetail(
    String orderId,
  ) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/laundry/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'data': _formatOrderData(data['data']),
          'message': data['message'] ?? 'Success',
        };
      } else {
        return {
          'status': false,
          'message': data['message'] ?? 'Failed to fetch order detail',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  // PERBAIKAN: Endpoint untuk update status order
  static Future<Map<String, dynamic>> updateLaundryOrderStatus(
    String orderId,
    Map<String, dynamic> statusData,
  ) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        return {'status': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/laundry/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(statusData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Status berhasil diperbarui',
        };
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Gagal memperbarui status',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Terjadi kesalahan: $e'};
    }
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
