import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/auth/data/auth_service.dart';
import 'package:sendit/features/auth/presentation/pages/login_page.dart';
import 'package:sendit/features/auth/presentation/pages/reset_password_page.dart';

class VerifyPage extends StatefulWidget {
  final String email;
  final String password;

  const VerifyPage({super.key, required this.email, required this.password});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  int _resendTimer = 60;
  bool _canResend = false;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    startResendCountdown();
  }

  void startResendCountdown() {
    _timer?.cancel();
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimer == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _resendTimer--;
        });
      }
    });
  }

  void handleInput(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void verifyOtp() async {
  final code = _controllers.map((e) => e.text).join();

  if (code.length != 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please enter the full 6-digit code."),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final authService = AuthService();
    print("Verifying OTP for ${widget.email} with code $code");

    final otpResult = await authService.verifySignupOtp(
      email: widget.email,
      otp: code,
    );
    print("OTP Verification Result: $otpResult");

    setState(() {
      _isLoading = false;
    });

    if (otpResult["success"] == true) {
      final data = otpResult["data"];
      final message = data is Map ? data["message"] : data;

      print("Verification success: $message");

      // Show confirmation and redirect to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification successful. Please log in."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(otpResult["message"] ?? "Verification failed."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
    });

    print("Unexpected error during verification: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("An error occurred. Please try again."),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}





  void resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    final result = await authService.resendSignupVerificationCode(
      email: widget.email,
    );

    setState(() {
      _isLoading = false;
    });

    if (result["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Verification code resent."),
          backgroundColor: Colors.green,
        ),
      );
      startResendCountdown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Could not resend code."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Verify Account',
              style: GoogleFonts.instrumentSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xff454a53),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'A 6-digit code has been sent to ${widget.email}. Enter the code to verify your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: Color(0xff454A53),
                ),
              ),
            ),
            SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 50,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff000000),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.all(10),
                      filled: true,
                      fillColor: Color(0xffF3F3F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: Color(0xffE28E3C),
                          width: 0.5,
                        ),
                      ),
                    ),
                    onChanged: (value) => handleInput(value, index),
                  ),
                );
              }),
            ),

            SizedBox(height: 62),

            Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Color(0xff454A53),
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(text: "Didn't receive a code? "),
                      TextSpan(
                        text: "Resend Code",
                        style: TextStyle(
                          color: _canResend
                              ? Color(0xffE28E3C)
                              : Color(0xffE28E3C).withValues(alpha: 0.5),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _canResend
                              ? () {
                                  resendCode();
                                }
                              : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                if (!_canResend)
                  Text(
                    "Resend Code in 00:${_resendTimer.toString().padLeft(2, '0')}",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Color(0xff454A53),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 40),

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
                onPressed: _isLoading ? null : verifyOtp,
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Verify',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

void showSignupOtpSuccessModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.5,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffE6F4EA),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40 ),
                  child: 
                  Icon(
                    Icons.check_circle, size: 60, color: Colors.green),

                ),
                SizedBox(height: 24),
                Text(
                  'OTP Verified Successfully!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff333333),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your number has been verified.\nNow you can continue to set up your account.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Color(0xff9EA2AD),
                  ),
                ),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(0xffE28E3C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/home');
                    },

                    child: Text(
                      'Continue',
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
        ),
      );
    },
  );
}

}
