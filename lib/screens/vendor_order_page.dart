import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wedding_planner/services/booking_service.dart';
import 'vendor_upcoming_page.dart';

class VendorOrderPage extends StatefulWidget {
  @override
  _VendorOrderPageState createState() => _VendorOrderPageState();
}

class _VendorOrderPageState extends State<VendorOrderPage> {
  late Future<List<dynamic>> _bookingsFuture;
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _bookingService.getMyBookings();
  }

  // Method to refresh bookings
  void _refreshBookings() {
    setState(() {
      _bookingsFuture = _bookingService.getMyBookings();
    });
  }

  // Helper to format date strings
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No bookings found.'));
            }

            // Filter bookings by status
            final allBookings = snapshot.data!;
            final pendingBookings = allBookings.where((b) => b['status'] == 'pending').toList();
            final confirmedBookings = allBookings.where((b) => b['status'] == 'confirmed').toList();
            final rejectedBookings = allBookings.where((b) => b['status'] == 'rejected').toList();

            return TabBarView(
              children: [
                // Requests Tab (Pending)
                _buildBookingList(pendingBookings),
                // Confirmed Tab
                _buildBookingList(confirmedBookings),
                // Rejected Tab
                _buildBookingList(rejectedBookings),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Planning',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the list of booking cards
  Widget _buildBookingList(List<dynamic> bookings) {
    if (bookings.isEmpty) {
      return Center(child: Text('No bookings in this category.'));
    }
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final customer = booking['customerId'] ?? {};

        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                customer['profilePictureUrl'] ?? 'https://via.placeholder.com/150',
              ),
            ),
            title: Text(customer['name'] ?? 'Customer Name'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_formatDate(booking['date'])} at ${booking['time'].join(', ')}'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () async {
              // Navigate to detail page and wait for result
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VendorUpcomingPage(booking: booking),
                ),
              );
              // Refresh bookings after returning from detail page
              _refreshBookings();
            },
          ),
        );
      },
    );
  }
}