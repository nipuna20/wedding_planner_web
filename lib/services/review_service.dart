import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_planner/config/api_config.dart';

class ReviewService {
  final String baseUrl = ApiConfig.baseUrl; // Your API base URL

  // Helper method to get the authentication token
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('No authentication token found');
      }
      return token;
    } catch (e) {
      throw Exception('Failed to retrieve token: $e');
    }
  }

  // Helper method to get the vendor ID
  Future<String?> _getVendorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getString('vendor_id');
      return vendorId;
    } catch (e) {
      throw Exception('Failed to retrieve vendor ID: $e');
    }
  }

  // Create a new review
  Future<void> createReview({
    required String targetId,
    required int rating,
    required String comment,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'targetId': targetId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create review: ${response.body}');
    }
  }

  // Fetch reviews for a specific target (e.g., vendor)
  Future<List<dynamic>> getReviews(String targetId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/reviews?targetId=$targetId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch reviews: ${response.body}');
    }
  }

  // Fetch reviews for the logged-in vendor
  Future<List<dynamic>> getVendorReviews() async {
    final token = await _getToken();
    final vendorId = await _getVendorId();
    if (token == null) {
      throw Exception('Authentication token is missing');
    }
    if (vendorId == null) {
      throw Exception('Vendor ID is missing');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/reviews?targetId=$vendorId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch vendor reviews: ${response.body}');
    }
  }
}
