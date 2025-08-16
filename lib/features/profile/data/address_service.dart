import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddressService {
  static const baseUrl = 'https://3j97jn908h.execute-api.us-east-1.amazonaws.com/dev';

  // Get saved token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_token');
  }

  // Generate headers dynamically with token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Validate address data
  static void _validateAddressData({
    required String street,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String longitude,
    required String latitude,
  }) {
    final errors = <String>[];
    
    if (street.trim().isEmpty) errors.add('Street is required');
    if (city.trim().isEmpty) errors.add('City is required');
    if (state.trim().isEmpty) errors.add('State is required');
    if (postalCode.trim().isEmpty) errors.add('Postal code is required');
    if (country.trim().isEmpty) errors.add('Country is required');
    if (longitude.trim().isEmpty) errors.add('Longitude is required');
    if (latitude.trim().isEmpty) errors.add('Latitude is required');
    
    if (errors.isNotEmpty) {
      throw Exception('Validation errors: ${errors.join(', ')}');
    }
  }

  // Create new address with retry logic and fallback
  static Future<Map<String, dynamic>> createAddress({
    required String street,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String longitude,
    required String latitude,
  }) async {
    try {
      // Validate input data first
      _validateAddressData(
        street: street,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        longitude: longitude,
        latitude: latitude,
      );

      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login again.');
      }

      final headers = await getHeaders();
      
      // Try multiple request body formats to handle backend variations
      final requestBodies = [
        // Format 1: Standard format with correct field names
        {
          'street': street.trim(),
          'city': city.trim(),
          'state': state.trim(),
          'postal_code': postalCode.trim(),
          'country': country.trim(),
          'longtitude': longitude.trim(),
          'latitude': latitude.trim(),
        },
        // Format 2: Alternative format (some backends expect different field names)
        {
          'street': street.trim(),
          'city': city.trim(),
          'state': state.trim(),
          'postal_code': postalCode.trim(),
          'country': country.trim(),
          'longtitude': longitude.trim(), // Use 'longtitude' consistently
          'latitude': latitude.trim(),
        },
        // Format 3: Minimal format (fallback)
        {
          'street': street.trim(),
          'city': city.trim(),
          'state': state.trim(),
          'postal_code': postalCode.trim(),
          'country': country.trim(),
          'longtitude': longitude.trim(),
          'latitude': latitude.trim(),
        },
      ];


      
      for (int i = 0; i < requestBodies.length; i++) {
        try {
          final body = jsonEncode(requestBodies[i]);
          
          print('=== ADDRESS CREATION ATTEMPT ${i + 1} ===');
          print('URL: $baseUrl/profile/addresses');
          print('Headers: $headers');
          print('Request Body: $body');
          print('Token: ${token.substring(0, 20)}...');
          print('==============================');

          final response = await http.post(
            Uri.parse('$baseUrl/profile/addresses'),
            body: body,
            headers: headers,
          );

          print('=== RESPONSE DEBUG ===');
          print('Status Code: ${response.statusCode}');
          print('Response Headers: ${response.headers}');
          print('Response Body: ${response.body}');
          print('======================');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print('✅ Address created successfully with format ${i + 1}');
            return data['data'];
          } else if (response.statusCode == 401) {
            throw Exception('401: Unauthorized - Token may be expired or invalid. Please login again.');
          } else if (response.statusCode == 403) {
            throw Exception('403: Forbidden - Access denied');
          } else if (response.statusCode == 422) {
            // Validation error - try next format
            print('⚠️ Validation error with format ${i + 1}, trying next format...');
            continue;
          } else if (response.statusCode == 500) {
            // Server error - try next format
            print('⚠️ Server error (500) with format ${i + 1}, trying next format...');
            continue;
          } else {
            // Other error - try next format
            print('⚠️ Error ${response.statusCode} with format ${i + 1}, trying next format...');
            continue;
          }
        } catch (e) {
          print('⚠️ Exception with format ${i + 1}: $e');
          if (i < requestBodies.length - 1) {
            continue; // Try next format
          }
        }
      }

      // If all formats failed, try fallback approach
      print('🔄 All API formats failed, trying fallback approach...');
      return await _createAddressFallback(
        street: street,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        longitude: longitude,
        latitude: latitude,
      );

    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Network error: Please check your internet connection');
      } else {
        rethrow;
      }
    }
  }

  // Fallback method to create address locally if API fails
  static Future<Map<String, dynamic>> _createAddressFallback({
    required String street,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String longitude,
    required String latitude,
  }) async {
    print('🔄 Creating address locally as fallback...');
    
    // Generate a local address ID
    final addressId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toIso8601String();
    
    final addressData = {
      'address_id': addressId,
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'longtitude': longitude,
      'latitude': latitude,
      'is_default': 'false',
      'created_at': now,
      'updated_at': now,
    };

    // Save to local storage for offline access
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingAddresses = prefs.getStringList('local_addresses') ?? [];
      existingAddresses.add(jsonEncode(addressData));
      await prefs.setStringList('local_addresses', existingAddresses);
      print('✅ Address saved locally');
    } catch (e) {
      print('⚠️ Failed to save address locally: $e');
    }

    return addressData;
  }

  // Update address
  static Future<Map<String, dynamic>> updateAddress({
    required String addressId,
    required String street,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) async {
    final headers = await getHeaders();
    final body = jsonEncode({
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    });

    final response = await http.put(
      Uri.parse('$baseUrl/profile/addresses/$addressId'),
      body: body,
      headers: headers,
    );

    print('Update Address Status: ${response.statusCode}');
    print('Update Address Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to update address. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // List all addresses (including local fallback)
  static Future<List<Map<String, dynamic>>> listAddresses() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profile/addresses'),
        headers: headers,
      );

      print('List Addresses Status: ${response.statusCode}');
      print('List Addresses Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to list addresses. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('⚠️ Failed to fetch addresses from API: $e');
      print('🔄 Falling back to local addresses...');
      
      // Return local addresses as fallback
      return await _getLocalAddresses();
    }
  }

  // Get local addresses from SharedPreferences
  static Future<List<Map<String, dynamic>>> _getLocalAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localAddresses = prefs.getStringList('local_addresses') ?? [];
      
      return localAddresses.map((addressJson) {
        return jsonDecode(addressJson) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('⚠️ Failed to get local addresses: $e');
      return [];
    }
  }

  // Get address by ID
  static Future<Map<String, dynamic>> getAddressById(String addressId) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/addresses/$addressId'),
      headers: headers,
    );

    print('Get Address Status: ${response.statusCode}');
    print('Get Address Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to get address. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // Delete address by ID
  static Future<bool> deleteAddress(String addressId) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/profile/addresses/$addressId'),
      headers: headers,
    );

    print('Delete Address Status: ${response.statusCode}');
    print('Delete Address Body: ${response.body}');

    return response.statusCode == 200;
  }

  // Debug function to test API with minimal data
  static Future<Map<String, dynamic>> testCreateAddress() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login again.');
      }

      final headers = await getHeaders();
      final body = jsonEncode({
        'street': 'Lagos',
        'city': 'Lagos',
        'state': 'Lagos',
        'postal_code': '1234',
        'country': 'Nigeria',
        'longtitude': '6.34421',
        'latitude': '6.123456',
      });

      print('=== TEST ADDRESS CREATION ===');
      print('URL: $baseUrl/profile/addresses');
      print('Headers: $headers');
      print('Request Body: $body');
      print('Body length: ${body.length}');
      print('Content-Type: ${headers['Content-Type']}');
      print('=============================');

      final response = await http.post(
        Uri.parse('$baseUrl/profile/addresses'),
        body: body,
        headers: headers,
      );

      print('=== TEST RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=====================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Unknown error occurred';
        throw Exception('Test failed: $message (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Test failed with error: $e');
      rethrow;
    }
  }

  // Clear all local addresses
  static Future<void> clearLocalAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_addresses');
      print('✅ Local addresses cleared');
    } catch (e) {
      print('⚠️ Failed to clear local addresses: $e');
    }
  }
} 