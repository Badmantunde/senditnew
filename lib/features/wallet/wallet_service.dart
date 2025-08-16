import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  double _balance = 0.0;
  bool _isLoading = false;

  double get balance => _balance;
  bool get isLoading => _isLoading;

  // Initialize wallet balance from SharedPreferences
  Future<void> initializeBalance() async {
    _isLoading = true;
WidgetsBinding.instance.addPostFrameCallback((_) {
  notifyListeners();
});


    try {
      final prefs = await SharedPreferences.getInstance();
      _balance = prefs.getDouble('wallet_balance') ?? 0.0;
    } catch (e) {
      print('Error loading wallet balance: $e');
      _balance = 0.0;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update wallet balance
  Future<void> updateBalance(double newBalance) async {
    _balance = newBalance;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('wallet_balance', _balance);
    } catch (e) {
      print('Error saving wallet balance: $e');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
  notifyListeners();
});

  }

  // Add amount to wallet balance
  Future<void> addToBalance(double amount) async {
    await updateBalance(_balance + amount);
  }

  // Subtract amount from wallet balance
  Future<void> subtractFromBalance(double amount) async {
    await updateBalance(_balance - amount);
  }

  // Format balance for display
  String getFormattedBalance() {
  final formatter = NumberFormat.currency(locale: 'en_NG', symbol: '\u20A6');
  return formatter.format(_balance); // e.g. ₦5,000.00
}

  // Get Inter font style for currency
  TextStyle getCurrencyStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Colors.black,
    );
  }

  // Clear wallet balance (for logout)
  Future<void> clearBalance() async {
    _balance = 0.0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('wallet_balance');
    } catch (e) {
      print('Error clearing wallet balance: $e');
    }
    notifyListeners();
  }
} 