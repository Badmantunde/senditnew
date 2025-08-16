import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/components/mytextfield.dart';
import 'package:sendit/components/terms_modal.dart';
import 'package:sendit/features/auth/data/auth_service.dart';
import 'package:sendit/features/auth/presentation/pages/login_page.dart';
import 'package:sendit/features/auth/presentation/pages/verify_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();

  final authService = AuthService();
  bool _agreedToTerms = false;
  bool isLoading = false;

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void handleSignUp() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = pwController.text;
    final confirmPassword = confirmPwController.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showError("Please fill all required fields.");
      return;
    }

    if (!_agreedToTerms) {
      showError("You must agree to our Terms of Service and Privacy Policy.");
      return;
    }

    if (password.length < 8) {
      showError("Password must be at least 8 characters.");
      return;
    }

    if (password != confirmPassword) {
      showError("Passwords do not match.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await authService.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration successful. Please verify your email."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VerifyPage(
      email: emailController.text.trim(),
      password: pwController.text.trim(),
    ),
  ),
);

    } else {
      final errorMsg = result['message'] ?? 'Something went wrong';
      showError(errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 55.0),
              child: Column(
                children: [
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We just need a bit more information. Please enter your details to get started',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First and Last Name Fields
Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('First Name', style: labelStyle()),
          SizedBox(height: 6),
          Mytextfield(
            controller: firstNameController,
            hintText: 'John',
            obscureText: false,
          ),
        ],
      ),
    ),
    SizedBox(width: 10),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last Name', style: labelStyle()),
          SizedBox(height: 6),
          Mytextfield(
            controller: lastNameController,
            hintText: 'Doe',
            obscureText: false,
          ),
        ],
      ),
    ),
  ],
),

                  SizedBox(height: 12),

                  // Email
                  Text('E-mail', style: labelStyle()),
                  SizedBox(height: 6,),
                  Mytextfield(
                    controller: emailController,
                    hintText: 'Enter your email',
                    obscureText: false,
                  ),
                  SizedBox(height: 12),

                  // Phone Number
                  Text('Phone Number', style: labelStyle()),
                  SizedBox(height: 6,),
                  Mytextfield(
                    controller: phoneController,
                    hintText: 'Enter your phone number',
                    obscureText: false,
                  ),
                  SizedBox(height: 12),

                  // Password
                  Text('Password', style: labelStyle()),
                  SizedBox(height: 6,),
                  Mytextfield(
                    controller: pwController,
                    hintText: 'Enter your password',
                    obscureText: true,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Must contain at least 8 characters',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Color(0xff9EA2AD),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Confirm Password
                  Text('Confirm Password', style: labelStyle()),
                  SizedBox(height: 6,),
                  Mytextfield(
                    controller: confirmPwController,
                    hintText: 'Re-enter your password',
                    obscureText: true,
                  ),
                  SizedBox(height: 20),

                  // Terms and Privacy Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xffCBD5E1)),
                            borderRadius: BorderRadius.circular(4),
                            color: _agreedToTerms ? Color(0xffE68A34) : Colors.transparent,
                          ),
                          child: _agreedToTerms
                              ? Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Color(0xff5E5E5E),
                            ),
                            children: [
                              TextSpan(text: 'By signing up, you agree to our '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(color: Color(0xffE68A34), fontSize: 14, fontWeight: FontWeight.w600),
                                recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  showTermsAndConditionsModal(
                                    context,
                                    'Terms and Conditions',
                                    'Your long terms content here...'
                                  );
                                },

                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: Color(0xffE68A34), fontSize: 14, fontWeight: FontWeight.w600),
                                recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  showTermsAndConditionsModal(
                                    context,
                                    'Terms and Conditions',
                                    'Your long terms content here...'
                                  );
                                },

                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: isLoading ? null : handleSignUp,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xffE28E3C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              'Continue',
                              style: GoogleFonts.instrumentSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Already have account?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Color(0xff5E5E5E),
                          )),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        ),
                        child: Text(
                          'Log In',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            color: Color(0xff1D4135),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Or continue with
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xffD6DDEB),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Or sign up with',
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: Color(0xff9EA2AD)),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xffD6DDEB),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Social Sign In Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      socialIconBox('assets/images/google-icon.png', () {}),
                      socialIconBox('assets/images/fb-icon.png', () {}, color: Color(0xFF1877F2)),
                      socialIconBox('assets/images/apple-icon.png', () {}, color: Colors.black),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle labelStyle() {
    return GoogleFonts.instrumentSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xff454A53),
    );
  }

  Widget socialIconBox(String assetPath, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 50,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: color == null ? Border.all(color: Color(0xFFE2E8F0)) : null,
        ),
        child: Image.asset(
          assetPath,
          color: color != null ? Colors.white : null,
        ),
      ),
    );
  }
}
