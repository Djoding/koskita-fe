import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class OrderCateringService {
  static const String _baseUrl = 'http://localhost:3000/api/v1/order/catering';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'accessToken';

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

  Future<Map<String, dynamic>> createCateringOrderWithPayment({
    required String reservasiId,
    required String cateringId,
    required String metodeBayar,
    required String catatan,
    required String itemsJson,
    required File buktiBayarFile,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl);
      final String? accessToken = await _getAccessToken();

      if (accessToken == null) {
        throw Exception('Access token not found. Please log in.');
      }

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $accessToken';

      request.fields['reservasi_id'] = reservasiId;
      request.fields['catering_id'] = cateringId;
      request.fields['metode_bayar'] = metodeBayar;
      request.fields['catatan'] = catatan;

      debugPrint(
        'DEBUG Flutter Service: Raw Items JSON string received: $itemsJson',
      );
      request.fields['items'] = itemsJson;
      request.files.add(
        await http.MultipartFile.fromPath(
          'bukti_bayar',
          buktiBayarFile.path,
          contentType: _getMediaTypeForFile(buktiBayarFile),
          filename: buktiBayarFile.path.split('/').last,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error creating catering order with payment: $e');
      if (e is SocketException) {
        throw Exception('No internet connection. Please check your network.');
      }
      if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
