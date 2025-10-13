import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wedding_planner/services/booking_service.dart'; // Import booking service
import 'package:wedding_planner/widgets/bottom_navbar.dart';
import 'package:wedding_planner/widgets/rating_dialog%20.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId; // Accept the bookingId

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  int _currentIndex = 1;
  Map<String, dynamic>? _booking; // To hold the fetched booking data
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails(); // Fetch details when the screen loads
  }

  // Function to fetch booking details from the service
  Future<void> _fetchBookingDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final bookingData = await BookingService().getBookingById(
        widget.bookingId,
      );
      setState(() {
        _booking = bookingData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Booking Details',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          _isLoading || _errorMessage.isNotEmpty || _booking == null
              ? null // Hide button while loading, on error, or if booking is null
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E7AC), Color(0xFF047284)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => RatingDialog(
                                vendorId:
                                    _booking!['vendorId']['_id'].toString(),
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Add Rating',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBookingDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_booking == null) {
      return const Center(child: Text('Booking details not found.'));
    }

    // Extract data from the booking map
    final vendor = _booking!['vendorId'] ?? {};
    final serviceName = _booking!['serviceId']?.toString() ?? 'Unknown Service';
    final vendorName = vendor['name'] ?? 'Unknown Vendor';
    final date = DateTime.tryParse(_booking!['date'] ?? '') ?? DateTime.now();
    final time = _booking!['time'] ?? 'Unknown Time';
    final formattedDate = DateFormat('d MMMM yyyy').format(date);
    final vendorImage =
        vendor['profileImage'] ?? 'assets/images/profilepic.jpg';
    final address = _booking!['address'] ?? 'No address provided';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking ID : #${_booking!['_id'].substring(0, 6)}', // Display a shortened ID
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child:
                    vendorImage.startsWith('http')
                        ? Image.network(
                          vendorImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Image.asset(
                                'assets/images/profilepic.jpg',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset(
                          vendorImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vendorName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$formattedDate · $time',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          Row(
            children: [
              const Text(
                'Date & Time : ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Expanded(child: Text('$formattedDate at $time')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Address : ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(address)),
            ],
          ),
          const SizedBox(height: 80), // Space for the floating action button
        ],
      ),
    );
  }
}
