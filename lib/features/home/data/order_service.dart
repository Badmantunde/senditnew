import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String baseUrl = 'https://3j97jn908h.execute-api.us-east-1.amazonaws.com/dev';
  
  // Get authentication token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_token');
  }

  // Get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Compute Order Summary (Step 1: Get pricing before payment)
  static Future<Map<String, dynamic>> computeOrderSummary({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> pickupAddress,
    required Map<String, dynamic> dropoffAddress,
    required String paymentMethod,
    String payer = 'owner',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/compute');

      // Add payment_method and payer to each item as expected by backend
      final itemsWithPayment = items.map((item) => {
        ...item,
        'payment_method': paymentMethod,
        'payer': payer,
      }).toList();

      // Validate required fields before sending request
      print('🔍 Validating request data...');
      
      // Check items
      if (itemsWithPayment.isEmpty) {
        print('❌ Validation failed: No items provided');
        return {'success': false, 'message': 'No items provided'};
      }
      
      // Check pickup address
      if (pickupAddress.isEmpty) {
        print('❌ Validation failed: Empty pickup address');
        return {'success': false, 'message': 'Empty pickup address'};
      }
      
      // Check dropoff address  
      if (dropoffAddress.isEmpty) {
        print('❌ Validation failed: Empty dropoff address');
        return {'success': false, 'message': 'Empty dropoff address'};
      }
      
      // Check required address fields
      final requiredPickupFields = ['street', 'city', 'state', 'country'];
      final requiredDropoffFields = ['street', 'city', 'state', 'country', 'name', 'phone'];
      
      for (final field in requiredPickupFields) {
        if (!pickupAddress.containsKey(field) || pickupAddress[field] == null || pickupAddress[field].toString().isEmpty) {
          print('❌ Validation failed: Missing pickup address field: $field');
          return {'success': false, 'message': 'Missing pickup address field: $field'};
        }
      }
      
      for (final field in requiredDropoffFields) {
        if (!dropoffAddress.containsKey(field) || dropoffAddress[field] == null || dropoffAddress[field].toString().isEmpty) {
          print('❌ Validation failed: Missing dropoff address field: $field');
          return {'success': false, 'message': 'Missing dropoff address field: $field'};
        }
      }
      
      print('✅ Validation passed');

      final body = jsonEncode({
        'items': itemsWithPayment,
        'pickup_address': pickupAddress,
        'drop_off': dropoffAddress,
        'payer': payer,
      });

      print('🔄 Computing order summary...');
      print('📤 Request URL: $url');
      print('📤 Request Headers: $headers');
      print('📤 Request Body: $body');
      print('📤 Items Count: ${itemsWithPayment.length}');
      print('📤 Pickup Address Keys: ${pickupAddress.keys.toList()}');
      print('📤 Dropoff Address Keys: ${dropoffAddress.keys.toList()}');

      final response = await http.post(url, headers: headers, body: body);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['data'] != null) {
            return {
              'success': true,
              'data': data['data'],
            };
          } else {
            print('⚠️ Backend returned 200 but no data field');
            return {
              'success': false,
              'message': 'Invalid response format from backend',
              'statusCode': response.statusCode,
            };
          }
        } catch (e) {
          print('❌ Error parsing response: $e');
          return {
            'success': false,
            'message': 'Invalid JSON response from backend',
            'statusCode': response.statusCode,
          };
        }
      } else {
        print('❌ Backend error: ${response.statusCode} - ${response.body}');
        
        // Try to parse error response for more details
        String errorMessage = 'Backend error: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
          if (errorData['errors'] != null) {
            print('📋 Backend validation errors: ${errorData['errors']}');
            errorMessage += ' - Details: ${errorData['errors']}';
          }
        } catch (e) {
          print('⚠️ Could not parse error response: $e');
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
          'rawResponse': response.body,
        };
      }
    } catch (e) {
      print('❌ Error computing order summary: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // 2. Process Payment (Step 2: Handle payment before creating order)
  static Future<Map<String, dynamic>> processPayment({
    required String paymentMethod,
    required double amount,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      // For now, we'll simulate payment processing
      // In a real app, you'd integrate with Paystack, etc.
      
      if (paymentMethod == 'wallet') {
        // Check wallet balance
        final prefs = await SharedPreferences.getInstance();
        final walletBalance = prefs.getDouble('wallet_balance') ?? 0.0;
        
        if (walletBalance < amount) {
          return {
            'success': false,
            'message': 'Insufficient wallet balance',
          };
        }
        
        // Deduct from wallet
        await prefs.setDouble('wallet_balance', walletBalance - amount);
        
        return {
          'success': true,
          'transactionId': 'WALLET_${DateTime.now().millisecondsSinceEpoch}',
          'message': 'Payment successful via wallet',
        };
      } else {
        // Simulate external payment (Paystack, card, etc.)
        await Future.delayed(Duration(seconds: 2)); // Simulate payment processing
        
        return {
          'success': true,
          'transactionId': 'PAY_${DateTime.now().millisecondsSinceEpoch}',
          'message': 'Payment successful via $paymentMethod',
        };
      }
    } catch (e) {
      print('❌ Error processing payment: $e');
      return {
        'success': false,
        'message': 'Payment failed: $e',
      };
    }
  }

  // 3. Create Order (Step 3: Only after payment is confirmed)
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> pickupAddress,
    required Map<String, dynamic> dropoffAddress,
    required String paymentMethod,
    required String transactionId,
    String payer = 'owner',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders');

      // Add payment_method and payer to each item as expected by backend
      final itemsWithPayment = items.map((item) => {
        ...item,
        'payment_method': paymentMethod,
        'payer': payer,
      }).toList();

      final body = jsonEncode({
        'items': itemsWithPayment,
        'pickup_address': pickupAddress,
        'drop_off': dropoffAddress,
        'payer': payer,
        'transaction_id': transactionId, // Include payment transaction ID
      });

      print('🔄 Creating order after payment confirmation...');
      print('📤 Request Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'orderId': data['data']['order_id'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create order',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // 3b. Create Order without payment (when receiver pays)
  static Future<Map<String, dynamic>> createOrderWithoutPayment({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> pickupAddress,
    required Map<String, dynamic> dropoffAddress,
    String payer = 'receiver',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders');

      // Add payment_method and payer to each item as expected by backend
      final itemsWithPayment = items.map((item) => {
        ...item,
        'payment_method': 'cash', // Receiver pays on delivery
        'payer': payer,
      }).toList();

      final body = jsonEncode({
        'items': itemsWithPayment,
        'pickup_address': pickupAddress,
        'drop_off': dropoffAddress,
        'payer': payer,
        // No transaction_id needed for receiver payment
      });

      print('🔄 Creating order without payment (receiver pays)...');
      print('📤 Request Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'orderId': data['data']['order_id'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create order',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // 4. Get All Orders
  static Future<Map<String, dynamic>> getOrders() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch orders',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error fetching orders: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // 5. Get Single Order
  static Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/$orderId');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch order',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error fetching order: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // 6. Cancel Order
  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/$orderId/cancel');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Order cancelled successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to cancel order',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error cancelling order: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Helper method to convert image to base64
  static String? imageToBase64(File? imageFile) {
    if (imageFile == null) return null;
    try {
      final bytes = imageFile.readAsBytesSync();
      return base64Encode(bytes);
    } catch (e) {
      print('❌ Error converting image to base64: $e');
      return null;
    }
  }

  // Helper method to prepare items for API
  static List<Map<String, dynamic>> prepareItems({
    required String name,
    required String description,
    required String category,
    required String weight,
    required int quantity,
    required bool insured,
    File? imageFile,
  }) {
    final item = {
      'name': name,
      'description': description,
      'category': category.toLowerCase(),
      'weight': weight,
      'quantity': quantity,
      'insured': insured,
    };

    // Add image if provided
    if (imageFile != null) {
      final base64Image = imageToBase64(imageFile);
      if (base64Image != null) {
        item['image'] = 'data:image/png;base64,$base64Image';
      }
    }

    return [item];
  }

  // Helper method to prepare pickup address for API
  static Map<String, dynamic> preparePickupAddress(Map<String, String> address) {
    return {
      'street': address['street'] ?? '',
      'city': address['city'] ?? '',
      'state': address['state'] ?? '',
      'formatted address': address['address'] ?? '',
      'postal code': address['postal_code'] ?? '',
      'country': address['country'] ?? '',
      'longtitude': double.tryParse(address['longitude'] ?? '0') ?? 0.0,
      'latitude': double.tryParse(address['latitude'] ?? '0') ?? 0.0,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'save': false,
    };
  }

  // Helper method to prepare dropoff address for API
  static Map<String, dynamic> prepareDropoffAddress(Map<String, String> address) {
    return {
      'name': address['name'] ?? '',
      'email': address['email'] ?? '',
      'phone': address['phone'] ?? '',
      'formatted address': address['address'] ?? '',
      'street': address['street'] ?? '',
      'city': address['city'] ?? '',
      'state': address['state'] ?? '',
      'country': address['country'] ?? '',
      'postal code': address['postal_code'] ?? '',
      'longtitude': double.tryParse(address['longitude'] ?? '0') ?? 0.0,
      'latitude': double.tryParse(address['latitude'] ?? '0') ?? 0.0,
      'save_address': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
} 