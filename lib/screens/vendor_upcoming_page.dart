import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wedding_planner/services/service_service.dart';
import 'package:wedding_planner/services/package_service.dart';
import 'package:wedding_planner/services/booking_service.dart';
import 'package:wedding_planner/screens/chat_detail_screen.dart';

class VendorUpcomingPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onStatusChanged; // Callback for status change

  const VendorUpcomingPage({super.key, required this.booking, this.onStatusChanged});

  @override
  _VendorUpcomingPageState createState() => _VendorUpcomingPageState();
}

class _VendorUpcomingPageState extends State<VendorUpcomingPage> {
  final ServiceService _serviceService = ServiceService();
  final PackageService _packageService = PackageService();
  final BookingService _bookingService = BookingService();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.booking['status'] ?? 'pending';
  }

  // Helper to format date strings
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Helper to format currency
  String _formatPrice(dynamic price) {
    if (price == null) return 'Price not available';
    if (price is num) {
      return '\Rs${price.toStringAsFixed(2)}';
    }
    return price.toString();
  }

  // Handle status change
  Future<void> _updateBookingStatus(String? newStatus) async {
    if (newStatus == null || newStatus == _selectedStatus) return;

    try {
      if (newStatus == 'confirmed') {
        await _bookingService.confirmBooking(widget.booking['_id']);
      } else if (newStatus == 'rejected') {
        await _bookingService.rejectBooking(widget.booking['_id']);
      } else {
        await _bookingService.updateBookingStatus(
          widget.booking['_id'],
          status: newStatus,
        );
      }

      setState(() {
        _selectedStatus = newStatus;
        widget.booking['status'] = newStatus; // Update local booking status
      });

      // Notify parent widget of status change
      widget.onStatusChanged?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.booking['customerId'] ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Appointments')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            customer['profilePictureUrl'] ??
                                'https://via.placeholder.com/150',
                          ),
                        ),
                        title: Text(customer['name'] ?? 'Customer Name'),
                        subtitle: Text(customer['phone'] ?? 'No phone number'),
                        trailing: IconButton(
                          icon: const Icon(Icons.chat, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  otherUserId: customer['_id'],
                                  otherUserName: customer['name'] ?? 'Customer Name',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text('Date: ${_formatDate(widget.booking['date'])}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text('Time: ${widget.booking['time'].join(', ')}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text('Location: ${widget.booking['address']}'),
                      ),
                      FutureBuilder(
                        future: _serviceService.getServiceById(
                          widget.booking['serviceId'],
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text('Loading service type...'),
                            );
                          } else if (snapshot.hasError) {
                            return const ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text('Error loading service type'),
                            );
                          } else if (snapshot.hasData && snapshot.data != null) {
                            final service = snapshot.data!;
                            return ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: Text('Service type: ${service.serviceType}'),
                            );
                          } else {
                            return const ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text('Service type: Unknown'),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          _selectedStatus == 'confirmed'
                              ? Icons.check_circle
                              : _selectedStatus == 'rejected'
                                  ? Icons.cancel
                                  : Icons.pending,
                          color: _selectedStatus == 'confirmed'
                              ? Colors.green
                              : _selectedStatus == 'rejected'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                        title: DropdownButton<String>(
                          value: _selectedStatus,
                          hint: const Text('Select status'),
                          isExpanded: true,
                          items: ['pending', 'confirmed', 'rejected']
                              .map((status) => DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(
                                      status[0].toUpperCase() + status.substring(1),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (newValue) => _updateBookingStatus(newValue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Package Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.booking['packageId'] != null &&
                          widget.booking['packageId'].isNotEmpty)
                        FutureBuilder<Map<String, dynamic>?>(
                          future: _packageService.getPackageById(widget.booking['packageId']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Loading package details...'),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(height: 8),
                                  Text('Error loading package: ${snapshot.error}'),
                                ],
                              );
                            } else if (snapshot.hasData && snapshot.data != null) {
                              final packageData = snapshot.data!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    packageData['packageName'] ?? 'Package Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatPrice(packageData['packagePrice']),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (packageData['description'] != null &&
                                      packageData['description'].isNotEmpty)
                                    Text(
                                      packageData['description'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    )
                                  else
                                    const Text(
                                      'No description available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              );
                            } else {
                              return const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.warning, color: Colors.orange),
                                  SizedBox(height: 8),
                                  Text(
                                    'Package details not found',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ],
                              );
                            }
                          },
                        )
                      else
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(height: 8),
                            Text(
                              'No package selected for this booking',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                    ],
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