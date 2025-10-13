import 'package:flutter/material.dart';
import 'signup_screen.dart'; // Make sure this path is correct

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  _SelectRoleScreenState createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String selectedRole = '';

  void selectRole(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.center, // Centered the column content
          children: [
            const Text(
              'Select Role',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 150), // Adjusted for better centering
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _roleCard(
                  'customer',
                  'assets/icons/customer.png', // Ensure you have this asset
                  selectedRole == 'customer',
                ),
                const SizedBox(width: 20),
                _roleCard(
                  'vendor',
                  'assets/icons/vendor.png', // Ensure you have this asset
                  selectedRole == 'vendor',
                ),
              ],
            ),
            const SizedBox(height: 40), // Increased spacing
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    30,
                  ), // Matched button's border radius
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E7AC), Color(0xFF047284)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed:
                      selectedRole.isEmpty
                          ? null
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        SignUpScreen(role: selectedRole),
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ## Animated Role Card Widget
  /// This widget now uses an `AnimatedContainer` to smoothly transition
  /// the border color and shadow when a role is selected.
  Widget _roleCard(String role, String imagePath, bool isSelected) {
    return GestureDetector(
      onTap: () => selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 300,
        ), // Controls the speed of the animation
        curve:
            Curves
                .easeInOut, // Defines the animation curve for a smoother effect
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.teal.withOpacity(0.3) : Colors.black12,
              blurRadius: isSelected ? 8 : 4,
              spreadRadius: isSelected ? 2 : 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              role[0].toUpperCase() + role.substring(1),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
