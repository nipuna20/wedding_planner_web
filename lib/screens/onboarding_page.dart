import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': '', // Empty title for first screen
      'description': '', // Empty description for first screen
      'image': 'assets/images/vendorlogo.png',
    },
    {
      'title': 'All You Need In One Place',
      'description':
          "It's certainly not a case of one-size fits all when it comes to wedding venues. Couples decide to get married in all venues.",
      'image': 'assets/images/couple.jpg',
    },
    {
      'title': 'Find Your Perfect Venue',
      'description':
          "It's certainly not a case of one-size fits all when it comes to wedding venues. Couples decide to get married in all venues.",
      'image': 'assets/images/couple.jpg',
    },
    {
      'title': 'The Best Suppliers',
      'description':
          "It's certainly not a case of one-size fits all when it comes to wedding venues. Couples decide to get married in all venues.",
      'image': 'assets/images/couple.jpg',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    // We only want to show dots for the last 3 pages
    final int totalDots = onboardingData.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: index == 0
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    : null,
                child: OnboardingScreen(
                  title: onboardingData[index]['title']!,
                  description: onboardingData[index]['description']!,
                  imagePath: onboardingData[index]['image']!,
                  isFirstScreen: index == 0,
                ),
              );
            },
          ),
          Positioned(
            bottom: 50,
            left: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (_currentPage != 0)
                  Row(
                    children: List.generate(
                      totalDots, // We want 3 dots
                      (index) => buildDot(index, context),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                if (_currentPage != 0)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E7AC), Color(0xFF047284)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          _markOnboardingSeen().then((_) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/select-role',
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _currentPage < onboardingData.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: _currentPage - 1 == index ? 12 : 10,
      decoration: BoxDecoration(
        color: _currentPage - 1 == index ? const Color(0xFF00E7AC) : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool isFirstScreen;

  const OnboardingScreen({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isFirstScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          isFirstScreen
              ? Center(
                child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child:SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 100), // Space for the logo
                           LayoutBuilder(
  builder: (context, constraints) {
    final maxHeight = constraints.maxHeight;
    final maxWidth = constraints.maxWidth;

    final imageHeight = min(maxHeight * 0.5, 300).toDouble();
    final imageWidth = min(maxWidth * 0.8, 300).toDouble();

    return Image.asset(
      imagePath,
      height: imagePath.contains('vendorlogo.png') ? imageHeight : 300,
      width: imagePath.contains('vendorlogo.png') ? imageWidth : null,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.image_not_supported,
        size: 200,
        color: Colors.grey,
      ),
    );
  },
)
                          ],
                        ),
                      ),
                    ),
                  ),
              )
              : ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    child: imagePath.isNotEmpty
                        ? null
                        : const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 300,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
          if (!isFirstScreen) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF047284),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}