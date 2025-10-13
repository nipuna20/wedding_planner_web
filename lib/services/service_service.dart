import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../config/api_config.dart';
import '../services/connectivity_service.dart';
import '../utils/exceptions.dart';
import '../models/service.dart';

class ServiceService {
  final ConnectivityService _connectivityService = ConnectivityService();
  late Box<Service> _servicesBox;

  ServiceService() {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _servicesBox = await Hive.openBox<Service>('services');
  }

  Future<Map<String, dynamic>?> addService({
    required String serviceName,
    required String serviceType,
    required String description,
    required String paymentPolicy,
    List<String>? mediaFiles,
  }) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final requestBody = jsonEncode({
        'serviceName': serviceName,
        'serviceType': serviceType,
        'description': description,
        'paymentPolicy': paymentPolicy,
        'mediaUrls': mediaFiles ?? [],
      });

      print('Sending POST request to ${ApiConfig.userEndpoint}/add-service');
      print('Request headers: $headers');
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('${ApiConfig.userEndpoint}/add-service'),
        headers: headers,
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        } else {
          throw ApiException(
            message: 'Invalid response format: Expected JSON object',
            statusCode: response.statusCode,
          );
        }
      } else {
        String errorMessage = 'Failed to create service';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw ApiException(
          message: '$errorMessage (Status: ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('AddService Error: $e');
      rethrow;
    }
  }

  Future<List<Service>> getAllServices(String s, {String? serviceType}) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        final cachedServices = _servicesBox.values.toList();
        print('Returning cached services: ${cachedServices.length} services');
        return cachedServices;
      }

      final token = await ApiConfig.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token missing. Please log in again.',
          statusCode: 401,
        );
      }

      final headers = await ApiConfig.getAuthHeaders();
      final uri = Uri.parse(
        '${ApiConfig.userEndpoint}/all-services${serviceType != null ? '?serviceType=$serviceType' : ''}',
      );
      print('Fetching services from: $uri with token: $token');

      final response = await http.get(uri, headers: headers);

      print(
        'GetAllServices response: ${response.statusCode}, ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> serviceList;

        if (data is Map && data['services'] is List) {
          serviceList = data['services'];
        } else if (data is List) {
          serviceList = data;
        } else {
          throw ApiException(
            message:
                'Unexpected response format: Expected { services: [] } or []',
            statusCode: 500,
          );
        }

        final services =
            serviceList.map((item) => Service.fromJson(item)).toList();
        await _servicesBox.clear();
        await _servicesBox.addAll(services);
        return services;
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          message: errorData['message'] ?? 'Failed to fetch services',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('GetAllServices Error: $e');
      rethrow;
    }
  }

  Future<Service?> getServiceById(String serviceId) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.userEndpoint}/services/$serviceId'),
        headers: headers,
      );

      final data = ApiConfig.handleResponse(response);
      if (data != null) {
        return Service.fromJson(data);
      }
      return null;
    } catch (e) {
      print('GetServiceById Error: $e');
      rethrow;
    }
  }

  Future<List<String>> uploadMediaFiles(List<File> files) async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null) {
        throw ApiException(
          message: 'No authentication token found',
          statusCode: 401,
        );
      }

      List<String> uploadedUrls = [];
      for (var file in files) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.userEndpoint}/upload-media'),
        );

        request.headers.addAll({'Authorization': 'Bearer $token'});
        request.files.add(
          await http.MultipartFile.fromPath('media', file.path),
        );

        var response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final respStr = await response.stream.bytesToString();
          final respJson = jsonDecode(respStr);
          uploadedUrls.add(respJson['fileUrl']);
        } else {
          throw ApiException(
            message: 'Error uploading file: ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      }

      return uploadedUrls;
    } catch (e) {
      print('UploadMediaFiles Error: $e');
      rethrow;
    }
  }
}
