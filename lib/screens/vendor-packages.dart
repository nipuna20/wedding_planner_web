import 'package:flutter/material.dart';
import 'package:wedding_planner/services/package_service.dart';

class VendorPackagesScreen extends StatefulWidget {
  const VendorPackagesScreen({super.key});

  @override
  State<VendorPackagesScreen> createState() => _VendorPackagesScreenState();
}

class _VendorPackagesScreenState extends State<VendorPackagesScreen> {
  final PackageService _packageService = PackageService();
  List<dynamic> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final packages = await _packageService.getAllPackages();
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading packages: $e')));
    }
  }

  Future<void> _deletePackage(String packageId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final success = await _packageService.deletePackage(packageId);
      if (success) {
        await _fetchPackages();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete package');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting package: $e')));
    }
  }

  Future<void> _editPackage(dynamic package) async {
    final TextEditingController nameController = TextEditingController(
      text: package['packageName'] ?? '',
    );
    final TextEditingController priceController = TextEditingController(
      text: package['packagePrice']?.toString() ?? '0.00',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: package['description'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Package'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Package Name',
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    final updatedData = {
                      'packageName': nameController.text,
                      'packagePrice':
                          double.tryParse(priceController.text) ?? 0.0,
                      'description': descriptionController.text,
                    };
                    final success = await _packageService.updatePackage(
                      package['_id'],
                      updatedData,
                    );
                    if (success != null) {
                      Navigator.pop(context);
                      await _fetchPackages();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Package updated successfully'),
                        ),
                      );
                    } else {
                      throw Exception('Failed to update package');
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating package: $e')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Packages',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _packages.isEmpty
              ? const Center(child: Text('No packages found'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  final package = _packages[index];
                  return _packageTile(package);
                },
              ),
    );
  }

  Widget _packageTile(dynamic package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  package['packageName'] ?? 'Unnamed Package',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editPackage(package),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: Text(
                                'Are you sure you want to want to delete "${package['packageName']}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deletePackage(package['_id']);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            package['description'] ?? 'No description',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '\Rs${package['packagePrice']?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF007D8C),
            ),
          ),
        ],
      ),
    );
  }
}
