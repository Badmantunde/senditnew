// payment_options_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sendit/features/wallet/wallet_service.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final String amount;
  const PaymentOptionsScreen({super.key, required this.amount});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  String? selectedMethod;
  late WalletService _walletService;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Options', style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: BackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/naira.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(Color(0xff9EA2AD), BlendMode.srcIn),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'You are about to fund your wallet with ${widget.amount}. Funds credited to your wallet are non-refundable and cannot be withdrawn. They shall be applied solely towards your transactions with Sendit.',
                      style: GoogleFonts.dmSans(fontSize: 14, color: Color(0xff9EA2AD)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text('Select Payment Method', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              SizedBox(height: 16),

              paymentTile('Mastercard', 'Pay with cash to the rider at pickup location', 'assets/images/master.svg'),
              paymentTile('Paystack', 'Pay with cash to the rider at pickup location', 'assets/images/paystack.svg'),
              paymentTile('Verve card', 'Pay with cash to the rider at pickup location', 'assets/images/verve.svg'),
              paymentTile('Visa card', 'Pay with cash to the rider at pickup location', 'assets/images/visa.svg'),

              Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedMethod == null
    ? null
    : () async {
        // Add the amount to wallet balance
        final amount = double.tryParse(widget.amount) ?? 0.0;
        await _walletService.addToBalance(amount);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/naira.svg',
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                SizedBox(width: 4),
                Text('Wallet funded successfully with ${widget.amount}'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).popUntil((route) => route.isFirst);
      },


                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedMethod == null ? Colors.grey.shade300 : Color(0xffF28D35),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: selectedMethod == null ? Colors.black38 : Colors.white,
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
  }

  Widget paymentTile(String label, String subtext, String svgAssetPath) {
    final isSelected = selectedMethod == label;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = label),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xffFFF3E9) : Color(0xffF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Color(0xffF28D35) : Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(svgAssetPath, width: 48, height: 48),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
                  SizedBox(height: 4),
                  Text(subtext,
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: Color(0xff9EA2AD))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
