import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/components/mytextfield.dart';
import 'package:sendit/features/auth/data/auth_service.dart';
import 'package:sendit/features/auth/presentation/pages/password_reset_success_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  final authService = AuthService();

  void handleResetPassword() async {
    final code = codeController.text.trim();
    final newPassword = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      showError("Please fill all fields.");
      return;
    }

    if (newPassword.length < 8) {
      showError("Password must be at least 8 characters.");
      return;
    }

    if (newPassword != confirmPassword) {
      showError("Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await authService.confirmPassword(
      email: widget.email,
      code: code,
      newPassword: newPassword,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Password reset successful."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PasswordResetSuccessPage()),
      );
    } else {
      showError(result['message'] ?? "Password reset failed.");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Color(0xff454A53)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Text(
              'Set New Password',
              style: GoogleFonts.instrumentSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xff454A53),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to ${widget.email}, and choose a new password.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Color(0xff6B7280),
              ),
            ),
            SizedBox(height: 30),

            Mytextfield(
              controller: codeController,
                hintText: 'Verification Code',
                obscureText: false,
              ),
            
            SizedBox(height: 16),

            Mytextfield(
              controller: passwordController,
              obscureText: true,
                hintText: 'New Password',
              ),
            
            SizedBox(height: 16),

            Mytextfield(
              controller: confirmPasswordController,
              obscureText: true,
                hintText: 'Confirm New Password',
              ),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xffE28E3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : handleResetPassword,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                        'Reset Password',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
