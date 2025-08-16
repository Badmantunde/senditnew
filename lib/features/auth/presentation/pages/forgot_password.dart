import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/components/mytextfield.dart';
import 'package:sendit/features/auth/data/auth_service.dart';
import 'package:sendit/features/auth/presentation/pages/verify_reset_password_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();
  final authService = AuthService();
  bool isLoading = false;

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void handleForgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showError("Please enter your email.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await authService.forgotPassword(email: email);

    setState(() {
      isLoading = false;
    });

    if (result["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("A verification code has been sent to your email."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: email),
        ),
      );
    } else {
      showError(result["message"] ?? "Something went wrong. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff454A53)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              children: [
                Text(
                  'Forgot Password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter the email linked to your account and we’ll send you a verification code.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff9EA2AD),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-mail',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff454A53),
                      ),
                    ),
                    SizedBox(height: 6),
                    Mytextfield(
                      controller: emailController,
                      hintText: 'Enter your email',
                      obscureText: false,
                    ),
                  ],
                ),
                SizedBox(height: 182),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: isLoading ? null : handleForgotPassword,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffE28E3C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Send Verification Code',
                            style: GoogleFonts.instrumentSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
