import 'package:flutter/material.dart';
import '../services/service_service.dart';
import '../services/package_service.dart';

class Package {
  String name;
  String price; // Store as string for display, parse to double when needed
  String description;
  TextEditingController nameController;
  TextEditingController priceController;
  TextEditingController descriptionController;

  Package({required this.name, required this.price, required this.description})
    : nameController = TextEditingController(text: name),
      priceController = TextEditingController(text: price),
      descriptionController = TextEditingController(text: description);

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }
}

class AddPackagesPage extends StatefulWidget {
  final String serviceId;

  AddPackagesPage({required this.serviceId});

  @override
  _AddPackagesPageState createState() => _AddPackagesPageState();
}

class _AddPackagesPageState extends State<AddPackagesPage> {
  List<Package> packages = [
    Package(name: 'Package I', price: '5000', description: 'Type here'),
  ];

  final ServiceService _serviceService = ServiceService();
  final PackageService _packageService = PackageService();
  bool _isLoading = false;
  Map<String, double>? budgetRange; // To store min and max budget

  // Budget ranges from budget_allocation_page.dart
  final Map<String, List<String>> categoryBudgetRanges = {
    'Photography': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Decoration': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Beautician': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Wedding Hall': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Wedding Cars': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Invitation Cards': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Catering': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Gift Items': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Sweets & Cakes': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Garland': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Iyer': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Mangala Vathiyam': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Outdoor Setup': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'DJ': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Kolam': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Mehndi Artist': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Live Music Troupe': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Jewellery & Accessories': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
    'Wedding Attire': [
      'Rs 10,000 - 100,000',
      'Rs 100,000 - 200,000',
      'Rs 200,000 - 300,000',
      'Rs 300,000 - 500,000',
      'Rs 500,000 - 1,000,000',
      'Rs 1,000,000 - 2,000,000',
      'Rs 2,000,000  and above',
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchBudgetRange();
  }

  // Fetch the budget range for the service's category
  Future<void> _fetchBudgetRange() async {
    try {
      final service = await _serviceService.getServiceById(widget.serviceId);
      if (service != null &&
          categoryBudgetRanges.containsKey(service.serviceType)) {
        final ranges = categoryBudgetRanges[service.serviceType]!;
        double minBudget = double.infinity;
        double maxBudget = 0;
        for (var range in ranges) {
          final budgetLimits = _parseBudgetRange(range);
          if (budgetLimits['min']! < minBudget)
            minBudget = budgetLimits['min']!;
          if (budgetLimits['max']! > maxBudget)
            maxBudget = budgetLimits['max']!;
        }
        setState(() {
          budgetRange = {'min': minBudget, 'max': maxBudget};
        });
      } else {
        print('Service or category not found: ${service?.serviceType}');
      }
    } catch (e) {
      print('Error fetching budget range: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load budget range: $e')),
      );
    }
  }

  // Parse budget range to get min and max values
  Map<String, double> _parseBudgetRange(String budgetRange) {
    String cleanRange = budgetRange.replaceAll('Rs ', '').replaceAll(',', '').trim();
    if (cleanRange.contains('and above')) {
      String numStr = cleanRange.split('and above')[0].trim();
      double min = double.tryParse(numStr) ?? 0;
      return {'min': min, 'max': double.infinity};
    } else {
      List<String> parts = cleanRange.split(' - ');
      if (parts.length != 2) {
        return {'min': 0, 'max': 0};
      }
      return {
        'min': double.tryParse(parts[0]) ?? 0,
        'max': double.tryParse(parts[1]) ?? 0,
      };
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
        title: Text('Add Packages', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Package Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  return _buildPackageCard(packages[index], index);
                },
              ),
            ),
            GestureDetector(
              onTap: _addNewPackage,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Color(0xFF00B8E4), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add more packages',
                      style: TextStyle(
                        color: Color(0xFF00B8E4),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
                onPressed: _isLoading ? null : _savePackages,
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

  Widget _buildPackageCard(Package package, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField('Package Name', package.nameController),
          SizedBox(height: 16),
          _buildPriceInputField('Package Price (Rs)', package.priceController),
          SizedBox(height: 16),
          _buildTextAreaField('Description', package.descriptionController),
        ],
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
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
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

  Widget _buildPriceInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black87, fontSize: 14)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: 'Enter price in Rs',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
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
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
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

  void _addNewPackage() {
    setState(() {
      packages.add(
        Package(
          name: 'Package ${packages.length + 1}',
          price: '5000',
          description: 'Type here',
        ),
      );
    });
  }

  Future<void> _savePackages() async {
    print('Service ID being used: ${widget.serviceId}');

    if (widget.serviceId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Service ID is missing')));
      return;
    }

    for (var package in packages) {
      if (package.nameController.text.trim().isEmpty ||
          package.priceController.text.trim().isEmpty ||
          package.descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all package details')),
        );
        return;
      }

      // Validate price against budget range
      if (budgetRange != null) {
        double enteredPrice =
            double.tryParse(package.priceController.text.trim()) ?? 0;
        if (enteredPrice < budgetRange!['min']! ||
            enteredPrice > budgetRange!['max']!) {
          String minStr = budgetRange!['min']!.toStringAsFixed(0);
          String rangeStr;
          if (budgetRange!['max']! == double.infinity) {
            rangeStr = 'at least Rs $minStr';
          } else {
            rangeStr = 'between Rs $minStr and Rs ${budgetRange!['max']!.toStringAsFixed(0)}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Price for ${package.nameController.text} must be $rangeStr',
              ),
            ),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget range not available for this service'),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> packagesData =
          packages.map((package) {
            double price = double.parse(package.priceController.text.trim());
            return {
              'name': package.nameController.text.trim(),
              'price': price,
              'description': package.descriptionController.text.trim(),
            };
          }).toList();

      print('Sending request to add packages for service: ${widget.serviceId}');
      print('Package data: $packagesData');

      final result = await _packageService.addPackagesToService(
        widget.serviceId,
        packagesData,
      );

      print('Add packages result: $result');

      if (result != null && result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Packages saved successfully')));
        Navigator.pop(context);
      } else {
        String errorMsg =
            result != null && result['message'] != null
                ? result['message']
                : 'Failed to save packages';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      print('Error adding packages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var package in packages) {
      package.dispose();
    }
    super.dispose();
  }
}