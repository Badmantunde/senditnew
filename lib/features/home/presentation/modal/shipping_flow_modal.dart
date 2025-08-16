// shipment_flow_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/home/data/order_service.dart';
import 'package:sendit/features/payment/payment_service.dart';
import 'package:sendit/utils/currency_formatter.dart';
import 'package:sendit/features/home/presentation/pages/payment_choice_modal.dart';
import 'package:sendit/features/home/presentation/pages/order_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShipmentFlowModal extends StatefulWidget {
  final Map<String, dynamic> orderData;
  
  const ShipmentFlowModal({super.key, this.orderData = const {}});

  @override
  State<ShipmentFlowModal> createState() => _ShipmentFlowModalState();
}

class _ShipmentFlowModalState extends State<ShipmentFlowModal> {
  int step = 1;
  String selectedPaymentMethod = '';
  String selectedPayer = ''; // 'sender' or 'receiver'
  bool isLoading = false;
  Map<String, dynamic>? orderSummary;
  Map<String, dynamic>? paymentResult;
  String? orderId;

  void goTo(int nextStep) => setState(() => step = nextStep);
  void goBack() => setState(() => step--);

  @override
  void initState() {
    super.initState();
    _computeOrderSummary();
  }

  // Handle payment choice from PaymentChoiceModal
  Future<void> _handlePaymentChoice(String paymentChoice) async {
    if (paymentChoice == 'receiver') {
      // Create order without payment (receiver pays)
      await _createReceiverPayOrder();
    } else if (paymentChoice == 'sender') {
      // Continue with sender payment flow
      goTo(2); // Go to payer selection step
    }
  }

