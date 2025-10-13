import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signin_screen.dart';
import '../widgets/phone_input_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final String role;

  const SignUpScreen({super.key, required this.role});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isChecked = false;
  bool _isPasswordVisible = false; // Track password visibility
  bool _isConfirmPasswordVisible = false; // Track confirm password visibility

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Create Account',
          style: TextStyle(
            fontSize: screenWidth > 600 ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 40.0 : 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhoneInputField(
                onChanged: (value) {
                  phoneController.text = value;
                },
              ),
              SizedBox(height: 10),
              _buildTextField('Email Id', 'Email Id', emailController),
              SizedBox(height: 10),
              _buildTextField(
                'Password',
                'Password',
                passwordController,
                obscureText: !_isPasswordVisible,
                isPassword: true,
              ),
              SizedBox(height: 10),
              _buildTextField(
                'Confirm Password',
                'Confirm Password',
                confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                isPassword: true,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                    activeColor: Color(0xFF00E7AC),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'By signing up you agree to our ',
                        style: TextStyle(fontSize: screenWidth > 600 ? 14 : 12),
                        children: [
                          TextSpan(
                            text: 'conditions ',
                            style: TextStyle(
                              color: Color(0xFF00E7AC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: 'and '),
                          TextSpan(
                            text: 'privacy policy',
                            style: TextStyle(
                              color: Color(0xFF00E7AC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: screenWidth > 600 ? 400 : double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!isChecked) {
                        Fluttertoast.showToast(msg: 'Please accept terms.');
                        return;
                      }
                      final data = {
                        "phone": phoneController.text.trim(),
                        "email": emailController.text.trim(),
                        "role": widget.role.toLowerCase(),
                        "password": passwordController.text.trim(),
                      };

                      final response = await AuthService.signUp(data);
                      if (response != null) {
                        Fluttertoast.showToast(msg: "Signup successful");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignInScreen()),
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: "Signup failed. Please try again.",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: screenWidth > 600 ? 20 : 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: screenWidth > 600 ? 18 : 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or Sign up with'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton('Google', FontAwesomeIcons.google),
                  SizedBox(width: 20),
                  _buildSocialButton('Apple', FontAwesomeIcons.apple),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        fontSize: screenWidth > 600 ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: Color(0xFF00E7AC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscureText = false,
    bool isPassword = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: screenWidth > 600 ? 16 : 14, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            border: UnderlineInputBorder(),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (label == 'Password') {
                            _isPasswordVisible = !_isPasswordVisible;
                          } else if (label == 'Confirm Password') {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          }
                        });
                      },
                    )
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: screenWidth > 600 ? 15 : 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 20, color: Colors.black),
        label: Text(text, style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
