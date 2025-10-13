import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/availability_calendar.dart';
import 'package:wedding_planner/services/package_service.dart';

class SelectPackagePage extends StatefulWidget {
  final String vendorId;
  final String serviceId;
  final String vendorName;

  SelectPackagePage({
    required this.vendorId,
    required this.serviceId,
    required this.vendorName,
  });

  @override
  _SelectPackagePageState createState() => _SelectPackagePageState();
}

class _SelectPackagePageState extends State<SelectPackagePage> {
  String? selectedPackage;
  final TextEditingController _customPriceController = TextEditingController();
  String customPrice = 'Rs.500.00';
  late Future<List<dynamic>> _packagesFuture;

  @override
  void initState() {
    super.initState();
    _packagesFuture = PackageService().getAllPackages();
    _customPriceController.text = '500.00';
    _customPriceController.addListener(() {
      setState(() {
        String input = _customPriceController.text;
        if (input.isNotEmpty && double.tryParse(input) != null) {
          customPrice = 'Rs.$input';
        } else {
          customPrice = 'Rs.500.00';
        }
      });
    });
  }

  @override
  void dispose() {
    _customPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Package',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<List<dynamic>>(
              future: _packagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading packages'));
                }
                final packages =
                    snapshot.data
                        ?.where(
                          (pkg) =>
                              pkg['serviceId'] == widget.serviceId &&
                              pkg['vendorId'] == widget.vendorId,
                        )
                        .toList() ??
                    [];
                if (packages.isEmpty) {
                  return Center(child: Text('No packages available'));
                }
                if (selectedPackage == null && packages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      selectedPackage = packages[0]['_id'];
                    });
                  });
                }
                return Column(
                  children:
                      packages
                          .asMap()
                          .entries
                          .map(
                            (entry) => Column(
                              children: [
                                _buildPackageCard(
                                  entry.value['_id'],
                                  entry.value['packageName'] ??
                                      'Unnamed Package',
                                  'Rs.${entry.value['packagePrice'].toStringAsFixed(2)}',
                                  entry.value['description'] ??
                                      'No description available',
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          )
                          .toList(),
                );
              },
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    selectedPackage != null
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AvailabilityCalendar(
                                    vendorId: widget.vendorId,
                                    serviceId: widget.serviceId,
                                    packageId: selectedPackage,
                                    vendorName: widget.vendorName,
                                  ),
                            ),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Ink(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      'Show Availability',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget _buildPackageCard(
    String value,
    String title,
    String price,
    String description,
  ) {
    bool isSelected = selectedPackage == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPackage = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xFF00D4AA) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected ? Color(0xFF00D4AA) : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? Color(0xFF00D4AA) : Colors.transparent,
                  ),
                  child:
                      isSelected
                          ? Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                ),
              ],
            ),
            SizedBox(height: 8),
            if (value == 'customized' && isSelected)
              TextField(
                controller: _customPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter Custom Price',
                  prefixText: 'Rs.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4AA),
                ),
              )
            else
              Text(
                price,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4AA),
                ),
              ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
