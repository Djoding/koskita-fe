import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000/api/v1/auth';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userDataKey = 'userData';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true && responseBody['data'] != null) {
          final data = responseBody['data'] as Map<String, dynamic>;

          final String? accessToken = data['accessToken'];
          final String? refreshToken = data['refreshToken'];
          final Map<String, dynamic>? user =
              data['user'] as Map<String, dynamic>?;

          if (accessToken != null && refreshToken != null) {
            await _saveTokens(accessToken, refreshToken);
            if (user != null) {
              await _storage.write(key: _userDataKey, value: jsonEncode(user));
            }
            return user ?? {};
          } else {
            throw Exception('Failed to retrieve tokens from login response.');
          }
        } else {
          throw Exception(
            responseBody['message'] ??
                'Login failed due to unexpected response.',
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Login failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await _getAccessToken();

    if (token == null) {
      throw Exception('Access token not found. Please log in.');
    }

    final url = Uri.parse('$_baseUrl/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return responseBody['data']['user'] ?? responseBody;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              'Failed to fetch user profile: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to the server or fetch profile: $e');
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> _getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> _getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<Map<String, dynamic>?> getStoredUserData() async {
    final userDataString = await _storage.read(key: _userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _getAccessToken();
    return token != null;
  }

  Future<String?> refreshAccessToken() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken == null) {
      return null;
    }

    final url = Uri.parse('$_baseUrl/refresh-token');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String? newAccessToken = responseBody['accessToken'];
        if (newAccessToken != null) {
          await _storage.write(key: _accessTokenKey, value: newAccessToken);
          return newAccessToken;
        }
      }
      throw Exception('Failed to refresh token: ${response.statusCode}');
    } catch (e) {
      await logout();
      return null;
    }
  }
}