  // Create order without payment (when receiver pays) - Store in local cache
  Future<void> _createReceiverPayOrder() async {
    setState(() => isLoading = true);

    try {
      // Generate a unique tracking ID for the local order
      final trackingId = 'SN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final now = DateTime.now();
      
      print('🔍 Creating local order for receiver payment...');
      print('🔍 Tracking ID: $trackingId');
      print('🔍 Order Data: ${widget.orderData}');
      
      // Create order data for local storage
      final localOrderData = {
        'order_id': trackingId,
        'tracking_id': trackingId,
        'status': 'created',
        'payer': 'receiver',
        'payment_method': 'cash',
        'payment_status': 'pending',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      
      // Save order to local storage
      await _saveOrderToLocal(localOrderData);
      
      setState(() => isLoading = false);
      
      print('✅ Local order created successfully, proceeding to navigation...');
      
      // Navigate to order detail screen
      if (mounted) {
        try {
          // Debug: Print order data before navigation
          print('🔍 Navigating to OrderDetailPage with local order data:');
          print('Order ID: $trackingId');
          print('Item Name: ${widget.orderData['itemName']}');
          print('Sender Name: ${widget.orderData['pickupAddress']?['name']}');
          print('Receiver Name: ${widget.orderData['dropoffAddress']?['name']}');
          print('Amount: ${orderSummary?['total_charge']}');
          
          // Navigate to OrderDetailPage first
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(
                order: {
                  'id': trackingId,
                  'status': 'Created',
                  'itemName': (widget.orderData['itemName'] ?? 'N/A').toString(),
                  'itemDescription': (widget.orderData['description'] ?? 'N/A').toString(),
                  'itemCategory': (widget.orderData['category'] ?? 'electronics').toString(),
                  'itemWeight': (widget.orderData['weight'] ?? '1').toString(),
                  'itemQuantity': (widget.orderData['quantity'] ?? 1).toString(),
                  'itemInsured': (widget.orderData['insured'] ?? false).toString(),
                  'amount': orderSummary?['total_charge']?.toString() ?? '₦5,500',
                  'payer': 'receiver',
                  'paymentMethod': 'cash',
                  'paymentStatus': 'Pending Payment',
                  'senderName': (widget.orderData['pickupAddress']?['name'] ?? 'N/A').toString(),
                  'senderPhone': (widget.orderData['pickupAddress']?['phone'] ?? 'N/A').toString(),
                  'senderEmail': (widget.orderData['pickupAddress']?['email'] ?? 'N/A').toString(),
                  'pickupAddress': (widget.orderData['pickupAddress']?['address'] ?? 'N/A').toString(),
                  'pickupStreet': (widget.orderData['pickupAddress']?['street'] ?? 'N/A').toString(),
                  'pickupCity': (widget.orderData['pickupAddress']?['city'] ?? 'N/A').toString(),
                  'pickupState': (widget.orderData['pickupAddress']?['state'] ?? 'N/A').toString(),
                  'receiverName': (widget.orderData['dropoffAddress']?['name'] ?? 'N/A').toString(),
                  'receiverPhone': (widget.orderData['dropoffAddress']?['phone'] ?? 'N/A').toString(),
                  'receiverEmail': (widget.orderData['dropoffAddress']?['email'] ?? 'N/A').toString(),
                  'dropoffAddress': (widget.orderData['dropoffAddress']?['address'] ?? 'N/A').toString(),
                  'dropoffStreet': (widget.orderData['dropoffAddress']?['street'] ?? 'N/A').toString(),
                  'dropoffCity': (widget.orderData['dropoffAddress']?['city'] ?? 'N/A').toString(),
                  'dropoffState': (widget.orderData['dropoffAddress']?['state'] ?? 'N/A').toString(),
                  'date': '${now.day}/${now.month}/${now.year}',
                  'time': '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                  'imageFile': widget.orderData['imageFile'], // Pass the actual image file
                },
              ),
            ),
          );
          
          // After returning from OrderDetailPage, close the shipping flow modal
          if (mounted) {
            Navigator.pop(context, true); // Close the shipment flow modal with success result
          }
        } catch (e) {
          print('❌ Error navigating to OrderDetailPage: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening order details: $e')),
          );
          return;
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('❌ Error creating local order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Save order to local storage
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
        'itemName': widget.orderData['itemName'] ?? 'N/A',
        'weight': widget.orderData['weight'] ?? 'N/A',
        'quantity': widget.orderData['quantity'] ?? 1,
        'amount': orderSummary?['total_charge']?.toString() ?? '₦5,500',
        'status': 'created',
        'imagePath': null,
        'createdDate': DateTime.now().toIso8601String(),
        'createdTime': DateTime.now().toIso8601String(),
        'items': [
          {
            'name': widget.orderData['itemName'] ?? 'N/A',
            'description': widget.orderData['description'] ?? 'N/A',
            'category': widget.orderData['category'] ?? 'electronics',
            'weight': widget.orderData['weight'] ?? '1',
            'quantity': widget.orderData['quantity'] ?? 1,
          }
        ],
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

  // Process payment and create order
  Future<void> _processPaymentAndCreateOrder() async {
    if (orderSummary == null || selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final amount = orderSummary!['total_charge']?.toDouble() ?? 0.0;
      
      // Step 1: Process payment
      final paymentResult = await PaymentService.processPayment(
        paymentMethod: selectedPaymentMethod,
        amount: amount,
        description: 'Order payment for ${widget.orderData['itemName'] ?? 'item'}',
      );

      if (!paymentResult['success']) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(paymentResult['message'] ?? 'Payment failed')),
        );
        return;
      }

      // Step 2: Create order after successful payment
      final items = OrderService.prepareItems(
        name: widget.orderData['itemName'] ?? '',
        description: widget.orderData['description'] ?? '',
        category: widget.orderData['category'] ?? 'electronics',
        weight: widget.orderData['weight'] ?? '1',
        quantity: widget.orderData['quantity'] ?? 1,
        insured: widget.orderData['insured'] ?? false,
        imageFile: widget.orderData['imageFile'],
      );

      final pickupAddress = _preparePickupAddress(
        Map<String, String>.from(widget.orderData['pickupAddress'] ?? {}),
      );

      final dropoffAddress = _prepareDropoffAddress(
        Map<String, String>.from(widget.orderData['dropoffAddress'] ?? {}),
      );

      final orderResult = await OrderService.createOrder(
        items: items,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        paymentMethod: selectedPaymentMethod,
        transactionId: paymentResult['transactionId'],
        payer: 'sender',
      );

      setState(() => isLoading = false);

      if (orderResult['success']) {
        setState(() {
          this.paymentResult = paymentResult;
          this.orderId = orderResult['orderId'];
        });
        goTo(4); // Go to success step
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderResult['message'] ?? 'Failed to create order')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: $e')),
      );
    }
  }

  // Compute order summary when modal opens - using local calculator for fast response
  Future<void> _computeOrderSummary() async {
    setState(() => isLoading = true);
    
    try {
      print('🔍 ShipmentFlowModal Debug - Using local calculator for instant quote');
      
      final items = OrderService.prepareItems(
        name: widget.orderData['itemName'] ?? '',
        description: widget.orderData['description'] ?? '',
        category: widget.orderData['category'] ?? 'electronics',
        weight: widget.orderData['weight'] ?? '1',
        quantity: widget.orderData['quantity'] ?? 1,
        insured: widget.orderData['insured'] ?? false,
        imageFile: widget.orderData['imageFile'],
      );

      final pickupAddress = _preparePickupAddress(
        Map<String, String>.from(widget.orderData['pickupAddress'] ?? {}),
      );

      final dropoffAddress = _prepareDropoffAddress(
        Map<String, String>.from(widget.orderData['dropoffAddress'] ?? {}),
      );
      
      // Use local calculation directly for instant results
      final localSummary = _computeLocalOrderSummary(
        items: items,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
      );
      
      setState(() {
        orderSummary = localSummary;
        isLoading = false;
      });
      
      print('✅ Quote calculated instantly using local calculator');
      
    } catch (e) {
      print('❌ Error computing order summary: $e');
      print('🔄 Using default calculation...');
      
      // Fallback to default calculation on any error
      final defaultSummary = _computeLocalOrderSummary(
        items: [],
        pickupAddress: {},
        dropoffAddress: {},
      );
      
      setState(() {
        orderSummary = defaultSummary;
        isLoading = false;
      });
    }
  }

  // Local order summary calculation - enhanced with dynamic pricing
  Map<String, dynamic> _computeLocalOrderSummary({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> pickupAddress,
    required Map<String, dynamic> dropoffAddress,
  }) {
    // Calculate distance based on addresses (simplified estimation)
    double distance = _estimateDistance(pickupAddress, dropoffAddress);
    
    // Calculate weight-based multiplier
    double totalWeight = 0.0;
    int totalQuantity = 0;
    bool hasInsurance = false;
    
    for (var item in items) {
      if (item['weight'] != null) {
        // Parse weight string (e.g., "2.5kg" -> 2.5)
        String weightStr = item['weight'].toString().toLowerCase().replaceAll('kg', '').trim();
        totalWeight += double.tryParse(weightStr) ?? 1.0;
      }
      if (item['quantity'] != null) {
        totalQuantity += (item['quantity'] is int) ? item['quantity'] as int : int.tryParse(item['quantity'].toString()) ?? 1;
      }
      if (item['insured'] == true) {
        hasInsurance = true;
      }
    }
    
    // Fallback to defaults if no items
    if (items.isEmpty) {
      totalWeight = 1.0;
      totalQuantity = 1;
    }
    
    // Dynamic pricing calculation
    double baseFee = 2500.0; // Base fee
    double rate = 45.0; // ₦45 per km
    double weightMultiplier = totalWeight > 5.0 ? 1.2 : 1.0; // 20% extra for heavy items
    double quantityMultiplier = totalQuantity > 1 ? 1.0 + (totalQuantity - 1) * 0.1 : 1.0; // 10% per extra item
    
    double distanceCost = distance * rate * weightMultiplier * quantityMultiplier;
    double deliveryFee = 550.0;
    double insurance = hasInsurance ? 650.0 : 0.0;
    
    double subtotal = baseFee + distanceCost + deliveryFee + insurance;
    double vat = subtotal * 0.075; // 7.5% VAT
    double totalCharge = subtotal + vat;
    
    return {
      'distance': distance,
      'rate': rate,
      'base_fee': baseFee,
      'distance_cost': distanceCost,
      'delivery_fee': deliveryFee,
      'insurance': insurance,
      'vat': vat,
      'total_charge': totalCharge,
      'weight': totalWeight,
      'quantity': totalQuantity,
      'estimated': true, // Flag to indicate this is an estimate
    };
  }
  
  // Estimate distance between two addresses (simplified)
  double _estimateDistance(Map<String, dynamic> pickup, Map<String, dynamic> dropoff) {
    // Try to get cities for basic estimation
    String pickupCity = (pickup['city'] ?? '').toString().toLowerCase();
    String dropoffCity = (dropoff['city'] ?? '').toString().toLowerCase();
    
    // Simple distance estimation based on common Lagos routes
    if (pickupCity.isEmpty || dropoffCity.isEmpty) return 15.0; // Default short distance
    
    // Same city = short distance
    if (pickupCity == dropoffCity) return 8.0;
    
    // Common Lagos area distances (simplified)
    Map<String, double> areaDistances = {
      'ikeja': 12.0,
      'victoria island': 25.0,
      'lekki': 35.0,
      'surulere': 18.0,
      'yaba': 15.0,
      'gbagada': 20.0,
      'festac': 30.0,
      'ajah': 40.0,
    };
    
    double pickupDistance = areaDistances[pickupCity] ?? 15.0;
    double dropoffDistance = areaDistances[dropoffCity] ?? 15.0;
    
    return (pickupDistance + dropoffDistance) / 2; // Average distance
  }

  // Helper method to convert simple address to structured format
  Map<String, dynamic> _convertToStructuredAddress(Map<String, String> simpleAddress) {
    // Parse the address string to extract components
    final addressString = simpleAddress['address'] ?? '';
    final parts = addressString.split(',').map((e) => e.trim()).toList();
    
    return {
      'street': parts.isNotEmpty ? parts[0] : '',
      'city': parts.length > 1 ? parts[1] : '',
      'state': parts.length > 2 ? parts[2] : '',
      'country': 'Nigeria',
      'postal_code': '1234', // Default postal code
      'longitude': '8.687872', // Default longitude
      'latitude': '49.420318', // Default latitude
      'name': simpleAddress['name'] ?? '',
      'phone': simpleAddress['phone'] ?? '',
      'email': simpleAddress['email'] ?? '',
    };
  }

  // Helper method to prepare pickup address for API
  Map<String, dynamic> _preparePickupAddress(Map<String, String> address) {
    return {
      "street": address['street'] ?? "",
      "city": address['city'] ?? "Ikeja",
      "state": address['state'] ?? "Lagos", 
      "formatted_address": address['formatted_address'] ?? "GRA Zone, Ikeja, LA, Nigeria",
      "postal_code": address['postal_code'] ?? "11010",
      "country": address['country'] ?? "Nigeria",
      "longtitude": address['longitude'] ?? "3.332001",
      "latitude": address['latitude'] ?? "6.633099",
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "updated_at": DateTime.now().toUtc().toIso8601String(),
      "save": false,
    };
  }

  // Helper method to prepare dropoff address for API
  Map<String, dynamic> _prepareDropoffAddress(Map<String, String> address) {
    return {
      "name": address['name'] ?? "Receiver",
      "email": address['email'] ?? "receiver@example.com",
      "phone": address['phone'] ?? "+234123456789",
      "formatted_address": address['formatted_address'] ?? "12, Unity Road, Ikeja, Lagos, Nigeria",
      "street": address['street'] ?? "12, Unity Road",
      "city": address['city'] ?? "Ikeja",
      "state": address['state'] ?? "Lagos",
      "country": address['country'] ?? "Nigeria",
      "postal_code": address['postal_code'] ?? "11010",
      "longtitude": address['longitude'] ?? "3.332001",
      "latitude": address['latitude'] ?? "6.633099",
      "save_address": false,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "updated_at": DateTime.now().toUtc().toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        color: Colors.white,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                .animate(animation),
            child: child,
          ),
          child: _renderStep(),
        ),
      ),
    );
  }

  Widget _renderStep() {
    switch (step) {
      case 1:
        return _buildQuoteStep();
      case 2:
        return _buildPayerSelectionStep();
      case 3:
        return _buildPaymentChoiceStep();
      case 4:
        return _buildPaymentSuccessStep();
      case 5:
        return _buildPaymentReceiptStep();
      case 6:
        return _buildReceiverPayStep();
      default:
        return _buildQuoteStep();
    }
  }



  Widget _buildQuoteStep() {
    return SingleChildScrollView(
      key: ValueKey('step1'),
      padding: const EdgeInsets.all(16),
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
              Text('Shipment Quote', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          SizedBox(height: 16),
          
          // Quote Box Illustration
          Container(
            height: 72,
            child: Image.asset('assets/images/quote-box.png', fit: BoxFit.contain),
          ),

          SizedBox(height: 16),
          
          if (isLoading)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xffE28E3C)),
                  SizedBox(height: 16),
                  Text('Computing your quote...', style: GoogleFonts.dmSans(fontSize: 14)),
                ],
              ),
            )
          else if (orderSummary != null) ...[
            // "Your Quote" Highlight Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFFFFF4EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Quote',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  CurrencyFormatter.formatCurrency(
                    orderSummary!['total_charge']?.toStringAsFixed(0) ?? '4200',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xffE28E3C),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Detailed Fee Breakdown
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fee Breakdown',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  _buildQuoteDetailRow('Distance', '${orderSummary!['distance']?.toStringAsFixed(0) ?? '15'}km'),
                  _buildQuoteDetailRow('Rate', '₦${orderSummary!['rate']?.toStringAsFixed(0) ?? '45'}/km'),
                  _buildQuoteDetailRow('Base Fee', '₦${orderSummary!['base_fee']?.toStringAsFixed(0) ?? '2500'}'),
                  _buildQuoteDetailRow('Distance Cost', '₦${orderSummary!['distance_cost']?.toStringAsFixed(0) ?? '675'}'),
                  _buildQuoteDetailRow('Delivery Fee', '₦${orderSummary!['delivery_fee']?.toStringAsFixed(0) ?? '550'}'),
                  if (orderSummary!['insurance'] != null && orderSummary!['insurance'] > 0)
                    _buildQuoteDetailRow('Insurance Fee', '₦${orderSummary!['insurance']?.toStringAsFixed(0) ?? '650'}'),
                  _buildQuoteDetailRow('VAT Fee', '₦${orderSummary!['vat']?.toStringAsFixed(0) ?? '280'} (7.5%)'),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Promo Code Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promo Code',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '-Enter Promo Code-',
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xffE28E3C)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement promo code logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffE28E3C),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 32),
                  SizedBox(height: 8),
                  Text('Failed to compute quote', style: GoogleFonts.dmSans(fontSize: 14, color: Colors.red)),
                ],
              ),
            ),

          SizedBox(height: 24),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: orderSummary != null ? () async {
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
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffE28E3C),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade600)),
          value.startsWith('₦') 
            ? CurrencyFormatter.formatCurrency(value.substring(1), fontSize: 14, fontWeight: FontWeight.w500)
            : Text(value, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuoteRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade600)),
          value.startsWith('₦') 
            ? CurrencyFormatter.formatCurrency(value.substring(1), fontSize: 14, fontWeight: FontWeight.w500)
            : Text(value, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

Widget _buildPromoCodeInput() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Promo Code', style: GoogleFonts.dmSans(fontSize: 14, color: Color(0xff9EA2AD))),
      SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '-Enter Promo Code-',
                hintStyle: GoogleFonts.dmSans(fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  borderSide: BorderSide(color: Color(0xffE9EAEB)),
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
              style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16)),
              child: Text('Apply', style: GoogleFonts.dmSans(color: Color(0xffE68A34), fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildPaymentChoiceStep() {
  return SingleChildScrollView(
    key: ValueKey('step3'),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: goBack,
            ),
            Text(
              'Make Payment',
              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        SizedBox(height: 24),

        _paymentOptionCard(
  id: 'wallet',
  title: 'Pay with Sendit Wallet',
  subtitle: 'Complete the payment using your e-wallet',
  image: 'assets/images/wallet2.png',
  selected: selectedPaymentMethod == 'wallet',
  onTap: () => setState(() => selectedPaymentMethod = 'wallet'),
  extra: TextButton.icon(
    onPressed: () {},
    icon: Icon(Icons.add_circle_outline, color: Color(0xff1D4135), size: 16),
    label: Text('Fund wallet', style: GoogleFonts.dmSans(fontSize: 12, color: Color(0xff1D4135))),
    style: TextButton.styleFrom(
      backgroundColor: Color(0xffffffff),
      side: BorderSide(color: Color(0xffD1D1D1)),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
),


        _paymentOptionCard(
  id: 'paystack',
  title: 'Pay with Paystack',
  subtitle: 'Complete the payment using your e-wallet',
  image: 'assets/images/paystack.png',
  selected: selectedPaymentMethod == 'paystack',
  onTap: () => setState(() => selectedPaymentMethod = 'paystack'),
),


        _paymentOptionCard(
          id: 'master',
          title: 'Pay with Mastercard',
          subtitle: 'Complete the payment using your e-wallet',
          image: 'assets/images/masterr.png',
          selected: selectedPaymentMethod == 'master',
          onTap: () => setState(() => selectedPaymentMethod = 'master'),
        ),

        _paymentOptionCard(
          id: 'visa',
          title: 'Pay with Visa card',
          subtitle: 'Complete the payment using your e-wallet',
          image: 'assets/images/vis.png',
          selected: selectedPaymentMethod == 'visa',
          onTap: () => setState(() => selectedPaymentMethod = 'visa'),
        ),

        SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedPaymentMethod.isNotEmpty && !isLoading 
              ? _processPaymentAndCreateOrder 
              : null,
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
                    Text('Processing...', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                  ],
                )
              : Text('Make Payment', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xffE28E3C),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildPayerSelectionStep() {
  return SingleChildScrollView(
    key: ValueKey('step2'),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: goBack,
            ),
            Text(
              'Who will pay?',
              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        SizedBox(height: 24),

        // Payer Options
        _payerOptionCard(
          id: 'sender',
          title: 'Sender pays',
          subtitle: 'I will pay for this delivery',
          icon: Icons.person,
          selected: selectedPayer == 'sender',
          onTap: () => setState(() => selectedPayer = 'sender'),
        ),

        SizedBox(height: 16),

        _payerOptionCard(
          id: 'receiver',
          title: 'Receiver pays',
          subtitle: 'The recipient will pay on delivery',
          icon: Icons.person_outline,
          selected: selectedPayer == 'receiver',
          onTap: () => setState(() => selectedPayer = 'receiver'),
        ),

        SizedBox(height: 32),

        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedPayer.isNotEmpty ? () {
              if (selectedPayer == 'receiver') {
                // Bypass payment and create order directly
                _createReceiverPayOrder();
              } else {
                // Go to payment methods
                goTo(3);
              }
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffE28E3C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _paymentOptionCard({
  required String id,
  required String title,
  required String subtitle,
  required String image,
  VoidCallback? onTap,
  Widget? extra,
  bool selected = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? Color(0xFFFFF4EC) : Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? Color(0xffE68A34) : Color(0xffE9EAEB),
        ),
      ),
      child: Row(
        children: [
          Image.asset(image, height: 32, width: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                if (extra != null) ...[
                  SizedBox(height: 8),
                  extra,
                ]
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    ),
  );
}

Widget _payerOptionCard({
  required String id,
  required String title,
  required String subtitle,
  required IconData icon,
  VoidCallback? onTap,
  bool selected = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? Color(0xFFFFF4EC) : Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? Color(0xffE68A34) : Color(0xffE9EAEB),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: selected ? Color(0xffE68A34) : Color(0xff1D4135)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (selected)
            Icon(Icons.check_circle, color: Color(0xffE68A34), size: 24),
        ],
      ),
    ),
  );
}



Widget _buildPaymentMethodStep() {
  return SingleChildScrollView(
    key: ValueKey('step3'),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: goBack,
            ),
            Text(
              'Payment Method',
              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        SizedBox(height: 24),

        Text(
          'How would you like to pay?',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff1D4135),
          ),
        ),

        SizedBox(height: 24),

        // Payment options
        _paymentOptionTile('Wallet', 'Pay with wallet balance', Icons.account_balance_wallet_outlined),
        _paymentOptionTile('Card', 'Pay with debit card', Icons.credit_card_outlined),
        _paymentOptionTile('USSD', 'Pay using USSD code', Icons.phone_android_outlined),

        SizedBox(height: 32),

        // Continue to success
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              goTo(4); // Go to success page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffE28E3C),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Make Payment',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        SizedBox(height: 24),
      ],
    ),
  );
}

Widget _paymentOptionTile(String title, String subtitle, IconData icon) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Color(0xffE9EAEB)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: Color(0xff1D4135)),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
          ],
        )
      ],
    ),
  );
}

