import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/auth/presentation/pages/login_page.dart';
import 'package:sendit/onboarding_screens/slide_page1.dart';
import 'package:sendit/onboarding_screens/slide_page2.dart';
import 'package:sendit/onboarding_screens/slide_page3.dart';
import 'package:sendit/features/auth/presentation/pages/register_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // controller to keep track of which page we're on
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        // page view
        PageView(
          controller: _controller,
        children: [
          SlidePage1(),
          SlidePage2(),
          SlidePage3(),
        ],
      ),
      //Skip
            Positioned(
              top:  80,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  _controller.jumpToPage(2);
                },
                child: Text('Skip', 
                style: GoogleFonts.instrumentSans(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500
                ) ,),
              ),
            ),

      // dot indicator
          Positioned(
            bottom: 90,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(
                    dotColor: Colors.grey,
                    activeDotColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                // Primary button (Next or Create Account)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      if (_currentPage == 2) {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen()));
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffE28E3C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == 2 ? 'Create an Account' : 'Next',
                      style: GoogleFonts.instrumentSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Login button (only on last page)
                if (_currentPage == 2) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.instrumentSans(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffE28E3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]

              ],
            ),
          ),
        ],
      ),
    );
  }
}
