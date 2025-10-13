import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class EventService {
  static Future<bool> addEvent(String name, String date) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.eventsEndpoint}/add'),
        headers: headers,
        body: jsonEncode({"name": name, "date": date}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMyEvents() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.eventsEndpoint}/my-events'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['events'] ?? []).map((e) {
          return {
            '_id': e['_id'],
            'name': e['name'],
            'date': DateTime.parse(e['date']).toIso8601String(),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateEvent(
    String eventId,
    String name,
    String date,
  ) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.eventsEndpoint}/update/$eventId'),
        headers: headers,
        body: jsonEncode({"name": name, "date": date}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteEvent(String eventId) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.eventsEndpoint}/delete/$eventId'),
        headers: headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
