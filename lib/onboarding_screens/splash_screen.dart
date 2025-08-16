import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sendit/onboarding_screens/onboarding_screen.dart';
import 'package:sendit/features/auth/data/session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    try {
      // Show splash for at least 2 seconds
      await Future.delayed(Duration(seconds: 2));
      
      // Check if user is already logged in
      final isLoggedIn = await SessionService.isLoggedIn();
      
      if (mounted) {
        if (isLoggedIn) {
          // User is logged in, go directly to home
          print('SplashScreen: User is logged in, navigating to home');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // User is not logged in, go to onboarding
          print('SplashScreen: User is not logged in, navigating to onboarding');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OnboardingScreen()),
          );
        }
      }
    } catch (e) {
      print('SplashScreen: Error checking session: $e');
      if (mounted) {
        // On error, go to onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1d4135),
      body: Center(
        child: Image.asset('assets/images/logo.png',
        width: 171,),
      ),
    );
  }
}