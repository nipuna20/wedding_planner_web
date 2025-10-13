import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_planner/screens/add_service_page.dart';
import 'package:wedding_planner/screens/edit_vendor_services_page.dart';

class VendorServicesScreen extends StatefulWidget {
  const VendorServicesScreen({Key? key}) : super(key: key);

  @override
  _VendorServicesScreenState createState() => _VendorServicesScreenState();
}

class _VendorServicesScreenState extends State<VendorServicesScreen> {
  List<dynamic> services = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchServices() async {
    try {
      final token = await getToken();
      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Please log in to view your services';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://api.atchadhai.com/api/user/all-services'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          services = data['services'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load services: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching services: $e';
      });
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      final token = await getToken();
      if (token == null) {
        setState(() {
          errorMessage = 'Please log in to delete services';
        });
        return;
      }

      final response = await http.delete(
        Uri.parse('http://api.atchadhai.com/api/user/services/$serviceId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          services.removeWhere((service) => service['_id'] == serviceId);
          errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
      } else {
        setState(() {
          errorMessage = 'Failed to delete service: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete service: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error deleting service: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting service: $e')));
    }
  }

  Future<bool?> showDeleteConfirmationDialog(String serviceName) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete "$serviceName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Services', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : services.isEmpty
              ? const Center(
                child: Text('No services found. Add a service to get started!'),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        service['serviceName'] ?? 'Unnamed Service',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${service['serviceType'] ?? 'N/A'}'),
                          Text(
                            'Description: ${service['description'] ?? 'No description'}',
                          ),
                          Text(
                            'Price: \$${service['basePrice']?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                          Text(
                            'Rating: ${service['averageRating']?.toStringAsFixed(1) ?? '0.0'} (${service['reviewCount'] ?? 0} reviews)',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EditServicePage(service: service),
                                ),
                              ).then(
                                (_) => fetchServices(),
                              ); // Refresh list after edit
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm =
                                  await showDeleteConfirmationDialog(
                                    service['serviceName'],
                                  );
                              if (confirm == true) {
                                await deleteService(service['_id']);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 45,
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddServicePage()),
            ).then((_) => fetchServices());
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Add Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
