import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrencyFormatter {
  // Format currency with Inter font
  static Widget formatCurrency(String amount, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    bool showSymbol = true,
  }) {
    final text = showSymbol ? '₦$amount' : amount;
    
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? Colors.black,
      ),
    );
  }

  // Format currency as string with Inter font style
  static TextStyle getCurrencyStyle({
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

  // Format amount with proper formatting (e.g., ₦5,500.00)
  static String formatAmount(double amount) {
    return '₦${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    )}';
  }

  // Format amount with Inter font widget
  static Widget formatAmountWidget(double amount, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return formatCurrency(
      amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      ),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
} 