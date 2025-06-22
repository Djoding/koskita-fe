import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  static const String _baseUrl = 'https://kost-kita.my.id/api/v1/auth';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userDataKey = 'userData';

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('Access token not found. Please log in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '493320600420-86og9e4gofabhq4lrsoscgnt9s0de946.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  Future<Map<String, dynamic>> register(
    String username,
    String fullName,
    String email,
    String password, {
    String? role,
    String? phone,
    String? whatsappNumber,
  }) async {
    final url = Uri.parse('$_baseUrl/register');

    try {
      final Map<String, dynamic> body = {
        'username': username,
        'full_name': fullName,
        'email': email,
        'password': password,
      };

      if (role != null) body['role'] = role;
      if (phone != null) body['phone'] = phone;
      if (whatsappNumber != null) body['whatsapp_number'] = whatsappNumber;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
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
            throw Exception(
              'Failed to retrieve tokens from registration response.',
            );
          }
        } else {
          throw Exception(
            responseBody['message'] ??
                'Registration failed due to unexpected response.',
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              'Registration failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to the server for registration: $e');
    }
  }

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

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In dibatalkan oleh pengguna.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Gagal mendapatkan ID Token dari Google.');
      }

      final url = Uri.parse('$_baseUrl/google/mobile');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
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
            throw Exception('Gagal mendapatkan token dari respons backend.');
          }
        } else {
          throw Exception(
            responseBody['message'] ?? 'Otentikasi Google gagal di backend.',
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Kesalahan backend: ${response.statusCode}',
        );
      }
    } catch (e) {
      await _googleSignIn.signOut();
      throw Exception('Gagal melakukan login Google: $e');
    }
  }

  Future<Map<String, dynamic>> setPassword(
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$_baseUrl/setup-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          'success': responseBody['success'] ?? true,
          'message': responseBody['message'] ?? 'Password berhasil diatur.',
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              'Gagal mengatur password: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
      );
    } on http.ClientException catch (e) {
      throw Exception('Kesalahan jaringan: ${e.message}');
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan tidak terduga saat mengatur password: $e',
      );
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

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
    String? whatsappNumber,
    File? avatarFile,
    bool clearAvatar = false,
  }) async {
    final token = await _getAccessToken();

    if (token == null) {
      throw Exception('Access token not found. Please log in.');
    }
    final url = Uri.parse('$_baseUrl/profile');

    try {
      final request = http.MultipartRequest('PUT', url);

      request.headers['Authorization'] = 'Bearer $token';

      if (fullName != null) {
        request.fields['full_name'] = fullName;
      }
      if (phone != null) {
        request.fields['phone'] = phone;
      }
      if (whatsappNumber != null) {
        request.fields['whatsapp_number'] = whatsappNumber;
      }

      if (avatarFile != null) {
        final MediaType contentType = _getMediaTypeForFile(avatarFile);
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatarFile.path,
            filename: avatarFile.path.split('/').last,
            contentType: contentType,
          ),
        );
      } else if (clearAvatar) {
        request.fields['avatar'] = '';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true && responseBody['data'] != null) {
          final data = responseBody['data'] as Map<String, dynamic>;
          final Map<String, dynamic>? user =
              data['user'] as Map<String, dynamic>?;

          if (user != null) {
            await _storage.write(key: _userDataKey, value: jsonEncode(user));
            return user;
          } else {
            throw Exception('Updated user data not found in response.');
          }
        } else {
          throw Exception(
            responseBody['message'] ??
                'Profile update failed due to unexpected response.',
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              'Profile update failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to the server or update profile: $e');
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final url = Uri.parse('$_baseUrl/change-password');

    try {
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          'success': responseBody['success'] ?? true,
          'message': responseBody['message'] ?? 'Password berhasil diubah.',
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              'Gagal mengubah password: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
      );
    } on http.ClientException catch (e) {
      throw Exception('Kesalahan jaringan: ${e.message}');
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan tidak terduga saat mengubah password: $e',
      );
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
    await _googleSignIn.signOut();
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
