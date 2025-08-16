import 'dart:convert';
import 'package:http/http.dart' as http;

class FallbackGeocodingService {
  // Nigerian cities and states mapping for better local results
  static const Map<String, List<String>> _nigerianCities = {
    'Lagos': ['Ikeja', 'Victoria Island', 'Lekki', 'Surulere', 'Yaba', 'Oshodi', 'Agege', 'Ikorodu', 'Alimosho'],
    'Abuja': ['Garki', 'Wuse', 'Maitama', 'Asokoro', 'Jabi', 'Kubwa', 'Gwarinpa'],
    'Kano': ['Municipal', 'Fagge', 'Dala', 'Gwale', 'Tarauni', 'Ungogo', 'Nasarawa'],
    'Ibadan': ['Ibadan North', 'Ibadan South-East', 'Ibadan South-West', 'Ibadan North-East', 'Ibadan North-West'],
    'Port Harcourt': ['Port Harcourt', 'Obio-Akpor', 'Okrika', 'Eleme'],
    'Kaduna': ['Kaduna North', 'Kaduna South', 'Chikun', 'Igabi', 'Soba'],
    'Enugu': ['Enugu North', 'Enugu South', 'Enugu East', 'Nkanu West', 'Nkanu East'],
    'Jos': ['Jos North', 'Jos South', 'Jos East', 'Bokkos', 'Barkin Ladi'],
  };

  static const Map<String, String> _stateMapping = {
    'lagos': 'Lagos',
    'abuja': 'FCT',
    'kano': 'Kano',
    'ibadan': 'Oyo',
    'port harcourt': 'Rivers',
    'kaduna': 'Kaduna',
    'enugu': 'Enugu',
    'jos': 'Plateau',
    'benin': 'Edo',
    'calabar': 'Cross River',
    'maiduguri': 'Borno',
    'sokoto': 'Sokoto',
    'katsina': 'Katsina',
    'bauchi': 'Bauchi',
    'gombe': 'Gombe',
    'yola': 'Adamawa',
    'jalingo': 'Taraba',
    'lafia': 'Nasarawa',
    'minna': 'Niger',
    'lokoja': 'Kogi',
    'abakaliki': 'Ebonyi',
    'owerri': 'Imo',
    'awka': 'Anambra',
    'asaba': 'Delta',
    'warri': 'Delta',
    'benin city': 'Edo',
    'akure': 'Ondo',
    'ado ekiti': 'Ekiti',
    'osogbo': 'Osun',
    'ilorin': 'Kwara',
  };

