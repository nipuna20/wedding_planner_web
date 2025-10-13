import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'availability_calendar.dart'; // Add this import

class BudgetAllocationPage extends StatefulWidget {
  final String selectedCategory;
  final String categoryImage;

  const BudgetAllocationPage({
    Key? key,
    required this.selectedCategory,
    required this.categoryImage,
  }) : super(key: key);

  @override
  _BudgetAllocationPageState createState() => _BudgetAllocationPageState();
}

class _BudgetAllocationPageState extends State<BudgetAllocationPage> {
  String selectedBudgetRange = '';
  double budgetPercentage = 0.0;
  List<dynamic> vendors = [];
  bool isLoadingVendors = false;
  bool showVendors = false;
  String? errorMessage;

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

  // Define typical budget percentages for each service type
  final Map<String, double> categoryPercentages = {
    'Photography': 10.0,
    'Decoration': 12.0,
    'Beautician': 5.0,
    'Wedding Hall': 30.0,
    'Wedding Cars': 5.0,
    'Invitation Cards': 3.0,
    'Catering': 20.0,
    'Gift Items': 3.0,
    'Sweets & Cakes': 5.0,
    'Garland': 2.0,
    'Iyer': 2.0,
    'Mangala Vathiyam': 3.0,
    'Outdoor Setup': 5.0,
    'DJ': 3.0,
    'Kolam': 1.0,
    'Mehndi Artist': 2.0,
    'Live Music Troupe': 5.0,
    'Jewellery & Accessories': 10.0,
    'Wedding Attire': 8.0,
  };

  @override
  void initState() {
    super.initState();
    budgetPercentage = categoryPercentages[widget.selectedCategory] ?? 10.0;
  }

  List<String> get currentCategoryBudgetRanges {
    return categoryBudgetRanges[widget.selectedCategory] ?? [];
  }

