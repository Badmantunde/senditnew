import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentChoiceModal extends StatelessWidget {
  const PaymentChoiceModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Shipment Quote',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Image
                Image.asset('assets/images/22.png', height: 120),

                SizedBox(height: 24),

                // Title
                Text(
                  'Who will pay for this delivery ?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1D4135),
                  ),
                ),

                SizedBox(height: 12),

                // Subtitle
                Text(
                  'Choose your payment option, receiver pays\non delivery or pay now as sender',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 28),

                // Receiver Pay Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Return 'receiver' as the payment choice
                      Navigator.pop(context, 'receiver');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xffE68A34),
                      side: BorderSide(color: Color(0xffE68A34)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Receiver Pay',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Make Payment Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Return 'sender' as the payment choice
                      Navigator.pop(context, 'sender');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffE28E3C),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Make Payment',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
