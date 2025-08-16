import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  void copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promoList = [
      {
        'discount': '25%',
        'image': 'assets/images/promo1.png',
      },
      {
        'discount': '15%',
        'image': 'assets/images/promo2.png',
      },
      {
        'discount': '40%',
        'image': 'assets/images/promo4.png',
      },
      {
        'discount': '5%',
        'image': 'assets/images/promo5.png',
      },
      {
        'discount': '10%',
        'image': 'assets/images/promo3.png',
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      appBar: AppBar(
  elevation: 4, // try 2 or 4 for soft shadow
  backgroundColor: Colors.white,
  shadowColor: Colors.black.withOpacity(0.1), // soft shadow
  foregroundColor: Colors.black,
  leading: BackButton(),
  title: Text(
    'Promo',
    style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
  ),
),

      body: ListView.separated(
        padding: EdgeInsets.all(16),
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemCount: promoList.length,
        itemBuilder: (context, index) {
          final promo = promoList[index];
          return Container(
            height: 138,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(promo['image'] as String),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Up to',
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${promo['discount']} OFF',
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'Discount for first order',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Spacer(),
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
                        onTap: () => copyCode(context, 'SN9056UL'),
                        child: Icon(Icons.copy, size: 18),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'SN9056UL',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w500, color: Color(0xffE28E3C)
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
