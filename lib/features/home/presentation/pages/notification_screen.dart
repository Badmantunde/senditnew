import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sendit/features/home/presentation/pages/order_tracking_page.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text("Notification", style: GoogleFonts.dmSans(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          buildSectionHeader("Today"),
          buildNotificationCard(context, "Your Parcel is ready to be sent", "12 unity road, ikeja lagos state", "09:20 AM", "assets/images/bike.svg"),
          buildNotificationCard(context, "Your Parcel has been delivered", "12 unity road, ikeja lagos state", "09:00 AM", "assets/images/package.svg"),
          buildNotificationCard(context, "Your Parcel has been delivered", "12 unity road, ikeja lagos state", "09:00 AM", "assets/images/package.svg"),
          const SizedBox(height: 20),
          buildSectionHeader("Yesterday"),
          buildNotificationCard(context, "Your Parcel is ready to be sent", "12 unity road, ikeja lagos state", "09:20 AM", "assets/images/package.svg"),
          buildNotificationCard(context, "Your Parcel has been delivered", "12 unity road, ikeja lagos state", "09:00 AM", "assets/images/package.svg"),
        ],
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 20),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget buildNotificationCard(BuildContext context, String title, String subtitle, String time, String iconPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderTrackingPage(
            order: {
              'id': 'TRK${DateTime.now().millisecondsSinceEpoch}',
              'senderName': 'John Doe',
              'receiverName': 'Jane Smith',
              'receiverPhone': '+234 801 234 5678',
              'receiverEmail': 'jane@example.com',
              'senderAddress': '12 Unity Road, Ikeja Lagos State',
              'receiverAddress': '45 Victoria Island, Lagos State',
              'itemName': 'Package',
              'weight': '2.5kg',
              'quantity': 1,
              'amount': '₦2,500',
              'status': 'In Transit',
              'date': DateTime.now().toString().split(' ')[0],
              'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            },
          )),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xffFFF2E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(iconPath),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(time, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.black38)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
