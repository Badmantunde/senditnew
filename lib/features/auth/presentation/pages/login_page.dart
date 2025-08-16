import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sendit/features/profile/data/profile_api.dart';
import 'package:sendit/features/wallet/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sendit/components/mytextfield.dart';
import 'package:sendit/features/auth/data/auth_service.dart';
import 'package:sendit/features/auth/presentation/pages/register_screen.dart';
import 'package:sendit/features/auth/presentation/pages/forgot_password.dart';
import 'package:sendit/features/auth/presentation/pages/verify_page.dart';
import 'package:sendit/features/profile/data/avatar_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  bool rememberMe = false;
  final authService = AuthService();
  bool _isLoading = false;

  Future<void> saveIdToken(String idToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id_token', idToken);
    print('ID token saved');
  }

void handleLogin() async {
  final email = emailController.text.trim();
  final password = pwController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please enter both email and password."),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  final result = await authService.login(
    email: email,
    password: password,
  );

  setState(() {
    _isLoading = false;
  });

  if (result['success']) {
  try {
    final idToken = result['tokens']['data']['id_token'];
    await saveIdToken(idToken);

    final prefs = await SharedPreferences.getInstance();

    // ✅ Store user email for avatar management
    await prefs.setString('user_email', email);
    print('LoginPage: Stored user_email: $email');
    
    // ✅ Set current user in AvatarService
    final avatarService = AvatarService();
    await avatarService.setCurrentUser(email);
    print('LoginPage: Set current user in AvatarService: $email');

    // ✅ FETCH PROFILE
    final profile = await ProfileApi.getProfile();
    await prefs.setString('firstName', profile['first_name']);
    await prefs.setString('lastName', profile['last_name']);
    
    // ✅ FETCH WALLET
    final walletUrl = Uri.parse('https://3j97jn908h.execute-api.us-east-1.amazonaws.com/dev/wallet');
    final headers = {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };
    final walletRes = await http.get(walletUrl, headers: headers);
    final walletJson = jsonDecode(walletRes.body);
    final walletBalance = walletJson['data']['balance'] ?? 0.0;

    await prefs.setDouble('wallet_balance', walletBalance.toDouble());
    WalletService().updateBalance(walletBalance.toDouble());

    // Verify user email was stored correctly
    final storedEmail = prefs.getString('user_email');
    print('LoginPage: Verification - stored user_email: $storedEmail');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login successful!"), backgroundColor: Colors.green),
    );

    Navigator.pushReplacementNamed(context, '/home');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login error: $e"), backgroundColor: Colors.redAccent),
    );
  }
}
 else {
    final errorMsg = result['message'] ?? 'Login failed';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                children: [
                  Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Welcome back! Please enter your details to continue',
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
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('E-mail',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff454A53),
                        )),
                    SizedBox(height: 6),
                    Mytextfield(
                      controller: emailController,
                      hintText: 'Enter your email',
                      obscureText: false,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Password',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff454A53),
                        )),
                    SizedBox(height: 6),
                    Mytextfield(
                      controller: pwController,
                      hintText: 'Enter your password',
                      obscureText: true,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          rememberMe = !rememberMe;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xffCBD5E1)),
                              borderRadius: BorderRadius.circular(4),
                              color: rememberMe
                                  ? Color(0xffE68A34)
                                  : Colors.transparent,
                            ),
                            child: rememberMe
                                ? Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : null,
                          ),
                          SizedBox(width: 8),
                          Text('Remember me',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Color(0xff333333),
                                fontWeight: FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPassword()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Color(0xff1D4135),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 52),
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xffE28E3C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Login',
                              style: GoogleFonts.instrumentSans(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: Color(0xff5E5E5E),
                          fontWeight: FontWeight.w500,
                        )),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text('Sign Up',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            color: Color(0xff1D4135),
                            fontWeight: FontWeight.w800,
                          )),
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
                          'Or Login with',
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
