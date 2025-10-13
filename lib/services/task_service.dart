import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TaskService {
  static Future<bool> addTask(Map<String, dynamic> taskData) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();

      final response = await http.post(
        Uri.parse('${ApiConfig.userEndpoint}/task'),
        headers: headers,
        body: jsonEncode(taskData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('AddTask Error: $e');
      return false;
    }
  }
}
