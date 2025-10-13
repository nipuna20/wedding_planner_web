import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditServicePage extends StatefulWidget {
  final Map<String, dynamic> service;

  const EditServicePage({Key? key, required this.service}) : super(key: key);

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serviceNameController;
  late TextEditingController _serviceTypeController;
  late TextEditingController _descriptionController;
  late TextEditingController _paymentPolicyController;
  late TextEditingController _mediaUrlsController;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _serviceNameController = TextEditingController(text: widget.service['serviceName'] ?? '');
    _serviceTypeController = TextEditingController(text: widget.service['serviceType'] ?? '');
    _descriptionController = TextEditingController(text: widget.service['description'] ?? '');
    _paymentPolicyController = TextEditingController(text: widget.service['paymentPolicy'] ?? '');
    _mediaUrlsController = TextEditingController(text: widget.service['mediaUrls']?.join(', ') ?? '');
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _paymentPolicyController.dispose();
    _mediaUrlsController.dispose();
    super.dispose();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> updateService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await getToken();
      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Please log in to update services';
        });
        return;
      }

      final updates = {
        'serviceName': _serviceNameController.text,
        'serviceType': _serviceTypeController.text,
        'description': _descriptionController.text,
        'paymentPolicy': _paymentPolicyController.text,
        'mediaUrls': _mediaUrlsController.text.split(',').map((url) => url.trim()).toList(),
      };

      final response = await http.put(
        Uri.parse('http://api.atchadhai.com/api/user/services/${widget.service['_id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = 'Failed to update service: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update service: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error updating service: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating service: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Service',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _serviceNameController,
                      decoration: const InputDecoration(labelText: 'Service Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a service name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceTypeController,
                      decoration: const InputDecoration(labelText: 'Service Type'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a service type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _paymentPolicyController,
                      decoration: const InputDecoration(labelText: 'Payment Policy'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mediaUrlsController,
                      decoration: const InputDecoration(
                        labelText: 'Media URLs (comma-separated)',
                        hintText: 'e.g., http://example.com/image1.jpg, http://example.com/image2.jpg',
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: updateService,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text('Update Service'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}