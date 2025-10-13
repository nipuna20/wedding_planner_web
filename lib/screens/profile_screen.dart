import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_planner/screens/edit_email_screen.dart';
import 'package:wedding_planner/screens/edit_name_page.dart';
import 'package:wedding_planner/screens/edit_phone_screen.dart';
import 'package:wedding_planner/screens/my_events_screen.dart';
import 'package:wedding_planner/screens/Privacy_and_Policy.dart';
import 'package:wedding_planner/screens/Terms_and_Conditions.dart';
import 'package:wedding_planner/widgets/bottom_navbar.dart';
import '../services/user_service.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4;
  String email = '';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    loadProfile();
    _loadProfileImage();
  }

  Future<void> loadProfile() async {
    final data = await UserService.getProfile();
    if (data != null && mounted) {
      setState(() {
        email = data['user']['email'] ?? '';
      });
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', pickedFile.path);
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : const AssetImage('assets/images/profilepic.jpg')
                            as ImageProvider,
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              email.isNotEmpty ? email : 'Loading...',
              style: const TextStyle(color: Color(0xFF00B8E4)),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE6FFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildProfileRow('Name', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditNameScreen()),
                    );
                  }),
                  _buildProfileRow('Email', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditEmailScreen(),
                      ),
                    );
                  }),
                  _buildProfileRow('Phone Number', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditPhoneScreen(),
                      ),
                    );
                  }),
                  _buildProfileRow('Change password', () {
                    // TODO: Navigate to ChangePasswordPage
                  }),
                  _buildProfileRow('Terms and Conditions', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsConditionsPage(),
                      ),
                    );
                  }),
                  _buildProfileRow('Privacy and Policy', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyEventsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'My Events',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
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
          },
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          title: Text(label),
          trailing: const Icon(Icons.chevron_right),
          tileColor: Colors.white,
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}