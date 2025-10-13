import 'package:flutter/material.dart';
import 'package:wedding_planner/services/booking_service.dart';
import 'package:wedding_planner/services/package_service.dart';

class PaymentPage extends StatefulWidget {
  final String vendorId;
  final String serviceId;
  final String? packageId;
  final String bookingId;
  final String date;
  final List<String> time;
  final String address;
  final String vendorName;

  PaymentPage({
    required this.vendorId,
    required this.serviceId,
    this.packageId,
    required this.bookingId,
    required this.date,
    required this.time,
    required this.address,
    required this.vendorName,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'card';
  Map<String, dynamic>? packageDetails;
  Map<String, dynamic>? vendorDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      // Fetch package details
      final packages = await PackageService().getAllPackages();
      final package = packages.firstWhere(
        (pkg) =>
            pkg['_id'] == widget.packageId &&
            pkg['serviceId'] == widget.serviceId &&
            pkg['vendorId'] == widget.vendorId,
        orElse: () => null,
      );

      // Use the passed vendorName
      final vendor = {
        'name': widget.vendorName,
        'address':
            '45 Elm Street, Los Angeles, USA', // Replace with VendorService call if needed
      };

      if (mounted) {
        setState(() {
          packageDetails = package;
          vendorDetails = vendor;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPayment(String paymentType) async {
    try {
      // Update booking status to completed and set payment type
      await BookingService().updateBooking(
        widget.bookingId,
        paymentType: paymentType,
      );
      await BookingService().updateBookingStatus(
        widget.bookingId,
        status: 'completed',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$paymentType Payment Completed!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to home or confirmation page
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double packagePrice =
        packageDetails != null
            ? (packageDetails!['packagePrice'] as num).toDouble()
            : 500.00;
    double platformFee = packagePrice * 0.02;
    double subTotal = packagePrice + platformFee;

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
          'Payment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.teal))
              : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor Details
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade300,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vendorDetails?['name'] ?? 'Vendor Name',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          vendorDetails?['address'] ??
                                              'Vendor Address',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${widget.date} ${widget.time.join(", ")}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        // Package Selected
                        Text(
                          'Package Selected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          packageDetails?['packageName'] ?? 'Unnamed Package',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Rs. ${packagePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00D4AA),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          packageDetails?['description'] ??
                              'No description available',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 24),
                        // Payment Method
                        Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildPaymentMethodTile('card', 'Credit / Debit Card'),
                        SizedBox(height: 24),
                        // Booking Info
                        Text(
                          'Booking Info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sub Total', style: TextStyle(fontSize: 14)),
                            Text(
                              'Rs. ${subTotal.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '2% Platform Fee',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Rs. ${platformFee.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        // Payment Buttons
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  _processPayment('full');
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Ink(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF00E7AC),
                                        Color(0xFF00B8E4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Full Payment',
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
                            SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  _processPayment('advance');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.transparent),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Ink(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF00E7AC),
                                        Color(0xFF00B8E4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Advance Payment',
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
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildPaymentMethodTile(String value, String title) {
    bool isSelected = selectedPaymentMethod == value;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Color(0xFF00D4AA) : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Color(0xFF00D4AA) : Colors.grey.shade400,
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
    );
  }
}
