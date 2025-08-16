import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sendit/features/profile/data/avatar_service.dart';
import 'package:sendit/features/wallet/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl;

  AuthService({
    this.baseUrl = 'https://3j97jn908h.execute-api.us-east-1.amazonaws.com/dev/auth',
  });

  /// User Signup
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/signup');

      final body = jsonEncode({
        "email": email,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
      });

      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      final data = safeJsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Signup failed.",
        };
      }
    } catch (e) {
      print("Signup error: $e");
      return {
        "success": false,
        "message": "An error occurred during signup.",
      };
    }
  }

  /// Confirm signup with verification code
  Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/confirm-signup');

      final body = jsonEncode({
        "email": email,
        "code": otp,
      });

      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      final data = safeJsonDecode(response.body);

      if (response.statusCode == 200) {
  return {
    "success": true,
    "message": data["message"] ?? "Account verified successfully.",
    "tokens": data, // Ensure the backend sends id_token here
  };
} else {
        return {
          "success": false,
          "message": data["message"] ?? "Verification failed.",
        };
      }
    } catch (e) {
      print("Verify signup OTP error: $e");
      return {
        "success": false,
        "message": "An error occurred during verification.",
      };
    }
  }

  /// Resend verification code for signup
  Future<Map<String, dynamic>> resendSignupVerificationCode({
    required String email,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/resend-verification');

      final body = jsonEncode({
        "email": email,
      });

      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      final data = safeJsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Verification code resent.",
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to resend code.",
        };
      }
    } catch (e) {
      print("Resend signup code error: $e");
      return {
        "success": false,
        "message": "An error occurred while resending the code.",
      };
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final body = jsonEncode({
        "email": email,
        "password": password,
      });

      print('Sending login body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Login status code: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = safeJsonDecode(response.body);

      if (data["error"] == true) {
        return {
          "success": false,
          "message": "Unexpected server response: ${data["raw"]}",
        };
      }

      if (response.statusCode == 200) {
        return {
          "success": true,
          "tokens": data,  // contains access token and other details
          "message": "Login successful",
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Login failed",
        };
      }
    } catch (e) {
      print("Error in login: $e");
      return {
        "success": false,
        "message": "Something went wrong during login.",
      };
    }
  }

  //shared_preferences
  Future<void> saveToken(String idToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('id_token', idToken); // ✅ save under correct key
  print('Saved ID token: $idToken');
}



Future<String?> getSavedToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

Future<void> clearToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
}

  /// Forgot Password
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/forgot-password');

      final body = jsonEncode({
        "email": email,
      });

      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      final data = safeJsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Reset email sent.",
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to send reset email.",
        };
      }
    } catch (e) {
      print("Forgot password error: $e");
      return {
        "success": false,
        "message": "An error occurred.",
      };
    }
  }

  

 /// Verify the OTP for forgot password flow
Future<Map<String, dynamic>> verifyForgotPasswordOtp({
  required String email,
  required String otp,
}) async {
  try {
    final url = Uri.parse('$baseUrl/verify-forgot-password-otp');

    final body = jsonEncode({
      "email": email,
      "code": otp,
    });

    final response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    final data = safeJsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": data["message"] ?? "OTP verified.",
      };
    } else {
      return {
        "success": false,
        "message": data["message"] ?? "OTP verification failed.",
      };
    }
  } catch (e) {
    print("Verify forgot password OTP error: $e");
    return {
      "success": false,
      "message": "An error occurred during verification.",
    };
  }
}

/// Resend OTP for forgot password flow
Future<Map<String, dynamic>> resendForgotPasswordOtp({
  required String email,
}) async {
  try {
    final url = Uri.parse('$baseUrl/resend-forgot-password-otp');

    final body = jsonEncode({
      "email": email,
    });

    final response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    final data = safeJsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": data["message"] ?? "Verification code resent.",
      };
    } else {
      return {
        "success": false,
        "message": data["message"] ?? "Failed to resend code.",
      };
    }
  } catch (e) {
    print("Resend forgot password OTP error: $e");
    return {
      "success": false,
      "message": "An error occurred while resending the code.",
    };
  }
}

/// Confirm new password after forgot password flow
Future<Map<String, dynamic>> confirmPassword({
  required String email,
  required String code,
  required String newPassword,
}) async {
  try {
    final url = Uri.parse('$baseUrl/confirm-password');

    final body = jsonEncode({
      "email": email,
      "code": code,
      "password": newPassword,
    });

    print('Sending confirm forgot password body: $body');

    final response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    print('Confirm Forgot Password status code: ${response.statusCode}');
    print('Confirm Forgot Password response body: ${response.body}');

    final data = safeJsonDecode(response.body);

    if (data["error"] == true) {
      return {
        "success": false,
        "message": "Unexpected server response: ${data["raw"]}",
      };
    }

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": data["message"] ?? "Password reset successful.",
      };
    } else {
      return {
        "success": false,
        "message": data["message"] ?? "Failed to reset password.",
      };
    }
  } catch (e) {
    print("Error in confirmPassword: $e");
    return {
      "success": false,
      "message": "An error occurred. Please try again.",
    };
  }
}



//logout
  Future<void> logoutUser(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  
  // Clear user-specific avatar data before clearing all data
  final avatarService = AvatarService();
  await avatarService.reset(); // This will clear user-specific avatar and user email
  
  await prefs.clear(); // Wipe all saved data

  WalletService().clearBalance(); // Reset wallet

  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
}



}

/// Utility function to safely decode JSON
Map<String, dynamic> safeJsonDecode(String source) {
  try {
    return jsonDecode(source);
  } catch (e) {
    print("JSON decode error: $e");
    return {};
  }
}