Widget _buildPaymentSuccessStep() {
  return SingleChildScrollView(
    key: ValueKey('step4'),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Close button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        SizedBox(height: 12),

        Image.asset('assets/images/pay-success.png', height: 100), // animated/confetti tick icon

        SizedBox(height: 16),

        Text(
          'Payment successful !',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Your order is being processed, Use your tracking id to\ntrack your order & view the delivery status',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey),
        ),

        SizedBox(height: 20),

        // Tracking ID section
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffE9EAEB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text('Tracking ID', style: GoogleFonts.dmSans(fontSize: 14)),
              SizedBox(width: 8),
              Icon(Icons.copy, size: 16),
              SizedBox(width: 8),
              Text(
                'SN9056UL',
                style: GoogleFonts.dmSans(
                  color: Color(0xffE28E3C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
      TextButton.icon(
            onPressed: () => goTo(5),
        label: Text(
          'Share',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xff6B7280),
          ),
        ),
        icon: SvgPicture.asset(
          'assets/images/share-grey.svg', // Your custom share icon
          height: 10,
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: Color(0xffE9EAEB)),
          ),
          backgroundColor: Colors.transparent,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        )
      ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Shipment details card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Color(0xffE9EAEB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Shipment Details', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xff1D4135),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Insured', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12)),
                  )
                ],
              ),
              Divider(height: 20),
              _shipmentRow('Sender Name', 'Adedeji Nelson'),
              _shipmentRow('Receiver Name', 'Adedeji Nelson'),
              _shipmentRow('Weight', '12kg'),
              _shipmentRow('Amount', '₦4,120.00', highlight: true),
              _shipmentRow('Pickup', '12, unity road, ikeja Lagos...'),
              _shipmentRow('Dropoff', '15, iyana ipaja, lagos...'),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Track Order button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => goTo(5),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xffE28E3C)),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Track Order', style: GoogleFonts.dmSans(color: Color(0xffE28E3C), fontWeight: FontWeight.w600)),
          ),
        ),

        SizedBox(height: 16),

        // Back Home button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Color(0xffffffff),
              backgroundColor: Color(0xffE28E3C),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Back Home', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ),

        SizedBox(height: 24),
      ],
    ),
  );
}

