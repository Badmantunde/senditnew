import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/home/presentation/pages/home_page.dart';

void showSignupOtpSuccessModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Text(
                'OTP Verified Successfully!',
                textAlign: TextAlign.center,
                style: GoogleFonts.instrumentSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff333333),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your number has been verified.\nNow you can continue to set up your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Color(0xff9EA2AD),
                ),
              ),
              Spacer(),
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
                    Navigator.pop(context);  // Close modal
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: Text(
                    'Continue',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}
