import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class EarnScreen extends StatelessWidget {
  const EarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      appBar: AppBar(
  elevation: 4, // try 2 or 4 for soft shadow
  backgroundColor: Colors.white,
  shadowColor: Colors.black.withOpacity(0.1), // soft shadow
  foregroundColor: Colors.black,
  leading: BackButton(),
  title: Text(
    'Earn',
    style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
  ),
),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Card with message
            Container(
              decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/earn-banner.png'),
                            fit: BoxFit.cover,
                          ),
                color: Color(0xff2E5C4D),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.only(top: 20, left: 16, right: 120, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fund your sendit wallet for fast and ease delivery',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Referral Code Section with background
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: 'SN9056UL'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Code copied!')),
                                );
                              },
                              child: Icon(Icons.copy, size: 18),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'SN9056UL',
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, color: Color(0xffE28E3C)),
                            ),
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 48),

            // Become a rider section
            Text(
              'Become a rider',
              style: GoogleFonts.instrumentSans(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xff454A53),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Send Your Parcel with Ease! Fast, reliable, and secure shipping services. Get a quote, book a pickup all in one place.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Color(0xff333333),
              ),
            ),
            SizedBox(height: 24),

            // Store buttons
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Download on App Store',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w500, fontSize: 14
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.android, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Download on Google Play',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w500, fontSize: 14
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
