import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/profile/presentation/profile_reset_password_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Security", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: BackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: SvgPicture.asset('assets/images/security.svg', width: 24, height: 24),
          title: Text("Reset Password", style: GoogleFonts.instrumentSans(fontWeight: FontWeight.normal, fontSize: 14)),
          subtitle: Text("Update your account information", style: GoogleFonts.dmSans(fontSize: 12),),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ResetPasswordScreen()),
          ),
        ),
      ),
      backgroundColor: Color(0xffF8F8FA),
    );
  }
}
