// chat_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      messages.add(_controller.text.trim());
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Support", style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w600),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Color(0xffF8F8FA),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (_, index) => Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(messages[index]),
                ),
              ),
            ),
          ),SafeArea(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: "Ask me anything...",
        hintStyle: TextStyle(color: Color(0XFF9EA2AD)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0XFFD6DDEB), width: 0.2),
        ),
        suffixIcon: GestureDetector(
          onTap: sendMessage,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SvgPicture.asset(
              'assets/images/message-send.svg',
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    ),
  ),
)

        ],
      ),
    );
  }
}
