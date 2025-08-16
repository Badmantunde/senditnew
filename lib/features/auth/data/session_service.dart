import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sendit/features/profile/data/avatar_service.dart';
import 'package:sendit/features/wallet/wallet_service.dart';

class SessionService {
  static const String baseUrl = 'https://3j97jn908h.execute-api.us-east-1.amazonaws.com/dev';

  // Check if user is already logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('id_token');
      
      if (token == null || token.isEmpty) {
        print('SessionService: No token found');
        return false;
      }

      // Validate token with backend
      final isValid = await _validateToken(token);
      if (!isValid) {
        print('SessionService: Token is invalid, clearing session');
        await _clearSession();
        return false;
      }

      print('SessionService: User is logged in with valid token');
      return true;
    } catch (e) {
      print('SessionService: Error checking login status: $e');
      return false;
    }
  }

  // Validate token with backend
  static Future<bool> _validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Token is valid, refresh user data
        await _refreshUserData(token);
        return true;
      } else if (response.statusCode == 401) {
        print('SessionService: Token expired (401)');
        return false;
      } else {
        print('SessionService: Token validation failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('SessionService: Error validating token: $e');
      return false;
    }
  }

  // Refresh user data (profile, wallet, etc.)
  static Future<void> _refreshUserData(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Refresh profile data
      final profileResponse = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body)['data'];
        
        // Update stored profile data
        await prefs.setString('firstName', profileData['first_name'] ?? '');
        await prefs.setString('lastName', profileData['last_name'] ?? '');
        
        // Handle avatar using the new user-specific system
        final backendAvatarUrl = profileData['avatarUrl'];
        if (backendAvatarUrl != null && backendAvatarUrl.isNotEmpty) {
          final userEmail = prefs.getString('user_email');
          if (userEmail != null && userEmail.isNotEmpty) {
            // Update avatar for the current user using AvatarService
            final avatarService = AvatarService();
            await avatarService.updateAvatar(backendAvatarUrl);
            print('SessionService: Updated avatar URL from backend for user $userEmail: $backendAvatarUrl');
          }
        }
      }

      // Refresh wallet data
      final walletResponse = await http.get(
        Uri.parse('$baseUrl/wallet'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (walletResponse.statusCode == 200) {
        final walletData = jsonDecode(walletResponse.body);
        final walletBalance = walletData['data']['balance'] ?? 0.0;
        
        await prefs.setDouble('wallet_balance', walletBalance.toDouble());
        WalletService().updateBalance(walletBalance.toDouble());
        
        print('SessionService: Updated wallet balance: $walletBalance');
      }

      // Initialize avatar service for current user
      final avatarService = AvatarService();
      final userEmail = prefs.getString('user_email');
      if (userEmail != null && userEmail.isNotEmpty) {
        await avatarService.setCurrentUser(userEmail);
        print('SessionService: Avatar service initialized for user: $userEmail');
      } else {
        print('SessionService: No user email found, skipping avatar initialization');
        await avatarService.initializeAvatar();
      }
      
      print('SessionService: User data refreshed successfully');
    } catch (e) {
      print('SessionService: Error refreshing user data: $e');
    }
  }

  // Clear session data
  static Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get user email before clearing it (to clear user-specific data)
      final userEmail = prefs.getString('user_email');
      
      await prefs.remove('id_token');
      await prefs.remove('firstName');
      await prefs.remove('lastName');
      // Note: avatarUrl is no longer used, avatars are stored with user-specific keys
      await prefs.remove('wallet_balance');
      await prefs.remove('user_email'); // Clear user email for proper isolation
      
      // Clear avatar service for current user
      final avatarService = AvatarService();
      await avatarService.clearAvatar();
      
      // Clear user-specific orders if user email was available
      if (userEmail != null && userEmail.isNotEmpty) {
        final userOrdersKey = 'created_orders_$userEmail';
        await prefs.remove(userOrdersKey);
        print('SessionService: Cleared orders for user: $userEmail');
      }
      
      print('SessionService: Session cleared');
    } catch (e) {
      print('SessionService: Error clearing session: $e');
    }
  }

  // Logout user
  static Future<void> logout() async {
    await _clearSession();
    print('SessionService: User logged out');
  }

  // Get stored user data
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      // Get avatar for current user if available
      String? avatarUrl;
      if (userEmail != null && userEmail.isNotEmpty) {
        final avatarService = AvatarService();
        avatarUrl = await avatarService.getUserAvatar(userEmail);
      }
      
      return {
        'firstName': prefs.getString('firstName') ?? '',
        'lastName': prefs.getString('lastName') ?? '',
        'avatarUrl': avatarUrl, // Now returns user-specific avatar
        'walletBalance': prefs.getDouble('wallet_balance') ?? 0.0,
        'userEmail': userEmail,
      };
    } catch (e) {
      print('SessionService: Error getting user data: $e');
      return {};
    }
  }
} 