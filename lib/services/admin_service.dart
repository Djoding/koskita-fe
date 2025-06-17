// lib/services/admin_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminService {
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

  // Get all users with pagination and filters
  static Future<Map<String, dynamic>> getAllUsers({
    String? role,
    bool? isApproved,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (role != null) queryParams['role'] = role;
      if (isApproved != null)
        queryParams['is_approved'] = isApproved.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(
        '$_baseUrl/users',
      ).replace(queryParameters: queryParams);
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
        throw Exception(errorData['message'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get pending users (is_approved = false)
  static Future<Map<String, dynamic>> getPendingUsers({
    int page = 1,
    int limit = 10,
  }) async {
    return getAllUsers(isApproved: false, page: page, limit: limit);
  }

  // Get verified users (is_approved = true)
  static Future<Map<String, dynamic>> getVerifiedUsers({
    int page = 1,
    int limit = 10,
  }) async {
    return getAllUsers(isApproved: true, page: page, limit: limit);
  }

  // Get user by ID
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data']['user'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Approve/Reject user
  static Future<Map<String, dynamic>> approveUser(
    String userId,
    bool isApproved,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/users/$userId/approve'),
        headers: await _headers,
        body: jsonEncode({'is_approved': isApproved}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data']['user'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete user
  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'status': true, 'message': data['message']};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Bulk approve users
  static Future<Map<String, dynamic>> bulkApproveUsers(
    List<String> userIds,
    bool isApproved,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/bulk-approve'),
        headers: await _headers,
        body: jsonEncode({'user_ids': userIds, 'is_approved': isApproved}),
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
        throw Exception(errorData['message'] ?? 'Failed to bulk approve users');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search users
  static Future<Map<String, dynamic>> searchUsers(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/users/search').replace(
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'data': data['data'],
          'pagination': data['pagination'],
          'query': data['query'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to search users');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/stats'),
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
        throw Exception(errorData['message'] ?? 'Failed to fetch statistics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
