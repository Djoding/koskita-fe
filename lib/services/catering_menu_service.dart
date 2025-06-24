// lib/services/catering_menu_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:kosan_euy/services/api_service.dart';
import 'package:kosan_euy/models/catering_model.dart';
import 'package:uploadthing/uploadthing.dart';
import 'package:kosan_euy/models/catering_order_model.dart';

class CateringMenuService {
  static const String _baseUrl = ApiService.baseUrl;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getCateringsByKost(String kostId) async {
    try {
      final uri = Uri.parse('${_baseUrl}catering?kost_id=$kostId');
      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<Catering> caterings =
              (data['data'] as List)
                  .map((json) => Catering.fromJson(json))
                  .toList();
          return {
            'status': true,
            'data': caterings,
            'message': data['message'],
          };
        } else {
          return {'status': false, 'message': data['message'], 'data': []};
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to fetch caterings',
          'data': [],
        };
      }
    } catch (e) {
      debugPrint('Error fetching caterings by kost: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getCateringMenu(String cateringId) async {
    try {
      final uri = Uri.parse('${_baseUrl}catering/$cateringId/menu');
      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<CateringMenuItem> menus =
            (data['data']['menus'] as List)
                .map((json) => CateringMenuItem.fromJson(json))
                .toList();
        Catering cateringInfo = Catering.fromJson(data['data']['catering']);
        return {
          'status': true,
          'catering_info': cateringInfo,
          'data': menus,
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch catering menu',
        );
      }
    } catch (e) {
      debugPrint('Error fetching catering menu: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> createCatering({
    required String kostId,
    required String namaCatering,
    required String alamat,
    String? whatsappNumber,
    File? qrisImage,
    Map<String, dynamic>? rekeningInfo,
    bool isPartner = false,
  }) async {
    try {
      String? uploadedImageUrl;
      if (qrisImage != null) {
        final uploadThing = UploadThing(
          "sk_live_08e0250b1aab76a8067be159691359dfb45a15f5fb0906fbacf6859866f1e199",
        );
        var uploadSuccess = await uploadThing.uploadFiles([qrisImage]);
        if (uploadSuccess && uploadThing.uploadedFilesData.isNotEmpty) {
          uploadedImageUrl = uploadThing.uploadedFilesData.first["url"];
        }
      }

      final response = await http.post(
        Uri.parse('${_baseUrl}catering'),
        headers: await _headers,
        body: jsonEncode({
          'kost_id': kostId,
          'nama_catering': namaCatering,
          'alamat': alamat,
          'whatsapp_number': whatsappNumber,
          'qris_image': uploadedImageUrl,
          'rekening_info': rekeningInfo,
          'is_partner': isPartner,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': Catering.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create catering');
      }
    } catch (e) {
      debugPrint('Error creating catering: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  // --- NEW: Placeholder for updateCatering method ---
  static Future<Map<String, dynamic>> updateCatering({
    required String cateringId,
    required String kostId,
    required String namaCatering,
    required String alamat,
    String? whatsappNumber,
    File? qrisImage,
    Map<String, dynamic>? rekeningInfo,
    bool? isPartner,
    String?
    existingQrisImageUrl, // Added to handle existing image without re-upload
  }) async {
    debugPrint('Attempting to update catering (frontend call)');
    debugPrint('Catering ID: $cateringId');
    debugPrint('Nama Catering: $namaCatering');
    debugPrint('Existing QRIS URL: $existingQrisImageUrl');
    debugPrint('New QRIS File: ${qrisImage?.path}');

    try {
      String? finalQrisImageUrl = existingQrisImageUrl;
      if (qrisImage != null) {
        // Only upload if a new file is provided
        final uploadThing = UploadThing(
          "sk_live_08e0250b1aab76a8067be159691359dfb45a15f5fb0906fbacf6859866f1e199",
        );
        var uploadSuccess = await uploadThing.uploadFiles([qrisImage]);
        if (uploadSuccess && uploadThing.uploadedFilesData.isNotEmpty) {
          finalQrisImageUrl = uploadThing.uploadedFilesData.first["url"];
        } else {
          throw Exception('Failed to upload new QRIS image to UploadThing');
        }
      }

      final Map<String, dynamic> body = {
        'kost_id':
            kostId, // Include kost_id, though typically not changed for update
        'nama_catering': namaCatering,
        'alamat': alamat,
        'whatsapp_number': whatsappNumber,
        'qris_image': finalQrisImageUrl, // Send the final URL
        'rekening_info': rekeningInfo,
        'is_partner': isPartner,
      };

      // NOTE: There is no backend PUT/PATCH endpoint for `/catering/:id` in the provided backend code.
      // This call will likely fail until that endpoint is implemented on the backend.
      final response = await http.put(
        // Using PUT as an assumption for update
        Uri.parse(
          '${_baseUrl}catering/$cateringId',
        ), // Assuming this endpoint for update
        headers: await _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': Catering.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Backend Error: ${errorData['message'] ?? 'Failed to update catering'}',
        );
      }
    } catch (e) {
      debugPrint('Error updating catering: $e');
      // Explicitly state that backend endpoint might be missing
      return {
        'status': false,
        'message':
            'Failed to update catering. Ensure backend endpoint for updating catering exists and is correctly implemented. Error: $e',
      };
    }
  }
  // --- END: Placeholder for updateCatering method ---

  static Future<Map<String, dynamic>> addCateringMenuItem({
    required String cateringId,
    required String namaMenu,
    required String kategori,
    required double harga,
    File? fotoMenu,
    bool isAvailable = true,
  }) async {
    try {
      String? uploadedImageUrl;
      if (fotoMenu != null) {
        final uploadThing = UploadThing(
          "sk_live_08e0250b1aab76a8067be159691359dfb45a15f5fb0906fbacf6859866f1e199",
        );
        var uploadSuccess = await uploadThing.uploadFiles([fotoMenu]);
        if (uploadSuccess && uploadThing.uploadedFilesData.isNotEmpty) {
          uploadedImageUrl = uploadThing.uploadedFilesData.first["url"];
        } else {
          throw Exception('Failed to upload image to UploadThing');
        }
      }

      final response = await http.post(
        Uri.parse('${_baseUrl}catering/$cateringId/menu'),
        headers: await _headers,
        body: jsonEncode({
          'nama_menu': namaMenu,
          'kategori': kategori,
          'harga': harga,
          'foto_menu': uploadedImageUrl,
          'is_available': isAvailable,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': CateringMenuItem.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add menu item');
      }
    } catch (e) {
      debugPrint('Error adding menu item: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateCateringMenuItem({
    required String cateringId,
    required String menuId,
    String? namaMenu,
    String? kategori,
    double? harga,
    File? newFotoMenu,
    String? existingFotoMenuUrl,
    bool? isAvailable,
  }) async {
    try {
      String? finalFotoMenuUrl = existingFotoMenuUrl;
      if (newFotoMenu != null) {
        final uploadThing = UploadThing(
          "sk_live_08e0250b1aab76a8067be159691359dfb45a15f5fb0906fbacf6859866f1e199",
        );
        var uploadSuccess = await uploadThing.uploadFiles([newFotoMenu]);
        if (uploadSuccess && uploadThing.uploadedFilesData.isNotEmpty) {
          finalFotoMenuUrl = uploadThing.uploadedFilesData.first["url"];
        } else {
          throw Exception('Failed to upload new image to UploadThing');
        }
      }

      final Map<String, dynamic> body = {};
      if (namaMenu != null) body['nama_menu'] = namaMenu;
      if (kategori != null) body['kategori'] = kategori;
      if (harga != null) body['harga'] = harga;
      if (finalFotoMenuUrl != null) body['foto_menu'] = finalFotoMenuUrl;
      if (isAvailable != null) body['is_available'] = isAvailable;

      if (body.isEmpty) {
        return {'status': false, 'message': 'No valid fields to update'};
      }

      final response = await http.put(
        Uri.parse('${_baseUrl}catering/$cateringId/menu/$menuId'),
        headers: await _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': CateringMenuItem.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update menu item');
      }
    } catch (e) {
      debugPrint('Error updating menu item: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteCateringMenuItem({
    required String cateringId,
    required String menuId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl}catering/$cateringId/menu/$menuId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'message':
              data['message'] ??
              'Menu item deleted successfully (soft deleted)',
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete menu item');
      }
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCateringOrders({
    String? status,
    String? cateringId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (cateringId != null && cateringId.isNotEmpty) {
        queryParams['catering_id'] = cateringId;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final uri = Uri.parse(
        '${_baseUrl}catering/orders',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<CateringOrder> orders =
              (data['data'] as List)
                  .map((json) => CateringOrder.fromJson(json))
                  .toList();
          return {'status': true, 'data': orders, 'message': data['message']};
        } else {
          return {'status': false, 'message': data['message'], 'data': []};
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to fetch orders',
          'data': [],
        };
      }
    } catch (e) {
      debugPrint('Error fetching catering orders: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getCateringOrderDetail(
    String orderId,
  ) async {
    try {
      final uri = Uri.parse('${_baseUrl}catering/orders/$orderId');
      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'status': true,
            'data': CateringOrder.fromJson(data['data']),
            'message': data['message'],
          };
        } else {
          return {'status': false, 'message': data['message'], 'data': null};
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to fetch order detail',
          'data': null,
        };
      }
    } catch (e) {
      debugPrint('Error fetching catering order detail: $e');
      return {'status': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('${_baseUrl}catering/orders/$orderId/status'),
        headers: await _headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'message': data['message'] ?? 'Order status updated successfully',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to update order status',
        };
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return {'status': false, 'message': 'Network error: $e'};
    }
  }
}
