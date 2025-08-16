import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/utils/currency_formatter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sendit/features/wallet/filter_dialog.dart';
import 'package:sendit/features/wallet/fund_wallet_modal.dart';
import 'package:sendit/features/wallet/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<Map<String, String>> walletHistory = [
    {
      "title": "6753836798",
      "date": "Today, 08:05 AM",
      "amount": "+₦5,500",
      "type": "credit"
    },
    {
      "title": "6753836798",
      "date": "Today, 08:05 AM",
      "amount": "-₦5,500",
      "type": "debit"
    },
    {
      "title": "6753836798",
      "date": "Today, 08:05 AM",
      "amount": "+₦5,500",
      "type": "credit"
    },
    {
      "title": "6753836798",
      "date": "Today, 08:05 AM",
      "amount": "-₦5,500",
      "type": "debit"
    },
  ];

  late WalletService _walletService;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService();
    _walletService.initializeBalance();
    calculateWalletBalance();
  }

  void calculateWalletBalance() {
    double balance = 0;
    for (var entry in walletHistory) {
      String cleanAmount = entry['amount']!.replaceAll(RegExp(r'[^0-9\.]'), '').replaceAll(',', '');
      double amount = double.tryParse(cleanAmount) ?? 0;
      if (entry['type'] == 'credit') {
        balance += amount;
      } else {
        balance -= amount;
      }
    }
    _walletService.updateBalance(balance);
  }

  void showFilterModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: FilterModalContent(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        foregroundColor: Colors.black,
        leading: BackButton(),
        title: Text(
          'Wallet',
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xff1D4135),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Top up your Sendit wallet for fast and ease delivery !',
                            style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(width: 70),
                        Image.asset(
                          'assets/images/stack.png',
                          width: 62,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xffF28D35),
                      image: DecorationImage(
                        image: AssetImage('assets/images/wall.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet Balance',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            ListenableBuilder(
                              listenable: _walletService,
                              builder: (context, child) {
                                return Row(
                                  children: [
                                    SizedBox(width: 4),
                                    Text(
                                      _walletService.getFormattedBalance(),
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => showFundWalletModal(context),
                          icon: Icon(Icons.add_circle_outline_outlined,
                              color: Color(0xff2E5C4D)),
                          label: Text(
                            'Top up',
                            style: GoogleFonts.dmSans(
                              color: Color(0xff2E5C4D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Wallet History Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wallet History',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => showFilterModalBottomSheet(context),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/bx-filter.svg'),
                      SizedBox(width: 4),
                      Text(
                        'Filter',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12,
                          color: Color(0xff454A53),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: walletHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/images/empty.svg', width: 180),
                          const SizedBox(height: 24),
                          Text(
                            'No wallet history yet',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Color(0xff9EA2AD),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: walletHistory.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = walletHistory[index];
                        final isCredit = entry['type'] == 'credit';
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isCredit ? Color(0xffE9F9F0) : Color(0xffFAEAEB) , // light green/red
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: isCredit ? Color(0xff2E5C4D) : Color(0xff9B1C1C),
                                      size: 16,
                                    ),
                                  ),


                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry['date'] ?? '',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: Color(0xff9EA2AD),
                                        ),
                                      ),
                                      Text(
                                        entry['title'] ?? '',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              entry['amount']?.startsWith('₦') == true
                                ? CurrencyFormatter.formatCurrency(
                                    entry['amount']!.substring(1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isCredit ? Colors.green : Colors.red,
                                  )
                                : Text(
                                    entry['amount'] ?? '',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isCredit ? Colors.green : Colors.red,
                                    ),
                                  ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
