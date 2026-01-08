import 'package:flutter/material.dart';
import 'package:gatecheck/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Navigate to Login Screen
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Media Query for responsive sizing
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white, // Or your app's primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/Logo.png',
              width: size.width * 0.40, // Responsive size: 40% of screen width for better visibility
              fit: BoxFit.contain,
            ),
            
            SizedBox(height: size.height * 0.02), // Responsive spacing
            
            Text(
              'Gate Check',
              style: TextStyle(
                fontSize: size.width * 0.08, // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
