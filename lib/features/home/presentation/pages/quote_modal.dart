import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/utils/currency_formatter.dart';
import 'package:sendit/features/home/presentation/pages/payment_choice_modal.dart';
import 'package:sendit/features/home/data/order_service.dart';
import 'package:sendit/features/home/presentation/pages/order_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteModal extends StatefulWidget {
  final Map<String, dynamic> orderData;
  
  const QuoteModal({super.key, required this.orderData});

  @override
  State<QuoteModal> createState() => _QuoteModalState();
}

class _QuoteModalState extends State<QuoteModal> {
  bool isLoading = false;

  Future<void> _handlePaymentChoice(String paymentChoice) async {
    if (paymentChoice == 'receiver') {
      // Create order without payment (receiver pays)
      await _createReceiverPayOrder();
    } else if (paymentChoice == 'sender') {
      // Navigate to payment flow for sender payment
      Navigator.pop(context, 'sender_payment');
    }
  }

  Future<void> _createReceiverPayOrder() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Extract order data
      final items = widget.orderData['items'] ?? [];
      final pickupAddress = widget.orderData['pickupAddress'] ?? {};
      final dropoffAddress = widget.orderData['dropoffAddress'] ?? {};

      // Create order without payment using OrderService
      final result = await OrderService.createOrderWithoutPayment(
        items: items,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        payer: 'receiver',
      );

      if (result['success']) {
        // Save order to local storage
        await _saveOrderToLocal(result['data']);
        
        // Navigate to order detail screen
        if (mounted) {
          Navigator.pop(context); // Close the quote modal
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(
                order: Map<String, String>.from({
                  'id': result['data']['order_id'] ?? 'N/A',
                  'status': 'Created',
                  'itemName': items.isNotEmpty ? items[0]['name'] ?? 'N/A' : 'N/A',
                  'amount': '₦5,500', // Default amount from quote
                }),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create order: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      print('❌ Error creating receiver pay order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveOrderToLocal(Map<String, dynamic> orderData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Use per-account storage key
      final userEmail = prefs.getString('user_email');
      if (userEmail == null || userEmail.isEmpty) {
        print('❌ Error: No user email found. Cannot save order.');
        return;
      }
      final userOrdersKey = 'created_orders_$userEmail';
      final existing = prefs.getStringList(userOrdersKey) ?? [];
      
      // Create order object for local storage
      final order = {
        'trackingId': orderData['order_id'] ?? 'N/A',
        'senderName': widget.orderData['pickupAddress']?['name'] ?? 'N/A',
        'receiverName': widget.orderData['dropoffAddress']?['name'] ?? 'N/A',
        'receiverPhone': widget.orderData['dropoffAddress']?['phone'] ?? 'N/A',
        'receiverEmail': widget.orderData['dropoffAddress']?['email'] ?? 'N/A',
        'senderAddress': '${widget.orderData['pickupAddress']?['street'] ?? ''}, ${widget.orderData['pickupAddress']?['city'] ?? ''}, ${widget.orderData['pickupAddress']?['state'] ?? ''}',
        'receiverAddress': '${widget.orderData['dropoffAddress']?['street'] ?? ''}, ${widget.orderData['dropoffAddress']?['city'] ?? ''}, ${widget.orderData['dropoffAddress']?['state'] ?? ''}',
        'itemName': widget.orderData['items']?.isNotEmpty == true ? widget.orderData['items'][0]['name'] : 'N/A',
        'weight': widget.orderData['items']?.isNotEmpty == true ? widget.orderData['items'][0]['weight'] : 'N/A',
        'quantity': widget.orderData['items']?.isNotEmpty == true ? widget.orderData['items'][0]['quantity'] : 1,
        'amount': '₦5,500',
        'status': 'created',
        'imagePath': null,
        'createdDate': DateTime.now().toIso8601String(),
        'createdTime': DateTime.now().toIso8601String(),
        'items': widget.orderData['items'] ?? [],
        'payer': 'receiver',
        'paymentMethod': 'cash',
      };
      
      existing.add(jsonEncode(order));
      await prefs.setStringList(userOrdersKey, existing);
      print('✅ Order saved to local storage: ${order['trackingId']}');
    } catch (e) {
      print('❌ Error saving order to local storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Shipment Quote',
                        style: GoogleFonts.instrumentSans(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
    
                SizedBox(height: 16),
    
                // Image Placeholder
                Image.asset('assets/images/quote-box.png', height: 72),
    
                SizedBox(height: 16),
    
                // Quote Summary
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF4EC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Quote',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₦5,500',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xffE28E3C),
                        ),
                      ),
                    ],
                  ),
                ),
    
                SizedBox(height: 20),
    
                // Fee breakdown
                _buildQuoteRow('Distance', '70km'),
                _buildQuoteRow('Rate', '₦50/km'),
                _buildQuoteRow('Base Fee', '₦3,500'),
                _buildQuoteRow('Delivery Fee', '₦550'),
                _buildQuoteRow('Insurance Fee', '₦550'),
                _buildQuoteRow('VAT Fee', '₦70 (7%)'),
    
                SizedBox(height: 18),
    
                // Promo Code Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Promo Code', style: GoogleFonts.instrumentSans(fontSize: 14, color: Color(0xff9EA2AD)),),
                    SizedBox(height: 8,),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          hintText: '-Enter Promo Code-',
                          hintStyle: GoogleFonts.dmSans(fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            borderSide: BorderSide(color: Color(0xffE9EAEB))
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffE68A34)),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xffE68A34),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text('Apply',
                            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                  ],
                ),
    
                SizedBox(height: 24),
    
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      final paymentChoice = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => const PaymentChoiceModal(),
                      );
                      
                      if (paymentChoice != null) {
                        await _handlePaymentChoice(paymentChoice);
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffE28E3C),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading 
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Creating Order...', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                          ],
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                  ),
                ),
    
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey.shade500,
              )),
          value.startsWith('₦') 
            ? CurrencyFormatter.formatCurrency(value.substring(1), fontSize: 14, fontWeight: FontWeight.w500)
            : Text(value,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
        ],
      ),
    );
  }
}
