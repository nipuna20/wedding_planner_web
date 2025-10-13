import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class InvitationService {
  static Future<bool> saveInvitationSettings({
    required String weddingDate,
    required int sendBeforeDays,
    required String brideName,
    required String groomName,
    required String time,
    required String venue,
    required String message,
    required String template,
  }) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.invitationsEndpoint}/settings'),
        headers: headers,
        body: jsonEncode({
          "weddingDate": weddingDate,
          "sendBeforeDays": sendBeforeDays,
          "brideName": brideName,
          "groomName": groomName,
          "time": time,
          "venue": venue,
          "message": message,
          "template": template,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('SaveInvitationSettings Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getInvitationSettings() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.invitationsEndpoint}/settings'),
        headers: headers,
      );
      return ApiConfig.handleResponse(response);
    } catch (e) {
      print('GetInvitationSettings Error: $e');
      return null;
    }
  }
}
