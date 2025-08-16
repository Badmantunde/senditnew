import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  final String referralCode = 'SN1790';

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Referral code copied')),
    );
  }

  void shareApp(BuildContext context) {
    final message = 'Join me on Sendit using my referral code: $referralCode';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      appBar: AppBar(
        title: Text('Refer and Share', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Color(0xff12332F),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset('assets/images/map.svg', width: 120, height: 120)
            ),
            SizedBox(height: 24),
            Text(
              'Share Sendit with friends & family',
              style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xff454A53)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Refer sendit app to your friends & family to help them with their logistics needs',
              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0xff9EA2AD)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Referral Code',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      referralCode,
                      style: GoogleFonts.dmSans(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: 20, color: Colors.grey),
                    onPressed: () => copyToClipboard(context, referralCode),
                  )
                ],
              ),
              height: 50,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => shareApp(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xffffffff),
                  backgroundColor: Color(0xffE68A34),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Share App', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
