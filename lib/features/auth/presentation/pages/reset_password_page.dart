import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/auth/data/auth_service.dart';
import 'package:sendit/features/auth/presentation/pages/login_page.dart';

class ConfirmForgotPasswordPage extends StatefulWidget {
  final String email;

  const ConfirmForgotPasswordPage({super.key, required this.email});

  @override
  State<ConfirmForgotPasswordPage> createState() => _ConfirmForgotPasswordPageState();
}

class _ConfirmForgotPasswordPageState extends State<ConfirmForgotPasswordPage> {
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final authService = AuthService();
  bool _isLoading = false;

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void handleConfirm() async {
    final code = codeController.text.trim();
    final newPassword = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    if (newPassword.length < 8) {
      showError('Password must be at least 8 characters.');
      return;
    }

    if (newPassword != confirmPassword) {
      showError('Passwords do not match.');
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
          content: Text('Password reset successful!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      showError(result['message'] ?? 'Failed to reset password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password', style: GoogleFonts.instrumentSans()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the code sent to your email and choose a new password:',
              style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black87)),
            SizedBox(height: 20),

            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffE28E3C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : handleConfirm,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Reset Password', style: GoogleFonts.instrumentSans(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
