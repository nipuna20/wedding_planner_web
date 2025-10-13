import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_planner/screens/add_availability_screen.dart';
import 'package:wedding_planner/screens/add_packages_page.dart';
import 'package:wedding_planner/screens/vendor_profile_setup_screen.dart';
import 'package:wedding_planner/screens/vendor_services_page.dart';
import 'package:wedding_planner/services/user_service.dart';
import 'package:wedding_planner/widgets/vendor_navbar.dart';
import 'package:wedding_planner/screens/Privacy_and_Policy.dart';
import 'package:wedding_planner/screens/Terms_and_Conditions.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  int _currentIndex = 3;

  String name = '';
  String phone = '';
  String email = '';
  String address = '';
  String vendorPackage = 'BASIC'; // Add vendorPackage
  String? serviceId;
  String? vendorId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVendorProfile();
  }

  Future<void> fetchVendorProfile() async {
    final profile = await UserService.getProfile();
    if (profile != null && profile['user'] != null) {
      setState(() {
        name = profile['user']['name'] ?? '';
        phone = profile['user']['phone'] ?? '';
        email = profile['user']['email'] ?? '';
        address = profile['user']['address'] ?? '';
        vendorPackage =
            profile['user']['vendorPackage'] ?? 'BASIC'; // Fetch vendorPackage
        vendorId = profile['user']['_id']?.toString();
        if (profile['user']['serviceDetails'] != null &&
            profile['user']['serviceDetails'].isNotEmpty) {
          serviceId = profile['user']['serviceDetails'][0]['_id'].toString();
        }
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('refresh_token');
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/wedding_bg.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 16,
                        bottom: 16,
                        child: Text(
                          'Wedding Photography',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => const VendorProfileSetupScreen(),
                              ),
                            ).then((_) => fetchVendorProfile());
                          },
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _profileField('Vendor Name', name),
                        _profileField('Phone number', phone),
                        _profileField('Email', email),
                        _profileField('Address', address),
                        _profileField(
                          'Vendor Package',
                          vendorPackage,
                        ), // Display vendorPackage
                        const SizedBox(height: 10),
                        _actionButton('Service'),
                        _actionButton('Packages'),
                        _actionButton('Availability'),
                        _actionButton('Terms and Conditions'),
                        _actionButton('Privacy Policy'),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          height: 45,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _logout(context),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF00E7AC),
                                    Color(0xFF00B8E4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: VendorNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }

  Widget _profileField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFE6FFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (label == 'Availability') {
            if (vendorId == null || vendorId!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vendor ID not found. Please try again.'),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddAvailabilityScreen(vendorId: vendorId!),
              ),
            ).then((_) => fetchVendorProfile());
          } else if (label == 'Service') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VendorServicesScreen()),
            );
          } else if (label == 'Packages') {
            if (serviceId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No service available. Add a service first.'),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPackagesPage(serviceId: serviceId!),
              ),
            );
          } else if (label == 'Terms and Conditions') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TermsConditionsPage()),
            );
          } else if (label == 'Privacy Policy') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PrivacyPolicyPage()),
            );
          }
        },
      ),
    );
  }
}
