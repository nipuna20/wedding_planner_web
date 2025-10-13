import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_planner/screens/Privacy_and_Policy.dart';
import 'package:wedding_planner/screens/Terms_and_Conditions.dart';
import 'package:wedding_planner/screens/change_password_page.dart';
import 'package:wedding_planner/screens/help_support_page.dart';
import 'package:wedding_planner/screens/message_screen.dart';
import 'package:wedding_planner/screens/onboarding_page.dart';
import 'package:wedding_planner/screens/profile_screen.dart';
import 'package:wedding_planner/screens/vendor_directory_screen.dart';
import '../services/user_service.dart';
import 'dart:io';

class SideMenuDrawer extends StatefulWidget {
  const SideMenuDrawer({super.key});

  @override
  State<SideMenuDrawer> createState() => _SideMenuDrawerState();
}

class _SideMenuDrawerState extends State<SideMenuDrawer> {
  String userName = 'Loading...';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    _loadProfileImage();
  }

  Future<void> fetchUserName() async {
    try {
      final data = await UserService.getProfile();
      if (data != null && data['user'] != null) {
        setState(() {
          userName = data['user']['name'] ?? 'User';
        });
      } else {
        setState(() {
          userName = 'User';
        });
      }
    } catch (e) {
      setState(() {
        userName = 'User';
      });
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFE6FFFF),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            accountName: Text(
              userName,
              style: const TextStyle(color: Colors.black),
            ),
            accountEmail: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                );
              },
              child: const Text(
                'View Profile',
                style: TextStyle(color: Color(0xFF00B8E4)),
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _profileImagePath != null
                  ? FileImage(File(_profileImagePath!))
                  : const AssetImage('assets/images/profile.jpg') as ImageProvider,
            ),
          ),
          _buildMenuItem(context, Icons.store, 'Vendor Bookings'),
          _buildMenuItem(context, Icons.chat, 'Chat'),
          _buildMenuItem(context, Icons.help_outline, 'Help & Support'),
          _buildMenuItem(context, Icons.privacy_tip, 'Privacy & Policy'),
          _buildMenuItem(context, Icons.security, 'Terms & Conditions'),
          _buildMenuItem(context, Icons.lock, 'Change Password'),
          _buildMenuItem(context, Icons.logout, 'Logout'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF007D8C)),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: () async {
        Navigator.pop(context); // Close the drawer first
        switch (title) {
          case 'Vendor Bookings':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VendorDirectoryScreen()),
            );
            break;
          case 'Chat':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MessageScreen()),
            );
            break;
          case 'Help & Support':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportPage()),
            );
            break;
          case 'Privacy & Policy':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            );
            break;
          case 'Terms & Conditions':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsConditionsPage()),
            );
            break;
          case 'Change Password':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            );
            break;
          case 'Logout':
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');
            await prefs.remove('user_role');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingPage()),
              (route) => false,
            );
            break;
        }
      },
    );
  }
}