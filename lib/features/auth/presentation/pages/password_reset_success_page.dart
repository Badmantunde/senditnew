import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/auth/presentation/pages/login_page.dart';

class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Green Circle with Check
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffE6F4EA),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(20),
                      child: Icon(
                        Icons.check_circle,
                        size: 100,
                        color: Color(0xff23A26D),
                      ),
                    ),
                    SizedBox(height: 24),
              
                    // Heading
                    Text(
                      'Your new password has\nbeen set successfully',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff454a53),
                      ),
                    ),
                    SizedBox(height: 12),
              
                    // Subtext
                    Text(
                      'From now on, please use your new password when login in to your account.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Color(0xff9EA2AD),
                      ),
                    ),
                    SizedBox(height: 200),
              
                    // Back to Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Color(0xffE28E3C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Back to Login',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
