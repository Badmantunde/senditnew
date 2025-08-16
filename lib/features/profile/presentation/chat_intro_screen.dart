// chat_intro_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';

class ChatIntroScreen extends StatelessWidget {
  const ChatIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Support", style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w600),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Color(0xffF8F8FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade900,
                  radius: 30,
                  child: Text("👋", style: TextStyle(fontSize: 28)),
                ),
                SizedBox(height: 20),
                Text(
                  "Hello! Nice to see you here!\nBy pressing the “Start chat” button you agree to our Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16, height: 1.8),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen()));
                    },
                    child: Text("Start chat"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xffE68A34),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
