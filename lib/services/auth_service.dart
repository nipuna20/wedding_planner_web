import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>?> signUp(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}/signup'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(data),
      );
      return ApiConfig.handleResponse(response);
    } catch (e) {
      print('SignUp Error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> signIn(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}/login'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(data),
      );

      final result = ApiConfig.handleResponse(response);
      if (result != null && result['token'] != null) {
        await ApiConfig.saveToken(result['token']);
        if (result['refresh_token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('refresh_token', result['refresh_token']);
        }
      }
      return result;
    } catch (e) {
      print('SignIn Error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.authEndpoint}/profile'),
        headers: headers,
      );
      final result = ApiConfig.handleResponse(response);
      if (response.statusCode == 401) {
        return {'error': 'token_expired'};
      }
      return result;
    } catch (e) {
      print('GetProfile Error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}/refresh-token'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      final result = ApiConfig.handleResponse(response);
      if (result != null && result['token'] != null) {
        await ApiConfig.saveToken(result['token']);
        if (result['refresh_token'] != null) {
          await prefs.setString('refresh_token', result['refresh_token']);
        }
        return result;
      }
      return null;
    } catch (e) {
      print('RefreshToken Error: $e');
      return null;
    }
  }

  static Future<bool> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refresh_token'); // Clear refresh token
    return await ApiConfig.removeToken();
  }

  static Future<Map<String, dynamic>?> forgotPassword(String email) async {
    try {
      print('Sending forgot password request for email: $email');
      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}/forgot-password'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'email': email}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return ApiConfig.handleResponse(response);
    } catch (e) {
      print('ForgotPassword Error: $e');
      return null;
    }
  }
}
