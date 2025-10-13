import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Base configuration
  static const String baseUrl =
      'http://192.168.8.152:5000/api'; // Updated to correct hosted URL
  static const String tokenKey = 'auth_token';
  //http://192.168.8.151:5000

  // API endpoints
  static const String authEndpoint = '$baseUrl/auth';
  static const String userEndpoint = '$baseUrl/user';
  static const String eventsEndpoint = '$baseUrl/events';
  static const String guestsEndpoint = '$baseUrl/guests';
  static const String invitationsEndpoint = '$baseUrl/invitations';
  static const String task = '$baseUrl/user';

  // Common headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
  };

  // Get token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Get authenticated headers
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      ...defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Save token to SharedPreferences
  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(tokenKey, token);
  }

  // Remove token from SharedPreferences
  static Future<bool> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(tokenKey);
  }

  // Common response handler
  static Map<String, dynamic>? handleResponse(dynamic response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('Error parsing JSON: $e');
        return null;
      }
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
