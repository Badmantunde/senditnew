import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse<T> {
  final bool success;
  final String status;
  final int statusCode;
  final T? data;
  final String? message;

  ApiResponse({
    required this.success,
    required this.status,
    required this.statusCode,
    this.data,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['status'] == 'success',
      status: json['status'] ?? '',
      statusCode: json['status_code'] ?? 0,
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : json['data'],
      message: json['message'],
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://3j97jn908h.execute-api.us-east-1.amazonaws.com/dev';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  static Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('id_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final headers = await _headers;
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return ApiResponse.fromJson(jsonData, fromJsonT);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        status: 'error',
        statusCode: response.statusCode,
        message: 'Failed to parse response: $e',
      );
    }
  }

  static ApiResponse<T> _handleError<T>(dynamic error) {
    String message = 'Unknown error occurred';
    
    if (error is SocketException) {
      message = 'No internet connection';
    } else if (error is HttpException) {
      message = 'Network error';
    } else if (error.toString().contains('timeout')) {
      message = 'Request timeout';
    } else {
      message = error.toString();
    }

    return ApiResponse<T>(
      success: false,
      status: 'error',
      statusCode: 0,
      message: message,
    );
  }
}

class OrderService {
  static Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required List<Map<String, dynamic>> items,
    required String pickupAddressId,
    required String paymentMethod,
    required Map<String, dynamic> shippingAddress,
  }) async {
    final body = {
      'items': items,
      'pickup_address_id': pickupAddressId,
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress,
    };

    return await ApiService.post<Map<String, dynamic>>(
      '/orders',
      body: body,
      fromJsonT: (data) => data as Map<String, dynamic>,
    );
  }
}

void main() async {
  print('🧪 Testing Order API Integration...');
  
  // Test order creation
  final testItems = [
    {
      'name': 'Iphone 16',
      'description': 'Test description',
      'category': 'electronics',
      'weight': '0.5',
      'quantity': 2,
      'insured': true,
    }
  ];

  final testShippingAddress = {
    'street': 'GRA',
    'state': 'Lagos',
    'city': 'Ikeja',
    'country': 'Nigeria',
    'postal_code': '1234',
    'longitude': '8.687872',
    'latitude': '49.420318',
  };

  try {
    print('📤 Creating test order...');
    final result = await OrderService.createOrder(
      items: testItems,
      pickupAddressId: '7d8a76d4-6787-4574-8a74-300590b2d5b9',
      paymentMethod: 'paystack',
      shippingAddress: testShippingAddress,
    );

    if (result.success) {
      print('✅ Order created successfully!');
      print('📋 Order ID: ${result.data?['order_id']}');
      print('📝 Message: ${result.data?['message']}');
    } else {
      print('❌ Order creation failed');
      print('📝 Error: ${result.message}');
      print('🔢 Status Code: ${result.statusCode}');
    }
  } catch (e) {
    print('💥 Exception occurred: $e');
  }
} 