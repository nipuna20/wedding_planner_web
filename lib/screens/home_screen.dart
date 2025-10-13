import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/show_task_page.dart';
import 'package:wedding_planner/widgets/bottom_navbar.dart';
import '../widgets/side_menu_drawer.dart';
import '../services/guest_service.dart';
import '../services/user_service.dart';
import '../services/service_service.dart';
import '../services/booking_service.dart';
import '../models/service.dart';
import 'notification_screen.dart';
import 'vendor_search_page.dart';
import 'choose_category_screen.dart';
import 'wedding_vendor_page.dart';
import 'checklist_screen.dart';
import 'booked_vendors_screen.dart';
import 'shortlisted_vendors_screen.dart';
import 'guest_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Timer? _timer;
  List<Map<String, dynamic>> guests = [];
  List<Map<String, dynamic>> tasks = [];
  List<Service> categoryVendors = [];
  int _bookedVendorsCount = 0;
  bool _isLoadingBookings = true;
  late Future<List<dynamic>> _bookingsFuture;
  List<String> _clearedNotificationIds = [];

  final DateTime weddingDate = DateTime(2025, 12, 4);

  final List<Map<String, dynamic>> _vendorCategories = [
    {'label': 'Decoration', 'image': 'assets/images/decoration.png'},
    {'label': 'Photography', 'image': 'assets/images/photography.png'},
    {'label': 'Beautician', 'image': 'assets/images/beautician.png'},
    {'label': 'Wedding Hall', 'image': 'assets/images/wedding_hall.png'},
    {'label': 'Wedding Cars', 'image': 'assets/images/wedding_cars.png'},
    {'label': 'Iyer', 'image': 'assets/images/iyer.png'},
  ];

  Map<String, String> getCountdown() {
    final now = DateTime.now();
    final difference = weddingDate.difference(now);

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return {
      'days': days.toString().padLeft(2, '0'),
      'hours': hours.toString().padLeft(2, '0'),
      'minutes': minutes.toString().padLeft(2, '0'),
      'seconds': seconds.toString().padLeft(2, '0'),
    };
  }

  Future<void> fetchGuests() async {
    try {
      final data = await GuestService.getGuests();
      setState(() {
        guests = data;
      });
    } catch (e) {
      print('Error fetching guests: $e');
    }
  }

  Future<void> fetchTasks() async {
    try {
      final data = await UserService.getTasks();
      setState(() {
        tasks = data;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> fetchCategoryVendors() async {
    try {
      List<Service> vendors = [];
      for (var category in _vendorCategories) {
        final services = await ServiceService().getAllServices(
          '',
          serviceType: category['label'].toString().toLowerCase(),
        );
        if (services.isNotEmpty) {
          vendors.add(services.first);
        }
      }
      setState(() {
        categoryVendors = vendors;
      });
    } catch (e) {
      print('Error fetching category vendors: $e');
    }
  }

  Future<void> fetchBookedVendorsCount() async {
    try {
      final bookings = await BookingService().getMyBookings();
      setState(() {
        _bookedVendorsCount = bookings.length;
        _isLoadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _bookedVendorsCount = 0;
        _isLoadingBookings = false;
      });
      print('Error fetching booked vendors count: $e');
    }
  }

  Future<void> fetchCustomerBookings() async {
    try {
      _bookingsFuture = BookingService().getMyBookings();
      await _loadClearedNotifications();
    } catch (e) {
      print('Error fetching customer bookings: $e');
    }
  }

  // Load cleared notification IDs
  Future<void> _loadClearedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _clearedNotificationIds = prefs.getStringList('cleared_notifications') ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchGuests();
    fetchTasks();
    fetchCategoryVendors();
    fetchBookedVendorsCount();
    fetchCustomerBookings();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onScreenResume() {
    fetchGuests();
    fetchTasks();
    fetchCategoryVendors();
    fetchBookedVendorsCount();
    fetchCustomerBookings();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final countdown = getCountdown();
    final totalGuests = guests.length;
    final invitationsSent =
        guests.where((g) => g['invitationSent'] == true).length;
    final confirmedAttendance =
        guests.where((g) => g['confirmed'] == true).length;
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) {
      if (task['subtasks'] != null && task['subtasks'].isNotEmpty) {
        return task['subtasks'].every((subtask) => subtask['completed'] == true);
      }
      return task['completed'] == true;
    }).length;

    return Scaffold(
      drawer: const SideMenuDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          FutureBuilder<List<dynamic>>(
            future: _bookingsFuture,
            builder: (context, snapshot) {
              int notificationCount = 0;
              if (snapshot.hasData && snapshot.data != null) {
                notificationCount = snapshot.data!
                    .where((b) =>
                        (b['status'] == 'confirmed' || b['status'] == 'rejected' || b['status'] == 'pending') &&
                        !_clearedNotificationIds.contains(b['_id']?.toString()))
                    .length;
              }
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      ).then((_) => _onScreenResume());
                    },
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth > 600 ? 32 : 16),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: screenWidth > 600 ? 450 : 300,
                    height: screenWidth > 600 ? 450 : 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/frame.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 70,
                    child: Column(
                      children: [
                        const Text(
                          'Liza & Shefan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCountdownTile(countdown['days']!, 'Days'),
                            _buildCountdownTile(countdown['hours']!, 'Hours'),
                            _buildCountdownTile(countdown['minutes']!, 'Mins'),
                            _buildCountdownTile(countdown['seconds']!, 'Secs'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Until Our Wedding',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '12/04/2025',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionHeader(
              'Book Vendors',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChooseCategoryScreen(),
                  ),
                ).then((_) => _onScreenResume());
              },
            ),
            SizedBox(
              height: screenWidth > 600 ? 120 : 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _vendorCategories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _vendorCategories.length - 1 ? 12 : 0,
                    ),
                    child: _categoryCard(
                      image: _vendorCategories[index]['image'],
                      label: _vendorCategories[index]['label'],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _sectionHeader(
              'All Vendors',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VendorSearchPage(category: 'all'),
                  ),
                ).then((_) => _onScreenResume());
              },
            ),
            SizedBox(
              height: screenWidth > 600 ? 210 : 190,
              child: categoryVendors.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryVendors.length,
                      itemBuilder: (context, index) {
                        final vendor = categoryVendors[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WeddingVendorPage(
                                  service: vendor.toJson(),
                                ),
                              ),
                            ).then((_) => _onScreenResume());
                          },
                          child: Container(
                            width: screenWidth > 600 ? 180 : 140,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: vendor.mediaUrls.isNotEmpty
                                      ? Image.network(
                                          vendor.mediaUrls[0],
                                          height: 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            'assets/images/proposalImage.png',
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/proposalImage.png',
                                          height: 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vendor.serviceName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.teal,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              vendor.vendorName,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            _customInfoCard(
              title: 'Tasks',
              icon: Icons.check_box,
              leftValue: totalTasks.toString(),
              leftLabel: 'All Tasks',
              rightValue: completedTasks.toString(),
              rightLabel: 'Completed Tasks',
            ),
            const SizedBox(height: 10),
            _customInfoCard(
              title: 'Vendors',
              icon: Icons.store,
              leftValue: _isLoadingBookings
                  ? '...'
                  : _bookedVendorsCount.toString().padLeft(2, '0'),
              leftLabel: 'Booked Vendors',
              rightValue: '09',
              rightLabel: 'Shortlisted Vendors',
            ),
            const SizedBox(height: 10),
            _customInfoCard(
              title: 'Guests',
              icon: Icons.people,
              leftValue: totalGuests.toString(),
              leftLabel: 'Total Guests',
              leftLabelFontSize: 14,
              leftLabelFontWeight: FontWeight.bold,
              rightItems: [
                {
                  'icon': Icons.mail_outline,
                  'label': 'Given an Invitations',
                  'value': invitationsSent.toString(),
                },
                {
                  'icon': Icons.verified,
                  'label': 'Confirmed attendance',
                  'value': confirmedAttendance.toString(),
                },
              ],
            ),
            const SizedBox(height: 10),
            _customInfoCard(
              title: 'Budget',
              icon: Icons.savings,
              leftValue: '\Rs 8,960',
              leftLabel: 'Current Budget',
              rightValue: '\Rs 25,000',
              rightLabel: 'Total Budget',
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              _onScreenResume();
            }
          },
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF007D8C)),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: () {},
    );
  }

  Widget _buildCountdownTile(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: const Text('View All', style: TextStyle(color: Colors.teal)),
        ),
      ],
    );
  }

  Widget _categoryCard({required String image, required String label}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VendorSearchPage(category: label.toLowerCase()),
          ),
        ).then((_) => _onScreenResume());
      },
      child: Container(
        width: screenWidth > 600 ? 120 : 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 30, height: 30, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _customInfoCard({
    required String title,
    IconData? icon,
    String? leftValue,
    String? leftLabel,
    double? leftLabelFontSize,
    FontWeight? leftLabelFontWeight,
    String? rightValue,
    String? rightLabel,
    List<Map<String, dynamic>>? rightItems,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: const Color(0xFF007D8C), size: 20),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      if (title == 'Tasks') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ShowTaskPage()),
                        ).then((_) => _onScreenResume());
                      } else if (title == 'Vendors') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BookedVendorsScreen(),
                          ),
                        ).then((_) => _onScreenResume());
                      } else if (title == 'Guests') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuestListScreen(),
                          ),
                        ).then((_) => _onScreenResume());
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (leftLabel != null && leftLabel.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                leftLabel,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: leftLabelFontSize ?? 12,
                                  fontWeight: leftLabelFontWeight,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          Text(
                            leftValue ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007D8C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  flex: 1,
                  child: rightItems == null
                      ? InkWell(
                          onTap: () {
                            if (title == 'Tasks') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckListScreen(),
                                ),
                              ).then((_) => _onScreenResume());
                            } else if (title == 'Vendors') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ShortListedVendorsScreen(),
                                ),
                              ).then((_) => _onScreenResume());
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  rightValue ?? '',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF007D8C),
                                  ),
                                ),
                                if (rightLabel != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      rightLabel,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: rightItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'],
                                    size: 18,
                                    color: const Color(0xFF007D8C),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item['label'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item['value'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF007D8C),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}