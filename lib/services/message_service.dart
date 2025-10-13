import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wedding_planner/config/api_config.dart';

class MessageService {
  // Send a message to a receiver (vendor or customer)
  Future<Map<String, dynamic>?> sendMessage(
    String receiverId,
    String message,
  ) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/send'),
        headers: headers,
        body: jsonEncode({'receiverId': receiverId, 'message': message}),
      );

      return ApiConfig.handleResponse(response);
    } catch (e) {
      print('SendMessage Error: $e');
      return null;
    }
  }

  // Fetch conversation between two users
  Future<List<dynamic>?> getConversation(String otherUserId) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/chat/conversation?otherUserId=$otherUserId',
        ),
        headers: headers,
      );

      final data = ApiConfig.handleResponse(response);
      return data?['messages'] ?? [];
    } catch (e) {
      print('GetConversation Error: $e');
      return [];
    }
  }

  // Fetch list of users (vendors or customers) with whom the current user has chatted
  Future<Map<String, dynamic>?> getChatUsers() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/users'),
        headers: headers,
      );

      final data = ApiConfig.handleResponse(response);
      return data ?? {};
    } catch (e) {
      print('GetChatUsers Error: $e');
      return {};
    }
  }
}
