import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class UserService {
  // Get user profile
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.userEndpoint}/profile'),
        headers: headers,
      );
      return ApiConfig.handleResponse(response);
    } catch (e) {
      print('GetProfile Error: $e');
      return null;
    }
  }

  // Update user name
  static Future<bool> updateName(String name) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.userEndpoint}/update-profile'),
        headers: headers,
        body: jsonEncode({"name": name}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('UpdateName Error: $e');
      return false;
    }
  }

  // Update user email
  static Future<bool> updateEmail(String email) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.userEndpoint}/update-profile'),
        headers: headers,
        body: jsonEncode({"email": email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('UpdateEmail Error: $e');
      return false;
    }
  }

  // Update user phone
  static Future<bool> updatePhone(String phone) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.userEndpoint}/update-profile'),
        headers: headers,
        body: jsonEncode({"phone": phone}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('UpdatePhone Error: $e');
      return false;
    }
  }

  // Get vendor setup
  static Future<Map<String, dynamic>?> getVendorSetup() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.userEndpoint}/vendor-setup'),
        headers: headers,
      );

      final result = ApiConfig.handleResponse(response);
      return result?['vendorProfile'];
    } catch (e) {
      print('GetVendorSetup Error: $e');
      return null;
    }
  }

  // Update vendor setup
  static Future<bool> updateVendorSetup(Map<String, dynamic> data) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.userEndpoint}/vendor-setup'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('UpdateVendorSetup Error: $e');
      return false;
    }
  }

  // Update vendor package
  static Future<bool> updateVendorPackage(Map<String, dynamic> data) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.userEndpoint}/vendor/select-package'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('UpdateVendorPackage Error: $e');
      return false;
    }
  }

  // Update vendor availability
  static Future<bool> updateAvailability(List<String> unavailableDates) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.userEndpoint}/vendor-availability'),
        headers: headers,
        body: jsonEncode({"unavailableDates": unavailableDates}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('UpdateAvailability Error: $e');
      return false;
    }
  }

  // Save vendor service
  static Future<bool> saveVendorService(Map<String, dynamic> data) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.userEndpoint}/add-service'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('SaveVendorService Error: $e');
      return false;
    }
  }

  // Add vendor package
  static Future<bool> addVendorPackage(Map<String, dynamic> data) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.userEndpoint}/package'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('AddVendorPackage Error: $e');
      return false;
    }
  }

  // Add task
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

  // Get tasks
  static Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.userEndpoint}/task'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['tasks'] ?? []);
      }
      return [];
    } catch (e) {
      print('GetTasks Error: $e');
      return [];
    }
  }

  // Get subtasks
  static Future<Map<String, dynamic>?> getSubtasks(int taskIndex) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.userEndpoint}/task/$taskIndex/subtasks'),
        headers: headers,
      );
      print('📥 Subtask API STATUS: ${response.statusCode}');
      print('📥 Subtask API BODY: ${response.body}');
      return ApiConfig.handleResponse(response);
    } catch (e) {
      print('GetSubtasks Error: $e');
      return null;
    }
  }

  // Add subtask
  static Future<Map<String, dynamic>> addSubtask(
    int taskIndex,
    String title,
  ) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.userEndpoint}/task/$taskIndex/subtask'),
        headers: headers,
        body: jsonEncode({"title": title}),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'subtask': data['subtask'] ?? {'title': title, 'completed': false},
        };
      } else {
        print(
          'AddSubtask Failed: Status ${response.statusCode}, Body: ${response.body}',
        );
        final data = jsonDecode(response.body);
        return {'success': false, 'error': data['message'] ?? 'Unknown error'};
      }
    } catch (e) {
      print('AddSubtask Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Delete subtask
  static Future<Map<String, dynamic>> deleteSubtask(
    int taskIndex,
    int subtaskIndex,
  ) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.delete(
        Uri.parse(
          '${ApiConfig.userEndpoint}/task/$taskIndex/subtask/$subtaskIndex',
        ),
        headers: headers,
      );
      print('Delete Subtask Response Status: ${response.statusCode}');
      print('Delete Subtask Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Subtask deleted successfully'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'error': data['message'] ?? 'Unknown error'};
      }
    } catch (e) {
      print('DeleteSubtask Error: $e');
      if (e is FormatException) {
        return {
          'success': false,
          'error': 'Invalid server response: ${e.message}',
        };
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  // Delete task
  static Future<Map<String, dynamic>> deleteTask(int taskIndex) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.userEndpoint}/task/$taskIndex'),
        headers: headers,
      );

      print('Delete Task Response Status: ${response.statusCode}');
      print('Delete Task Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Task deleted successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'error': data['message'] ?? 'Unknown error'};
      }
    } catch (e) {
      print('DeleteTask Error: $e');
      if (e is FormatException) {
        return {
          'success': false,
          'error': 'Invalid server response: ${e.message}',
        };
      }
      return {'success': false, 'error': e.toString()};
    }
  }
}
