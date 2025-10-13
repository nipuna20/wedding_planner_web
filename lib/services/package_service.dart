import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PackageService {
  Future<List<dynamic>> getAllPackages() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.userEndpoint}/packages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['packages'] ?? [];
      } else {
        throw Exception('Failed to load packages: ${response.statusCode}');
      }
    } catch (e) {
      print('GetAllPackages Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPackageById(String packageId) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.userEndpoint}/packages/$packageId'),
        headers: headers,
      );

      return ApiConfig.handleResponse(response);
    } catch (e) {
      print('GetPackageById Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createPackage(
    Map<String, dynamic> packageData,
  ) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.userEndpoint}/package'),
        headers: headers,
        body: json.encode(packageData),
      );

      return ApiConfig.handleResponse(response);
    } catch (e) {
      print('CreatePackage Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updatePackage(
    String packageId,
    Map<String, dynamic> packageData,
  ) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.userEndpoint}/packages/$packageId'),
        headers: headers,
        body: json.encode(packageData),
      );

      return ApiConfig.handleResponse(response);
    } catch (e) {
      print('UpdatePackage Error: $e');
      return null;
    }
  }

  Future<bool> deletePackage(String packageId) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.userEndpoint}/packages/$packageId'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('DeletePackage Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> addPackagesToService(
    String serviceId,
    List<Map<String, dynamic>> packages,
  ) async {
    try {
      print('Making API call with serviceId: $serviceId');
      final headers = await ApiConfig.getAuthHeaders();

      // Ensure packages are encoded with numeric price
      final body = {'packages': packages};
      print(
        'Request URL: ${ApiConfig.userEndpoint}/services/$serviceId/packages',
      );
      print('Request body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse('${ApiConfig.userEndpoint}/services/$serviceId/packages'),
        headers: headers,
        body: json.encode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception(
          'Error adding packages: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('AddPackagesToService Error: $e');
      if (e is Exception) {
        print('Exception details: ${e.toString()}');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchVendorsByCategoryAndBudget(
      String category, double minBudget, double maxBudget) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.userEndpoint}/services?category=$category&minBudget=$minBudget&maxBudget=$maxBudget',
        ),
        headers: headers,
      );

      print('FetchVendors Request URL: ${ApiConfig.userEndpoint}/services?category=$category&minBudget=$minBudget&maxBudget=$maxBudget');
      print('FetchVendors Response status: ${response.statusCode}');
      print('FetchVendors Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> services = jsonResponse['services'] ?? [];
        List<Map<String, dynamic>> vendors = [];

        for (var service in services) {
          var packages = service['packages'] as List<dynamic>? ?? [];
          for (var pkg in packages) {
            double price = pkg['price']?.toDouble() ?? 0.0;
            if (price >= minBudget && price <= maxBudget) {
              vendors.add({
                'name': service['vendorName'] ?? 'Unknown Vendor',
                'packageName': pkg['name'] ?? 'N/A',
                'price': price,
                'description': pkg['description'] ?? 'No description',
              });
            }
          }
        }

        return vendors;
      } else {
        throw Exception('Failed to fetch vendors: ${response.statusCode}');
      }
    } catch (e) {
      print('FetchVendorsByCategoryAndBudget Error: $e');
      throw Exception('Failed to fetch vendors: $e');
    }
  }
}