import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GuestService {
  static Future<bool> addGuest({
    required String name,
    required String side,
    required String phone,
    required String category,
  }) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.guestsEndpoint}/add'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'side': side.toLowerCase(),
          'phone': phone,
          'category': category.toLowerCase(),
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('AddGuest Error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getGuests() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.guestsEndpoint),
        headers: headers,
      );

      print('🧪 Response Status: ${response.statusCode}');
      print('🧪 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final guests = List<Map<String, dynamic>>.from(body['guests'] ?? []);
        print('🧪 Parsed Guests: $guests');
        return guests;
      }
      return [];
    } catch (e) {
      print('GetGuests Error: $e');
      return [];
    }
  }

  static Future<bool> sendInvitations(List<String> guestIds) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final url = Uri.parse('${ApiConfig.guestsEndpoint}/send-invitations');

      print("Sending invitation request to: $url");
      print("Guest IDs: $guestIds");

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'guestIds': guestIds}),
      );

      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print('SendInvitations Error: $e');
      return false;
    }
  }
}
