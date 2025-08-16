import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleGeocodingService {
  // Replace with your actual Google Maps API key
  static const String _apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  // Search for places (address autocomplete)
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.length < 3) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl/place/autocomplete/json?'
        'input=${Uri.encodeComponent(query)}'
        '&types=address'
        '&components=country:ng'
        '&key=$_apiKey'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((prediction) {
            return {
              'place_id': prediction['place_id'],
              'description': prediction['description'],
              'structured_formatting': prediction['structured_formatting'],
            };
          }).toList();
        } else {
          print('Google Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return [];
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  // Get place details by place_id
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/place/details/json?'
        'place_id=$placeId'
        '&fields=formatted_address,geometry,address_components'
        '&key=$_apiKey'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry'];
          final location = geometry['location'];
          
          return {
            'formatted_address': result['formatted_address'],
            'latitude': location['lat'],
            'longitude': location['lng'],
            'address_components': result['address_components'],
          };
        } else {
          print('Google Place Details API error: ${data['status']}');
          return null;
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  // Geocode an address string
  static Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/geocode/json?'
        'address=${Uri.encodeComponent(address)}'
        '&components=country:ng'
        '&key=$_apiKey'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final geometry = result['geometry'];
          final location = geometry['location'];
          
          return {
            'formatted_address': result['formatted_address'],
            'latitude': location['lat'],
            'longitude': location['lng'],
            'address_components': result['address_components'],
          };
        } else {
          print('Google Geocoding API error: ${data['status']}');
          return null;
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }

  // Reverse geocode coordinates
  static Future<Map<String, dynamic>?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/geocode/json?'
        'latlng=$lat,$lng'
        '&key=$_apiKey'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          
          return {
            'formatted_address': result['formatted_address'],
            'address_components': result['address_components'],
          };
        } else {
          print('Google Reverse Geocoding API error: ${data['status']}');
          return null;
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  // Parse address components into structured format
  static Map<String, String> parseAddressComponents(List<dynamic> components) {
    final result = <String, String>{};
    
    for (final component in components) {
      final types = List<String>.from(component['types']);
      final longName = component['long_name'];
      
      if (types.contains('street_number')) {
        result['street_number'] = longName;
      } else if (types.contains('route')) {
        result['street'] = longName;
      } else if (types.contains('locality')) {
        result['city'] = longName;
      } else if (types.contains('administrative_area_level_1')) {
        result['state'] = longName;
      } else if (types.contains('postal_code')) {
        result['postal_code'] = longName;
      } else if (types.contains('country')) {
        result['country'] = longName;
      }
    }
    
    return result;
  }

  // Get formatted address for display
  static String formatAddressForDisplay(Map<String, String> components) {
    final parts = <String>[];
    
    if (components['street_number']?.isNotEmpty == true) {
      parts.add(components['street_number']!);
    }
    if (components['street']?.isNotEmpty == true) {
      parts.add(components['street']!);
    }
    if (components['city']?.isNotEmpty == true) {
      parts.add(components['city']!);
    }
    if (components['state']?.isNotEmpty == true) {
      parts.add(components['state']!);
    }
    if (components['postal_code']?.isNotEmpty == true) {
      parts.add(components['postal_code']!);
    }
    if (components['country']?.isNotEmpty == true) {
      parts.add(components['country']!);
    }
    
    return parts.join(', ');
  }
} 