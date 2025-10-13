import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wedding_planner/screens/vendor-packages.dart';
import 'package:wedding_planner/screens/wendor_review_page.dart';
import 'package:wedding_planner/services/booking_service.dart';
import 'package:wedding_planner/screens/vendor_upcoming_page.dart';
import 'package:wedding_planner/widgets/vendor_navbar.dart';
import 'package:wedding_planner/screens/add_availability_screen.dart';
import 'package:wedding_planner/services/user_service.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _currentIndex = 0;
  late Future<List<dynamic>> _bookingsFuture;
  final BookingService _bookingService = BookingService();
  String? _vendorId;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _bookingService.getMyBookings();
    _fetchVendorId();
  }

  Future<void> _fetchVendorId() async {
    try {
      final profile = await UserService.getProfile();
      if (profile != null && profile['user'] != null) {
        setState(() {
          _vendorId = profile['user']['_id'].toString();
        });
      }
    } catch (e) {
      print('Error fetching vendor ID: $e');
    }
  }

  void handleNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Refresh bookings
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

  // Calculate responsive sizes based on screen width
  double _getResponsiveSize(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  // Determine GridView crossAxisCount based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 600 ? 3 : 2; // 3 columns for tablets, 2 for phones
  }

  // Responsive font size for titles
  double _getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 600 ? 24 : 18;
  }

  // Responsive font size for feature labels
  double _getFeatureLabelFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 600 ? 16 : 14;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/vendorlogo.png',
          height: _getResponsiveSize(context, 0.1),
          fit: BoxFit.contain,
        ),
        actions: [
          FutureBuilder<List<dynamic>>(
            future: _bookingsFuture,
            builder: (context, snapshot) {
              int pendingCount = 0;
              if (snapshot.hasData && snapshot.data != null) {
                pendingCount = snapshot.data!.where((b) => b['status'] == 'pending').length;
              }
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                        final pendingBookings = snapshot.data!.where((b) => b['status'] == 'pending').toList();
                        if (pendingBookings.isNotEmpty) {
                          final firstBooking = pendingBookings.first;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VendorUpcomingPage(
                                booking: firstBooking,
                                onStatusChanged: _refreshBookings,
                              ),
                            ),
                          );
                        } else {
                          // Optional: Show a message if no pending bookings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No pending bookings available'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      } else {
                        // Optional: Show a message if data is not loaded
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Loading bookings...'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                      size: _getResponsiveSize(context, 0.07),
                    ),
                  ),
                  if (pendingCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$pendingCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            _getResponsiveSize(context, 0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: _getResponsiveSize(context, 0.045),
                ),
              ),
              SizedBox(height: _getResponsiveSize(context, 0.025)),
              _highlightCard(context),
              SizedBox(height: _getResponsiveSize(context, 0.05)),
              GridView.count(
                crossAxisCount: _getCrossAxisCount(context),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isLandscape ? 1.5 : 1.2,
                crossAxisSpacing: _getResponsiveSize(context, 0.03),
                mainAxisSpacing: _getResponsiveSize(context, 0.03),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VendorReviewPage(),
                        ),
                      );
                    },
                    child: _featureTile(
                      context,
                      Icons.star,
                      'Rating & Reviews',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VendorPackagesScreen(),
                        ),
                      );
                    },
                    child: _featureTile(
                      context,
                      Icons.card_giftcard,
                      'Packages',
                    ),
                  ),
                  _featureTile(context, Icons.monetization_on, 'Earnings'),
                  GestureDetector(
                    onTap: () {
                      if (_vendorId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddAvailabilityScreen(vendorId: _vendorId!),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Vendor ID not found. Please try again.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: _featureTile(
                      context,
                      Icons.calendar_month,
                      'Availability',
                    ),
                  ),
                ],
              ),
              SizedBox(height: _getResponsiveSize(context, 0.05)),
              Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: _getResponsiveSize(context, 0.045),
                ),
              ),
              SizedBox(height: _getResponsiveSize(context, 0.025)),
              FutureBuilder<List<dynamic>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading bookings'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No upcoming appointments'),
                    );
                  }

                  final upcomingBookings =
                      snapshot.data!.where((b) => b['status'] == 'pending').toList();

                  if (upcomingBookings.isEmpty) {
                    return const Center(
                      child: Text('No upcoming appointments'),
                    );
                  }

                  return Column(
                    children: upcomingBookings.map((booking) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: _getResponsiveSize(context, 0.025),
                        ),
                        child: _appointmentTile(context, booking),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: _getResponsiveSize(context, 0.2),
        child: VendorNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _highlightCard(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF007D8C),
              borderRadius: BorderRadius.circular(
                _getResponsiveSize(context, 0.04),
              ),
            ),
            padding: EdgeInsets.all(_getResponsiveSize(context, 0.03)),
            child: Text(
              'No upcoming appointments',
              style: TextStyle(
                color: Colors.white,
                fontSize: _getResponsiveSize(context, 0.04),
              ),
            ),
          );
        }

        final upcomingBookings =
            snapshot.data!.where((b) => b['status'] == 'pending').toList();

        if (upcomingBookings.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF007D8C),
              borderRadius: BorderRadius.circular(
                _getResponsiveSize(context, 0.04),
              ),
            ),
            padding: EdgeInsets.all(_getResponsiveSize(context, 0.03)),
            child: Text(
              'No upcoming appointments',
              style: TextStyle(
                color: Colors.white,
                fontSize: _getResponsiveSize(context, 0.04),
              ),
            ),
          );
        }

        final booking = upcomingBookings.first;
        final customer = booking['customerId'] ?? {};

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorUpcomingPage(
                  booking: booking,
                  onStatusChanged: _refreshBookings,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF007D8C),
              borderRadius: BorderRadius.circular(
                _getResponsiveSize(context, 0.04),
              ),
            ),
            padding: EdgeInsets.all(_getResponsiveSize(context, 0.03)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    _getResponsiveSize(context, 0.03),
                  ),
                  child: Image.network(
                    customer['profilePictureUrl'] ??
                        'https://via.placeholder.com/150',
                    width: _getResponsiveSize(context, 0.12),
                    height: _getResponsiveSize(context, 0.12),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/profilepic.jpg',
                      width: _getResponsiveSize(context, 0.12),
                      height: _getResponsiveSize(context, 0.12),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: _getResponsiveSize(context, 0.025)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer['name'] ?? 'Customer Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: _getResponsiveSize(context, 0.04),
                        ),
                      ),
                      SizedBox(height: _getResponsiveSize(context, 0.01)),
                      Text(
                        '${_formatDate(booking['date'])} ${booking['time'].join(', ')}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: _getResponsiveSize(context, 0.035),
                        ),
                      ),
                      SizedBox(height: _getResponsiveSize(context, 0.005)),
                      Text(
                        'Service type - ${booking['serviceType'] ?? 'Unknown'}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: _getResponsiveSize(context, 0.035),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: _getResponsiveSize(context, 0.045),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _featureTile(BuildContext context, IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6FFFF),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
        borderRadius: BorderRadius.circular(_getResponsiveSize(context, 0.04)),
      ),
      padding: EdgeInsets.all(_getResponsiveSize(context, 0.03)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: _getResponsiveSize(context, 0.08),
            color: const Color(0xFF00B8E4),
          ),
          SizedBox(height: _getResponsiveSize(context, 0.02)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveSize(context, 0.035),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentTile(BuildContext context, dynamic booking) {
    final customer = booking['customerId'] ?? {};
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorUpcomingPage(
              booking: booking,
              onStatusChanged: _refreshBookings,
            ),
          ),
        );
        _refreshBookings(); // Refresh on return for robustness
      },
      child: Container(
        padding: EdgeInsets.all(_getResponsiveSize(context, 0.03)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            _getResponsiveSize(context, 0.03),
          ),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                _getResponsiveSize(context, 0.02),
              ),
              child: Image.network(
                customer['profilePictureUrl'] ??
                    'https://via.placeholder.com/150',
                width: _getResponsiveSize(context, 0.12),
                height: _getResponsiveSize(context, 0.12),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/profilepic.jpg',
                  width: _getResponsiveSize(context, 0.12),
                  height: _getResponsiveSize(context, 0.12),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: _getResponsiveSize(context, 0.03)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer['name'] ?? 'Customer Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _getResponsiveSize(context, 0.04),
                    ),
                  ),
                  SizedBox(height: _getResponsiveSize(context, 0.01)),
                  Text(
                    '${_formatDate(booking['date'])} at ${booking['time'].join(', ')}',
                    style: TextStyle(
                      fontSize: _getResponsiveSize(context, 0.035),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: _getResponsiveSize(context, 0.04),
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}