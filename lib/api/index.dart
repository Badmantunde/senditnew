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
  
  // Get saved token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_token');
  }

  // Generate headers dynamically with token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Generic GET request
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        return ApiResponse<T>(
          success: false,
          status: 'error',
          statusCode: 401,
          message: 'No authentication token found. Please login again.',
        );
      }
      
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(timeoutDuration);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic POST request
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        return ApiResponse<T>(
          success: false,
          status: 'error',
          statusCode: 401,
          message: 'No authentication token found. Please login again.',
        );
      }
      
      final headers = await _getHeaders();
      
      // Debug: Log the request details
      print('🔍 POST Request URL: $baseUrl$endpoint');
      print('🔍 POST Request Headers: $headers');
      print('🔍 POST Request Body: ${body != null ? jsonEncode(body) : null}');
      
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

  // Generic PUT request
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        return ApiResponse<T>(
          success: false,
          status: 'error',
          statusCode: 401,
          message: 'No authentication token found. Please login again.',
        );
      }
      
      final headers = await _getHeaders();
      final response = await http
          .put(
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

  // Generic DELETE request
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        return ApiResponse<T>(
          success: false,
          status: 'error',
          statusCode: 401,
          message: 'No authentication token found. Please login again.',
        );
      }
      
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(timeoutDuration);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Handle HTTP response
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    try {
      // Debug: Log the raw response
      print('🔍 Raw API Response Status: ${response.statusCode}');
      print('🔍 Raw API Response Body: ${response.body}');
      print('🔍 Raw API Response Headers: ${response.headers}');
      
      if (response.statusCode == 401) {
        return ApiResponse<T>(
          success: false,
          status: 'error',
          statusCode: 401,
          message: '401: Unauthorized - Token may be expired or invalid',
        );
      } else if (response.statusCode == 403) {
        return ApiResponse<T>(
          success: false,
          status: 'error',
          statusCode: 403,
          message: '403: Forbidden - Access denied',
        );
      } else if (response.statusCode == 422) {
        // Handle validation errors specifically
        try {
          final Map<String, dynamic> jsonData = jsonDecode(response.body);
          return ApiResponse<T>(
            success: false,
            status: 'error',
            statusCode: 422,
            message: jsonData['message'] ?? 'Validation failed',
            data: jsonData['errors'] ?? jsonData,
          );
        } catch (e) {
          return ApiResponse<T>(
            success: false,
            status: 'error',
            statusCode: 422,
            message: 'Validation failed: ${response.body}',
          );
        }
      }
      
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      return ApiResponse.fromJson(jsonData, fromJsonT);
    } catch (e) {
      print('❌ Error parsing API response: $e');
      print('❌ Response body that failed to parse: ${response.body}');
      return ApiResponse<T>(
        success: false,
        status: 'error',
        statusCode: response.statusCode,
        message: 'Failed to parse response: $e',
      );
    }
  }

  // Handle errors
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

// Order-specific API calls
class OrderService {
  // Create Order
  static Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> pickupAddress,
    required Map<String, dynamic> dropOff,
    required String paymentMethod,
    required String payer,
  }) async {
    final body = {
      'items': items,
      'pickup_address': pickupAddress,
      'drop_off': dropOff,
      'payment_method': paymentMethod,
      'payer': payer,
    };

    return await ApiService.post<Map<String, dynamic>>(
      '/orders',
      body: body,
      fromJsonT: (data) => data as Map<String, dynamic>,
    );
  }

  // Compute Order Summary/Charge
  static Future<ApiResponse<Map<String, dynamic>>> computeOrderCharge({
    required Map<String, dynamic> pickupAddress,
    required Map<String, dynamic> dropOff,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    required String payer,
  }) async {
    final body = {
      'pickup_address': pickupAddress,
      'drop_off': dropOff,
      'payment_method': paymentMethod,
      'items': items,
      'payer': payer,
    };

    return await ApiService.post<Map<String, dynamic>>(
      '/orders/compute',
      body: body,
      fromJsonT: (data) => data as Map<String, dynamic>,
    );
  }

  // Get Orders
  static Future<ApiResponse<List<dynamic>>> getOrders() async {
    return await ApiService.get<List<dynamic>>(
      '/orders',
      fromJsonT: (data) => data as List<dynamic>,
    );
  }

  // Get Single Order
  static Future<ApiResponse<Map<String, dynamic>>> getOrder(String orderId) async {
    return await ApiService.get<Map<String, dynamic>>(
      '/orders/$orderId',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );
  }

  // Cancel Order
  static Future<ApiResponse<void>> cancelOrder(String orderId) async {
    return await ApiService.get<void>('/orders/$orderId/cancel');
  }

  // Add Order (alternative create method)
  static Future<ApiResponse<Map<String, dynamic>>> addOrder({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required String payer,
    required Map<String, dynamic> pickupAddress,
    required Map<String, dynamic> dropOff,
  }) async {
    final body = {
      'items': items,
      'payment_method': paymentMethod,
      'payer': payer,
      'pickup_address': pickupAddress,
      'drop_off': dropOff,
    };

    return await ApiService.post<Map<String, dynamic>>(
      '/orders',
      body: body,
      fromJsonT: (data) => data as Map<String, dynamic>,
    );
  }
}

// Usage Examples:
class OrderRepository {
  // Example: Create order from your Flutter app
  static Future<bool> submitOrder(Map<String, dynamic> orderData) async {
    try {
      // Prepare items array
      final items = [
        {
          'name': orderData['itemName'],
          'description': orderData['description'],
          'category': orderData['category'].toLowerCase(),
          'weight': orderData['weight'],
          'quantity': orderData['quantity'],
          'insured': orderData['insured'],
        }
      ];

      final result = await OrderService.addOrder(
        items: items,
        paymentMethod: 'card', // or dynamic
        payer: 'owner',
        pickupAddress: orderData['pickupAddress'],
        dropOff: orderData['dropoffAddress'],
      );

      return result.success;
    } catch (e) {
      print('Error submitting order: $e');
      return false;
    }
  }

  // Example: Get order charge
  static Future<Map<String, dynamic>?> getOrderCharge(Map<String, dynamic> orderData) async {
    try {
      final result = await OrderService.computeOrderCharge(
        pickupAddress: orderData['pickupAddress'],
        dropOff: orderData['dropoffAddress'],
        paymentMethod: 'card',
        items: orderData['items'],
        payer: 'owner',
      );

      if (result.success) {
        return result.data;
      }
      return null;
    } catch (e) {
      print('Error getting order charge: $e');
      return null;
    }
  }

  // Example: Fetch all orders
  static Future<List<dynamic>> fetchOrders() async {
    try {
      final result = await OrderService.getOrders();
      
      if (result.success && result.data != null) {
        return result.data!;
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
}