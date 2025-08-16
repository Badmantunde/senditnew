import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> verificationItems = [
    {'title': 'Setup Account', 'points': 10, 'verified': true},
    {'title': 'Email verification', 'points': 10, 'verified': true},
    {'title': 'Phone Number Verification', 'points': 10, 'verified': false},
    {'title': 'Upload Photo', 'points': 10, 'verified': false},
    {'title': 'Pickup Address', 'points': 20, 'verified': true},
    {'title': 'Government Issue ID', 'points': 20, 'verified': false},
  ];

int get totalPoints =>
    verificationItems.fold(0, (sum, item) => sum + (item['points'] as int));

int get earnedPoints => verificationItems
    .where((item) => item['verified'] == true)
    .fold(0, (sum, item) => sum + (item['points'] as int));


  @override
  Widget build(BuildContext context) {
    double progress = earnedPoints / totalPoints;

    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      appBar: AppBar(
        title: Text('Verification', style: GoogleFonts.instrumentSans(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 32.77,
                    backgroundColor: Colors.green.shade100,
                    valueColor: AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
                Text('${(progress * 100).toInt()}%',
                    style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 365),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(10, 29, 65, 53),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: verificationItems.length,
                      itemBuilder: (context, index) {
                        final item = verificationItems[index];
                        final isVerified = item['verified'] == true;
                
                        return ListTile(
                          leading: SvgPicture.asset(
                            isVerified
                                ? 'assets/images/check.svg'
                                : 'assets/images/cancel.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: Text(item['title'],
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xff454A53))),
                          subtitle: Text('+${item['points']}', style: GoogleFonts.dmSans(fontSize: 12, color: Color(0xff9EA2AD),fontWeight: FontWeight.normal),),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navigate to verification step screen
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save action
                },
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xffE68A34),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
