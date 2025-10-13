import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/shortlisted_vendors_screen.dart';
import 'package:wedding_planner/widgets/bottom_navbar.dart';
import 'package:wedding_planner/screens/booked_vendors_screen.dart';
import 'package:wedding_planner/screens/vendor_search_page.dart';
import 'package:wedding_planner/services/booking_service.dart';

class VendorDirectoryScreen extends StatefulWidget {
  const VendorDirectoryScreen({super.key});

  @override
  State<VendorDirectoryScreen> createState() => _VendorDirectoryScreenState();
}

class _VendorDirectoryScreenState extends State<VendorDirectoryScreen> {
  int _currentIndex = 1;
  int _bookedVendorsCount = 0;
  bool _isLoadingCount = true;

  final List<Map<String, dynamic>> _vendorCategories = [
    {'label': 'Decoration', 'image': 'assets/images/decoration.png'},
    {'label': 'Photography', 'image': 'assets/images/photography.png'},
    {'label': 'Beautician', 'image': 'assets/images/beautician.png'},
    {'label': 'Wedding Hall', 'image': 'assets/images/wedding_hall.png'},
    {'label': 'Wedding Cars', 'image': 'assets/images/wedding_cars.png'},
    {
      'label': 'Invitation Cards',
      'image': 'assets/images/invitation_cards.png',
    },
    {'label': 'Catering', 'image': 'assets/images/catering.png'},
    {'label': 'Gift Items', 'image': 'assets/images/gift_items.png'},
    {'label': 'Sweets & Cakes', 'image': 'assets/images/sweets_cakes.png'},
    {'label': 'Garland', 'image': 'assets/images/garland.png'},
    {'label': 'Iyer', 'image': 'assets/images/iyer.png'},
    {
      'label': 'Mangala Vathiyam',
      'image': 'assets/images/mangala_vathiyam.png',
    },
    {'label': 'Outdoor Setup', 'image': 'assets/images/outdoor_setup.png'},
    {'label': 'DJ', 'image': 'assets/images/dj.png'},
    {'label': 'Kolam', 'image': 'assets/images/kolam.png'},
    {'label': 'Mehndi Artist', 'image': 'assets/images/mehndi_artist.png'},
    {
      'label': 'Live Music Troupe',
      'image': 'assets/images/live_music_troupe.png',
    },
    {
      'label': 'Jewellery & Accessories',
      'image': 'assets/images/jewellery_accessories.png',
    },
    {'label': 'Wedding Attire', 'image': 'assets/images/wedding_attire.png'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookedVendorsCount();
  }

  Future<void> _fetchBookedVendorsCount() async {
    try {
      final bookings = await BookingService().getMyBookings();
      setState(() {
        _bookedVendorsCount = bookings.length;
        _isLoadingCount = false;
      });
    } catch (e) {
      setState(() {
        _bookedVendorsCount = 0;
        _isLoadingCount = false;
      });
      print('Error fetching booked vendors count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Vendors', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: _fetchBookedVendorsCount,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search the vendors...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Booked & Shortlisted
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCard(
                        'Booked Vendors',
                        _isLoadingCount
                            ? '...'
                            : _bookedVendorsCount.toString().padLeft(2, '0'),
                        () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BookedVendorsScreen(),
                            ),
                          );
                          // Refresh count when returning from BookedVendorsScreen
                          if (result == true || result == null) {
                            _fetchBookedVendorsCount();
                          }
                        },
                      ),
                      _statCard('Shortlisted Vendors', '09', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ShortListedVendorsScreen(),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Category grid
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: GridView.builder(
                      itemCount: _vendorCategories.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (constraints.maxWidth < 600) ? 3 : 5,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final category = _vendorCategories[index];
                        return _categoryCard(
                          image: category['image'],
                          label: category['label'],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String title, String count, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF00B8E4),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCard({required String image, required String label}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VendorSearchPage(category: label)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: 30,
              height: 30,
              color: const Color(0xFF00B8E4), // Optional: Apply color tint
              fit: BoxFit.contain,
            ),
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
}