  // Search for places using a more reliable approach
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.length < 2) return [];

    try {
      // First try with a more reliable geocoding service
      final results = await _searchWithPhotonAPI(query);
      
      if (results.isNotEmpty) {
        return results;
      }

      // Fallback to local Nigerian data
      return _searchLocalNigerianData(query);
    } catch (e) {
      print('Error searching places: $e');
      return _searchLocalNigerianData(query);
    }
  }

  // Use Photon API (more reliable than Nominatim)
  static Future<List<Map<String, dynamic>>> _searchWithPhotonAPI(String query) async {
    try {
      final uri = Uri.parse(
        'https://photon.komoot.io/api/?'
        'q=${Uri.encodeComponent(query)}'
        '&limit=5'
        '&lang=en'
        '&lat=9.0820&lon=8.6753' // Center of Nigeria
        '&radius=1000000' // Large radius to cover Nigeria
      );

      final response = await http.get(uri, headers: {
        'User-Agent': 'SendIt/1.0',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List?;
        
        if (features != null) {
          return features.map((feature) {
            final properties = feature['properties'];
            final geometry = feature['geometry'];
            final coordinates = geometry['coordinates'];
            
            return {
              'display_name': properties['name'] ?? properties['street'] ?? 'Unknown Location',
              'lat': coordinates[1].toDouble(),
              'lon': coordinates[0].toDouble(),
              'street': properties['street'] ?? '',
              'city': properties['city'] ?? properties['state'] ?? '',
              'state': properties['state'] ?? '',
              'country': properties['country'] ?? 'Nigeria',
            };
          }).where((result) => 
            result['country'] == 'Nigeria' && 
            result['lat'] != 0.0 && 
            result['lon'] != 0.0
          ).toList();
        }
      }
    } catch (e) {
      print('Photon API error: $e');
    }
    
    return [];
  }

  // Local Nigerian data search
  static List<Map<String, dynamic>> _searchLocalNigerianData(String query) {
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();

    // Search in cities
    for (final entry in _nigerianCities.entries) {
      final state = entry.key;
      final cities = entry.value;
      
      for (final city in cities) {
        if (city.toLowerCase().contains(lowerQuery) || 
            state.toLowerCase().contains(lowerQuery)) {
          results.add({
            'display_name': '$city, $state, Nigeria',
            'lat': _getApproximateLatitude(city, state),
            'lon': _getApproximateLongitude(city, state),
            'street': '',
            'city': city,
            'state': state,
            'country': 'Nigeria',
          });
        }
      }
    }

    // Search in state mapping
    for (final entry in _stateMapping.entries) {
      if (entry.key.contains(lowerQuery) || entry.value.toLowerCase().contains(lowerQuery)) {
        results.add({
          'display_name': '${entry.value}, Nigeria',
          'lat': _getApproximateLatitude('', entry.value),
          'lon': _getApproximateLongitude('', entry.value),
          'street': '',
          'city': entry.value,
          'state': entry.value,
          'country': 'Nigeria',
        });
      }
    }

    return results.take(5).toList();
  }

  // Approximate coordinates for Nigerian cities
  static double _getApproximateLatitude(String city, String state) {
    const coordinates = {
      'Lagos': 6.5244,
      'Ikeja': 6.6018,
      'Victoria Island': 6.4281,
      'Lekki': 6.4654,
      'Surulere': 6.5015,
      'Yaba': 6.5095,
      'Oshodi': 6.5550,
      'Agege': 6.6274,
      'Ikorodu': 6.6147,
      'Alimosho': 6.5991,
      'Abuja': 9.0820,
      'Garki': 9.0581,
      'Wuse': 9.0765,
      'Maitama': 9.0765,
      'Asokoro': 9.0581,
      'Jabi': 9.0581,
      'Kubwa': 9.1585,
      'Gwarinpa': 9.0581,
      'Kano': 11.9914,
      'Ibadan': 7.3964,
      'Port Harcourt': 4.8156,
      'Kaduna': 10.5222,
      'Enugu': 6.4584,
      'Jos': 9.8965,
      'Benin': 6.3176,
      'Calabar': 4.9757,
      'Maiduguri': 11.8333,
      'Sokoto': 13.0621,
      'Katsina': 12.9914,
      'Bauchi': 10.3103,
      'Gombe': 10.2897,
      'Yola': 9.2035,
      'Jalingo': 8.9000,
      'Lafia': 8.5000,
      'Minna': 9.6139,
      'Lokoja': 7.8023,
      'Abakaliki': 6.3249,
      'Owerri': 5.4833,
      'Awka': 6.2109,
      'Asaba': 6.1833,
      'Warri': 5.5167,
      'Benin City': 6.3176,
      'Akure': 7.2500,
      'Ado Ekiti': 7.6167,
      'Osogbo': 7.7667,
      'Ilorin': 8.5000,
    };

    // Try city first, then state
    return coordinates[city] ?? coordinates[state] ?? 6.5244; // Default to Lagos
  }

  static double _getApproximateLongitude(String city, String state) {
    const coordinates = {
      'Lagos': 3.3792,
      'Ikeja': 3.3515,
      'Victoria Island': 3.4219,
      'Lekki': 3.5657,
      'Surulere': 3.3581,
      'Yaba': 3.3711,
      'Oshodi': 3.3322,
      'Agege': 3.3131,
      'Ikorodu': 3.5107,
      'Alimosho': 3.2454,
      'Abuja': 7.3986,
      'Garki': 7.4951,
      'Wuse': 7.3986,
      'Maitama': 7.3986,
      'Asokoro': 7.4951,
      'Jabi': 7.3986,
      'Kubwa': 7.3986,
      'Gwarinpa': 7.3986,
      'Kano': 8.5317,
      'Ibadan': 3.8867,
      'Port Harcourt': 7.0498,
      'Kaduna': 7.4384,
      'Enugu': 7.5464,
      'Jos': 8.8583,
      'Benin': 5.6145,
      'Calabar': 8.3417,
      'Maiduguri': 13.1500,
      'Sokoto': 5.2333,
      'Katsina': 7.6014,
      'Bauchi': 9.8439,
      'Gombe': 11.1673,
      'Yola': 12.4667,
      'Jalingo': 11.3667,
      'Lafia': 8.5167,
      'Minna': 6.5569,
      'Lokoja': 6.7333,
      'Abakaliki': 8.1134,
      'Owerri': 7.0333,
      'Awka': 7.0689,
      'Asaba': 6.7500,
      'Warri': 5.7500,
      'Benin City': 5.6145,
      'Akure': 5.2000,
      'Ado Ekiti': 5.2167,
      'Osogbo': 4.5667,
      'Ilorin': 4.5500,
    };

    return coordinates[city] ?? coordinates[state] ?? 3.3792; // Default to Lagos
  }

  // Geocode an address string
  static Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    try {
      // Try Photon API first
      final results = await _searchWithPhotonAPI(address);
      
      if (results.isNotEmpty) {
        final result = results.first;
        return {
          'formatted_address': result['display_name'],
          'latitude': result['lat'],
          'longitude': result['lon'],
          'street': result['street'],
          'city': result['city'],
          'state': result['state'],
          'country': result['country'],
        };
      }

      // Fallback to local parsing
      return _parseAddressLocally(address);
    } catch (e) {
      print('Error geocoding address: $e');
      return _parseAddressLocally(address);
    }
  }

  // Parse address using local logic
  static Map<String, dynamic>? _parseAddressLocally(String address) {
    if (address.isEmpty) return null;

    final parts = address.split(',').map((part) => part.trim()).toList();
    
    if (parts.isEmpty) return null;

    String street = parts[0];
    String city = 'Lagos';
    String state = 'Lagos';

    if (parts.length > 1) {
      city = parts[1];
    }
    if (parts.length > 2) {
      state = parts[2];
    }

    // Normalize state
    state = _stateMapping[state.toLowerCase()] ?? state;

    return {
      'formatted_address': address,
      'latitude': _getApproximateLatitude(city, state),
      'longitude': _getApproximateLongitude(city, state),
      'street': street,
      'city': city,
      'state': state,
      'country': 'Nigeria',
    };
  }
} 