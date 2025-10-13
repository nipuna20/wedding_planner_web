import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'vendor_dashboard_screen.dart';
import '../services/auth_service.dart';
import '../widgets/phone_input_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isChecked = false;
  bool _isPasswordVisible = false;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  Future<void> saveVendorId(String vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vendor_id', vendorId);
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhoneInputField(
              onChanged: (value) {
                phoneController.text = value;
              },
            ),
            const SizedBox(height: 10),
            _buildTextField(
              'Password',
              'Password',
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              isPassword: true,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() => isChecked = value!);
                      },
                      activeColor: const Color(0xFF00E7AC),
                    ),
                    const Text('Remember me', style: TextStyle(fontSize: 14)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF00B8E4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final data = {
                      "phone": phoneController.text.trim(),
                      "password": passwordController.text.trim(),
                    };

                    try {
                      final response = await AuthService.signIn(data);

                      if (response != null && response['token'] != null) {
                        final userRole = response['user']['role'];
                        final vendorId = response['user']['id']?.toString();
                        final userName = response['user']['name'] ?? 'Vendor';
                        await saveToken(response['token']);
                        await saveRole(userRole);
                        await saveUserName(userName);
                        if (userRole == 'vendor' && vendorId != null) {
                          await saveVendorId(vendorId);
                        }
                        Fluttertoast.showToast(msg: "Login successful");

                        if (userRole == 'vendor') {
                          Navigator.pushReplacementNamed(
                            context,
                            '/vendor-dashboard',
                          );
                        } else {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: "Invalid credentials or server error",
                        );
                      }
                    } catch (e) {
                      print("Login error: $e");
                      Fluttertoast.showToast(msg: "Something went wrong");
                    }
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
                    'Sign In',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    TextEditingController? controller,
    bool obscureText = false,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: const UnderlineInputBorder(),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                    : null,
          ),
        ),
      ],
    );
  }
}
