import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    // try {
    //   final response = await ApiService.post('/login', {
    //     'email': email,
    //     'password': password,
    //   });
    //   debugPrint("RESPONSE LOGN ${response["user"]}");
    //   debugPrint("RESPONSE LOGN2 ${response["message"]}");
    //   debugPrint("RESPONSE LOGN3 ${response['message']}");
    //   if (response['token'] != null) {
    //     ApiService.token = response['token'];
    //     final prefs = await SharedPreferences.getInstance();
    //     await prefs.setString('token', response['token']);
    //     return {
    //       'status': true,
    //       'token': response['token'],
    //       'message': response['message'],
    //     };
    //   }
    //   return {'status': false, 'message': response['message']};
    // } catch (e) {
    //   debugPrint('Login error: $e');
    //   return {'status': false, 'message': e.toString()};
    // }
    // --- OFFLINE MODE: return dummy data ---
    return {'status': true, 'token': 'dummy_token', 'message': 'Login offline'};
  }

  static Future<Map<String, dynamic>> loginWithGoogle(
    String name,
    String email,
    String token,
    String photoUrl,
    String userRole,
  ) async {
    // try {
    //   final response = await ApiService.post('/auth/google', {
    //     'token': token,
    //     'role': userRole,
    //   });
    //   debugPrint('Login with Google response: $response');
    //   if (response['token'] != null) {
    //     ApiService.token = response['token'];
    //     final prefs = await SharedPreferences.getInstance();
    //     await prefs.setString('token', response['token']);
    //     return {'status': true, 'message': response['token']};
    //   }
    //   return {'status': false, 'message': response['message']};
    // } catch (e) {
    //   debugPrint('Login with Google error: $e');
    //   return {'status': false, 'message': e.toString()};
    // }
    // --- OFFLINE MODE: return dummy data ---
    return {'status': true, 'message': 'Login Google offline'};
  }

  // Register
  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    // try {
    //   final response = await ApiService.post('/register', {
    //     'name': name,
    //     'email': email,
    //     'password': password,
    //   });
    //   return response['success'] == true;
    // } catch (e) {
    //   debugPrint('Register error: $e');
    //   return false;
    // }
    // --- OFFLINE MODE: return true ---
    return true;
  }

  // Logout
  static Future<void> logout() async {
    // ApiService.token = null;
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('token');
    // --- OFFLINE MODE: kosong ---
    return;
  }

  // Cek apakah user sudah login
  static Future<Map<String, dynamic>> isLoggedIn() async {
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('token');
    // if (token == null) {
    //   return {'isLoggedIn': false, 'token': null};
    // }
    // if (JwtDecoder.isExpired(token)) {
    //   await logout();
    //   return {'isLoggedIn': false, 'token': null};
    // }
    // ApiService.token = token;
    // return {'isLoggedIn': true, 'token': token};
    // --- OFFLINE MODE: selalu tidak login ---
    return {'isLoggedIn': false, 'token': null};
  }
}
