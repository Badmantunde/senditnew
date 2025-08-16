import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showTermsAndConditionsModal(BuildContext context, String title, String content) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff454A53),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Color(0xff454A53)),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Optional image or header graphic (replace with your asset if needed)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xffE6F4EA),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                style: GoogleFonts.instrumentSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1D4135),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Terms content
SingleChildScrollView(
  child: Text(
    'A small description about the feature title. It\'s better to only write about two sentences about the feature here.\n\n'
    'Reliable. On-Time. Your package, our top priority! We understand the importance of timely delivery, '
    'which is why we guarantee fast and secure shipping to get your goods where they need to go, quickly and efficiently.\n\n'
    'Another small description about the feature title. It\'s better to only write about two sentences here.\n\n'
    'Reliable. On-Time. Your package, our top priority! We understand the importance of timely delivery, '
    'which is why we guarantee fast and secure shipping to get your goods where they need to go, quickly and efficiently.\n\n'
    'A small description about the feature title. It\'s better to only write about two sentences here.\n\n'
    'Reliable. On-Time. Your package, our top priority! We understand the importance of timely delivery, '
    'which is why we guarantee fast and secure shipping to get your goods where they need to go, quickly and efficiently.',
    style: GoogleFonts.dmSans(
      fontSize: 12,
      color: Color(0xff333333),
      height: 1.6,
    ),
    textAlign: TextAlign.justify,
  ),
),

          ],
        ),
      );
    },
  );
}
