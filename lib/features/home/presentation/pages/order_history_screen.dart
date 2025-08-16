import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sendit/features/home/presentation/pages/order_detail_page.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Map<String, String>> orders = [
    {
      "id": "SN790226",
      "date": "28 June 2025",
      "time": "02:05 PM",
      "amount": "₦5,500",
      "status": "In Transit",
      "name": "John Doe",
      "phone": "+2348192671092"
    },
    {
      "id": "SN790226",
      "date": "28 June 2025",
      "time": "02:05 PM",
      "amount": "₦1,500",
      "status": "Delivered",
      "name": "Taye Taiwo",
      "phone": "+2348192671092"
    },
    {
      "id": "SN790226",
      "date": "28 June 2025",
      "time": "02:05 PM",
      "amount": "₦2,500",
      "status": "Delivered",
      "name": "Dunsin Oyekan",
      "phone": "+2348192671092"
    },
    {
      "id": "SN790226",
      "date": "28 June 2025",
      "time": "02:05 PM",
      "amount": "₦3,500",
      "status": "Canceled",
      "name": "Hidden",
      "phone": "************"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      appBar: AppBar(
        title: Text("Order History", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: orders.isEmpty ? buildEmptyState(context) : buildFilledState(context),
    );
  }

  Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/empty-box.png', height: 160), // Replace with your illustration
            const SizedBox(height: 24),
            Text("No Order yet", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              "Click “send a package” button to get started with creating your order.",
              style: GoogleFonts.dmSans(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Trigger navigation
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xffF7931A),
                backgroundColor: Colors.transparent,
                elevation: 0,
                side: const BorderSide(color: Color(0xffF7931A)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text("Send a package"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildFilledState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffffffff),
                          hintText: 'Search',
                          hintStyle: GoogleFonts.dmSans(color: Color(0xff9EA2AD), fontSize: 14, fontWeight: FontWeight.w500,),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle filter tap
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/filter.svg',
                            height: 18,
                            width: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Filter',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff9EA2AD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          Expanded(
  child: ListView.builder(
    itemCount: orders.length,
    itemBuilder: (context, index) {
      final order = orders[index];
      return GestureDetector(
       onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OrderDetailPage(order: order),
    ),
  );
},

        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Order ID and Amount
              Row(
                children: [
                  Text(
                    order['id']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffE68A34),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order['amount']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff454A53),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
        
              // Date & Location
              Text(
                "${order['date']},  ${order['time']}",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff454A53),
                ),
              ),
              Text(
                "12 unity road, ikeja lagos state",
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xff9EA2AD),
                ),
              ),
              const SizedBox(height: 12),
        
              // Divider
              Container(height: 1, color: const Color(0xffF2F4F7)),
              const SizedBox(height: 12),
        
              // Avatar + Name + Status Badge
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/images/rider.png'),
                  ),
                  const SizedBox(width: 8),
        
                  // Name and Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/verified.svg', 
                              height: 14,
                              width: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order['name']!,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff027A48),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order['phone']!,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: const Color(0xff9EA2AD),
                          ),
                        ),
                      ],
                    ),
                  ),
        
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: getStatusBackground(order['status']!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order['status']!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: getStatusTextColor(order['status']!),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  ),
)
        ],
      ),
    );
  }

  Color getStatusBackground(String status) {
  switch (status) {
    case 'Delivered':
      return const Color(0xffD1FADF);
    case 'Canceled':
      return const Color(0xffFEE4E2);
    case 'In Transit':
      return const Color(0xffFEF6E7);
    default:
      return Colors.grey.shade200;
  }
}

Color getStatusTextColor(String status) {
  switch (status) {
    case 'Delivered':
      return const Color(0xff027A48);
    case 'Canceled':
      return const Color(0xffB42318);
    case 'In Transit':
      return const Color(0xffF59E0B);
    default:
      return Colors.black;
  }
}

}
