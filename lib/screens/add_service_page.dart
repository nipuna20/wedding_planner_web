import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/service_service.dart';
import 'add_packages_page.dart';

class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _serviceNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentPolicyController = TextEditingController();
  String selectedServiceType = 'Select';
  final ServiceService _serviceService = ServiceService();
  bool _isLoading = false;
  List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _serviceNameController.text = 'Service I';
    _descriptionController.text = 'Type here';
    _paymentPolicyController.text = 'Type here';
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.length() > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File size too large. Please select a file less than 10MB',
              ),
            ),
          );
          return;
        }

        setState(() {
          _selectedFiles.add(file);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking media: $e')));
    }
  }

  Future<void> _saveService() async {
    if (_serviceNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Service name is required')));
      return;
    }

    if (selectedServiceType == 'Select') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a service type')));
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Description is required')));
      return;
    }

    if (_paymentPolicyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment policy is required')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> mediaUrls = [];
      if (_selectedFiles.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Uploading media files...')));

        try {
          mediaUrls = await _serviceService.uploadMediaFiles(_selectedFiles);
          if (mediaUrls.isEmpty && _selectedFiles.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Some media files may not have uploaded correctly',
                ),
              ),
            );
          }
        } catch (uploadError) {
          final continueWithoutMedia = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: Color(0xFF2A2A2A),
                  title: Text(
                    'Upload Error',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Text(
                    'Media upload failed. Continue without media files?',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF00BCD4)),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text(
                        'Continue',
                        style: TextStyle(color: Color(0xFF00BCD4)),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
          );

          if (continueWithoutMedia != true) {
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
      }

      print('Sending service creation request...');
      final result = await _serviceService.addService(
        serviceName: _serviceNameController.text.trim(),
        serviceType: selectedServiceType,
        description: _descriptionController.text.trim(),
        paymentPolicy: _paymentPolicyController.text.trim(),
        mediaFiles: mediaUrls,
      );

      print('Service creation result: $result');

      String? serviceId;
      if (result != null) {
        if (result.containsKey('_id') && result['_id'] != null) {
          serviceId = result['_id'].toString();
          print('Extracted serviceId from direct _id: $serviceId');
        } else if (result.containsKey('service') &&
            result['service'] != null &&
            result['service'].containsKey('_id') &&
            result['service']['_id'] != null) {
          serviceId = result['service']['_id'].toString();
          print('Extracted serviceId from nested service._id: $serviceId');
        } else {
          print('No valid serviceId found in response');
          throw Exception(
            'Service ID missing in server response. Response: $result',
          );
        }
      } else {
        print('Service creation result is null');
        throw Exception('Invalid response from server: Result is null');
      }

      if (serviceId != null && serviceId.isNotEmpty) {
        print('Navigating to AddPackagesPage with serviceId: $serviceId');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddPackagesPage(serviceId: serviceId!),
          ),
        );
      }
    } catch (e) {
      print('Error in _saveService: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save service: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text('Add Service', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Service Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField('Service Name', _serviceNameController),
                    SizedBox(height: 20),
                    _buildDropdownField(),
                    SizedBox(height: 20),
                    _buildTextAreaField('Description', _descriptionController),
                    SizedBox(height: 20),
                    _buildUploadSection(),
                    SizedBox(height: 20),
                    _buildTextAreaField(
                      'Payment Policy',
                      _paymentPolicyController,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveService,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black87, fontSize: 14)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Type',
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: DropdownButtonFormField<String>(
            value: selectedServiceType,
            dropdownColor: Colors.white,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.black87),
            items:
                [
                  'Select',
                  'Decoration',
                  'Photography',
                  'Beautician',
                  'Wedding Hall',
                  'Wedding Cars',
                  'Invitation Cards',
                  'Catering',
                  'Gift Items',
                  'Sweets & Cakes',
                  'Garland',
                  'Iyer',
                  'Mangala Vathiyam',
                  'Outdoor Setup',
                  'DJ',
                  'Kolam',
                  'Mehndi Artist',
                  'Live Music Troupe',
                  'Jewellery & Accessories',
                  'Wedding Attire',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.black87)),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedServiceType = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black87, fontSize: 14)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload photos or Videos',
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            if (_selectedFiles.length >= 10) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Maximum 10 files can be uploaded')),
              );
              return;
            }
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              builder:
                  (context) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.photo_library,
                            color: Color(0xFF00B8E4),
                          ),
                          title: Text(
                            'Gallery',
                            style: TextStyle(color: Colors.black87),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia(ImageSource.gallery);
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.camera_alt,
                            color: Color(0xFF00E7AC),
                          ),
                          title: Text(
                            'Camera',
                            style: TextStyle(color: Colors.black87),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia(ImageSource.camera);
                          },
                        ),
                      ],
                    ),
                  ),
            );
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFF00B8E4), width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child:
                _selectedFiles.isEmpty
                    ? Center(
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFF00B8E4),
                        size: 40,
                      ),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(
                                  _selectedFiles[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFiles.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _paymentPolicyController.dispose();
    super.dispose();
  }
}
