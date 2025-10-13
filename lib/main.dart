import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_page.dart';
import 'screens/select_screen.dart';
import 'screens/home_screen.dart';
import 'screens/vendor_dashboard_screen.dart';
import 'screens/signin_screen.dart';
import 'services/auth_service.dart';
import 'models/service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(ServiceAdapter());
    await Hive.openBox<Service>('services');
  } catch (e) {
    print('Hive initialization error: $e');
  }

  // Check if user is logged in
  String initialRoute = '/';
  String? role;
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token != null) {
    // Verify token by calling getProfile
    final profile = await AuthService.getProfile();
    if (profile != null && profile['error'] == 'token_expired') {
      // Try refreshing token
      final refreshResult = await AuthService.refreshToken();
      if (refreshResult != null && refreshResult['token'] != null) {
        // Retry profile fetch with new token
        final retryProfile = await AuthService.getProfile();
        if (retryProfile != null && retryProfile['user'] != null) {
          role = prefs.getString('user_role');
          if (role == 'vendor') {
            initialRoute = '/vendor-dashboard';
          } else {
            initialRoute = '/home';
          }
        } else {
          // Clear invalid token and role
          await prefs.remove('auth_token');
          await prefs.remove('user_role');
        }
      } else {
        // Clear invalid token and role
        await prefs.remove('auth_token');
        await prefs.remove('user_role');
      }
    } else if (profile != null && profile['user'] != null) {
      role = prefs.getString('user_role');
      if (role == 'vendor') {
        initialRoute = '/vendor-dashboard';
      } else {
        initialRoute = '/home';
      }
    } else {
      // Clear invalid token and role
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
    }
  }

  runApp(WeddingPlannerApp(initialRoute: initialRoute));
}

class WeddingPlannerApp extends StatelessWidget {
  final String initialRoute;

  const WeddingPlannerApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wedding Planner',
      theme: ThemeData(
        primaryColor: const Color(0xFF007D8C),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF007D8C),
          secondary: Colors.grey[300],
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF007D8C),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF007D8C)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const OnboardingPage(),
        '/select-role': (context) => const SelectRoleScreen(),
        '/home': (context) => const HomeScreen(),
        '/vendor-dashboard': (context) => const VendorDashboardScreen(),
        '/login': (context) => const SignInScreen(),
      },
    );
  }
}