  // Parse budget range to get min and max values
  Map<String, double> parseBudgetRange(String budgetRange) {
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

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchVendorsInBudgetRange() async {
    if (selectedBudgetRange.isEmpty) {
      print('No budget range selected');
      return;
    }

    print(
      'Fetching vendors for category: ${widget.selectedCategory}, budget: $selectedBudgetRange',
    );

    setState(() {
      isLoadingVendors = true;
      errorMessage = null;
      vendors.clear(); // Clear previous vendors
    });

    try {
      final token = await getToken();
      final budgetLimits = parseBudgetRange(selectedBudgetRange);

      // Use the correct API endpoint
      final response = await http.get(
        Uri.parse('http://api.atchadhai.com/api/user/packages'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Adjust based on the actual response structure
        List<dynamic> allPackages =
            data is List ? data : data['packages'] ?? [];
        print('All Packages: $allPackages');

        // Filter packages by serviceType and budget range
        List<dynamic> filteredVendors =
            allPackages.where((package) {
              // Match serviceType with selected category
              bool categoryMatch =
                  package['serviceType'] == widget.selectedCategory;

              if (!categoryMatch) return false;

              // Handle packagePrice as number or string
              double packagePrice = 0.0;
              if (package['packagePrice'] is num) {
                packagePrice = package['packagePrice'].toDouble();
              } else if (package['packagePrice'] is String) {
                packagePrice =
                    double.tryParse(
                      package['packagePrice']
                          .replaceAll('Rs ', '')
                          .replaceAll(',', ''),
                    ) ??
                    0.0;
              }

              print(
                'Checking package: ${package['packageName']}, ServiceType: ${package['serviceType']}, Price: $packagePrice, Range: ${budgetLimits['min']} - ${budgetLimits['max']}',
              );

              return packagePrice >= budgetLimits['min']! &&
                  (budgetLimits['max']! == double.infinity || packagePrice <= budgetLimits['max']!);
            }).toList();

        print('Filtered Vendors: $filteredVendors');

        setState(() {
          vendors = filteredVendors;
          isLoadingVendors = false;
          showVendors = true;
        });
      } else {
        setState(() {
          isLoadingVendors = false;
          errorMessage = 'Failed to load vendors: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoadingVendors = false;
        errorMessage = 'Error fetching vendors: $e';
      });
      print('Error fetching vendors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.selectedCategory} Budget',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Budget Selection Card
                  Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Category Header
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE0F7FA),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Image.asset(
                                      widget.categoryImage,
                                      fit: BoxFit.contain,
                                      color: Color(0xFF00838F),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  widget.selectedCategory,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Recommended: ${budgetPercentage.toInt()}% of total budget',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32),

                          // Circular Progress Indicator
                          Container(
                            width: 180,
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF00E7AC),
                                        Color(0xFF00B8E4),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${budgetPercentage.toInt()}%',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'of budget',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32),

                          // Budget Range Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Your Budget Range',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedBudgetRange.isEmpty ? null : selectedBudgetRange,
                                  hint: Text(
                                    'Choose budget range',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  items: currentCategoryBudgetRanges.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBudgetRange = value!;
                                      showVendors = false;
                                      vendors.clear();
                                      print(
                                        'Selected budget range: $selectedBudgetRange',
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 32),

                          // Budget Tips
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: Colors.blue[700],
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Budget Tip',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _getBudgetTip(widget.selectedCategory),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue[800],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Vendors List
                  if (showVendors) ...[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.store,
                                color: Color(0xFF00838F),
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Available Vendors',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Vendors within your budget range: $selectedBudgetRange',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 16),

                          if (isLoadingVendors)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00B8E4),
                                ),
                              ),
                            )
                          else if (errorMessage != null)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else if (vendors.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No vendors found in this budget range',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Try selecting a different budget range',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: vendors.length,
                              itemBuilder: (context, index) {
                                print('Rendering vendor: ${vendors[index]}');
                                final vendor = vendors[index];
                                return _buildVendorCard(vendor);
                              },
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    selectedBudgetRange.isNotEmpty
                        ? () {
                          fetchVendorsInBudgetRange(); // Always fetch vendors when button is pressed
                          if (showVendors && vendors.isNotEmpty) {
                            // Confirm budget allocation
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Budget allocated: $selectedBudgetRange for ${widget.selectedCategory}',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient:
                        selectedBudgetRange.isNotEmpty
                            ? LinearGradient(
                              colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                            )
                            : null,
                    color:
                        selectedBudgetRange.isEmpty ? Colors.grey[300] : null,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Center(
                    child: Text(
                      showVendors && vendors.isNotEmpty
                          ? 'Confirm Budget Allocation'
                          : 'Find Vendors',
                      style: TextStyle(
                        color:
                            selectedBudgetRange.isNotEmpty
                                ? Colors.white
                                : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.business, color: Color(0xFF00838F), size: 24),
        ),
        title: Text(
          vendor['packageName'] ?? 'Unnamed Package',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              vendor['description'] ?? 'No description available',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'Rs ${vendor['packagePrice']?.toStringAsFixed(0) ?? '0'}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () {
          // Navigate to AvailabilityCalendar page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AvailabilityCalendar(
                    vendorId: vendor['vendorId']?.toString() ?? '',
                    serviceId: vendor['serviceId']?.toString() ?? '',
                    packageId: vendor['_id']?.toString(),
                    vendorName: vendor['vendorName'] ?? 'Unknown Vendor',
                  ),
            ),
          );
        },
      ),
    );
  }

  String _getBudgetTip(String category) {
    final tips = {
      'Photography':
          'Consider booking early for better rates. Don\'t forget to budget for engagement and pre-wedding shoots.',
      'Decoration':
          'DIY some elements to save money. Rent instead of buying when possible.',
      'Beautician':
          'Book a trial run 1-2 months before. Consider packages for bridal party.',
      'Wedding Hall':
          'This is typically your largest expense. Book 12-18 months in advance for better pricing.',
      'Wedding Cars':
          'Book early, especially during wedding season. Consider guest transportation too.',
      'Invitation Cards':
          'Digital invitations can significantly reduce costs and are eco-friendly.',
      'Catering':
          'Clarify per-plate costs and minimum guest requirements to avoid surprises.',
      'Gift Items':
          'Consider bulk purchases or personalized items to stay within budget.',
      'Sweets & Cakes':
          'Consider a smaller display cake with sheet cakes for serving to reduce costs.',
      'Garland':
          'Use seasonal flowers to reduce costs. Discuss designs with your florist.',
      'Iyer': 'Religious ceremonies may have additional donation expectations.',
      'Mangala Vathiyam':
          'Live music costs vary by troupe size. Clarify performance duration.',
      'Outdoor Setup':
          'Check venue restrictions for outdoor setups to avoid extra fees.',
      'DJ': 'Ensure the DJ package includes lighting and sound equipment.',
      'Kolam':
          'Simple designs can be cost-effective. Discuss complexity with the artist.',
      'Mehndi Artist':
          'Book early for intricate designs. Group rates may apply for bridal party.',
      'Live Music Troupe':
          'Live bands cost more than DJs. Consider the venue size for audio needs.',
      'Jewellery & Accessories':
          'Shop around and consider family heirlooms. Insurance is recommended.',
      'Wedding Attire':
          'Don\'t forget alterations, shoes, and accessories in your budget.',
    };
    return tips[category] ??
        'Research multiple vendors and compare packages for the best value.';
  }
}