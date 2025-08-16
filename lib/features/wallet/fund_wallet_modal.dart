import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/wallet/payment_options_screen.dart';

void showFundWalletModal(BuildContext context) {
  final TextEditingController amountController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets, // keyboard padding
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fund Wallet',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600, color: Color(0xff454A53)
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffF1F1F3),
                        ),
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
            
                // Amount Input
                Text(
                  'Amount',
                  style: GoogleFonts.dmSans(fontSize: 14, color: Color(0xff454A53)),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    filled: true,
                    fillColor: Color(0xffF1F5F9),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24),
            
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                    final amount = amountController.text.trim();
                    if (amount.isNotEmpty) {
                      Navigator.pop(context); // close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentOptionsScreen(amount: amount),
                        ),
                      );
                    }
                  },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffF28D35),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Fund Wallet',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,)
              ],
            ),
          ),
        ),
      );
    },
  );
}
