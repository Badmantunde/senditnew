// support_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/profile/presentation/faq_screen.dart';
import 'chat_intro_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Widget buildTile(String title, String svgAssetPath, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: SvgPicture.asset(svgAssetPath, width: 24, height: 24),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14)),
        subtitle: Text("Update your account information", style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.normal),),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Support", 
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Color(0xffF8F8FA),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTile("Call Us", 'assets/images/call.svg', () {}),
              buildTile("Chat Us", 'assets/images/chat.svg', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatIntroScreen()));
              }),
              buildTile("Email Us", 'assets/images/email.svg', () {}),
              buildTile("Frequently Asked Question", 'assets/images/faq.svg', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => FaqScreen()));}),
            ],
          ),
        ),
      ),
    );
  }
}