// Helper row builder
Widget _shipmentRow(String label, String value, {bool highlight = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black87)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis, // ✅ FIXED
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: highlight ? Color(0xffE28E3C) : Colors.grey,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );
}




Widget _buildPaymentReceiptStep() {
  return SingleChildScrollView(
    key: ValueKey('step5'),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: goBack,
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        // Receipt card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
          ),
          child: Column(
            children: [
              // Top banner
              SizedBox(height: 40,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF4EC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Amount to be paid on delivery!',
                      style: GoogleFonts.dmSans(fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    CurrencyFormatter.formatCurrency('5,500', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xffE28E3C)),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Fee breakdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildQuoteRow('Distance', '70km'),
                    _buildQuoteRow('Rate', '₦50/km'),
                    _buildQuoteRow('Base Fee', '₦3,500'),
                    _buildQuoteRow('Delivery Fee', '₦550'),
                    _buildQuoteRow('Insurance Fee', '₦550'),
                    _buildQuoteRow('VAT Fee', '₦70 (7%)'),
                    SizedBox(height: 16),

                    // QR
                    Image.asset('assets/images/qr-code.png', height: 140, fit: BoxFit.contain),
                  ],
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Download Receipt Button
       SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      // download receipt logic
    },
    icon: SvgPicture.asset(
      'assets/images/import.svg', // Replace with your actual path
      height: 16,
    ),
    label: Text(
      'Download Receipt',
      style: GoogleFonts.dmSans(
        color: Color(0xffE68A34),
        fontWeight: FontWeight.w600,
      ),
    ),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Color(0xffE68A34)),
      padding: EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),

        SizedBox(height: 16),

        // Back Home Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffE28E3C),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Back Home',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),

        SizedBox(height: 24),
      ],
    ),
  );
}


Widget _buildReceiverPayStep() {
  return SingleChildScrollView(
    key: ValueKey('step5'),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        SizedBox(height: 24),

        // QR or Illustration
        Image.asset('assets/images/receiver-pay.png', height: 120),

        SizedBox(height: 24),

        Text(
          'Receiver will pay on delivery',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff1D4135),
          ),
        ),

        SizedBox(height: 12),

        Text(
          'You’ve chosen the receiver to complete payment\nwhen the delivery is made.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),

        SizedBox(height: 24),

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xffF8F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: Color(0xffE28E3C)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total Payment Due on Delivery',
                      style: GoogleFonts.dmSans(fontSize: 14),
                    ),
                  ),
                  CurrencyFormatter.formatCurrency('5,500', fontSize: 14, fontWeight: FontWeight.w700)
                ],
              )
            ],
          ),
        ),

        SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffE28E3C),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Done',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        SizedBox(height: 24),
      ],
    ),
  );
}



}
