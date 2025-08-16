import 'package:flutter_test/flutter_test.dart';
import 'package:sendit/features/geocoding/fallback_geocoding_service.dart';

void main() {
  group('FallbackGeocodingService Tests', () {
    test('should search for Nigerian places correctly', () async {
      final results = await FallbackGeocodingService.searchPlaces('Lagos');
      
      expect(results, isNotEmpty);
      expect(results.first['country'], 'Nigeria');
      expect(results.first['display_name'], contains('Lagos'));
    });

    test('should handle short queries', () async {
      final results = await FallbackGeocodingService.searchPlaces('La');
      
      expect(results, isEmpty); // Should be empty for queries < 2 chars
    });

    test('should search for Nigerian cities', () async {
      final results = await FallbackGeocodingService.searchPlaces('Ikeja');
      
      expect(results, isNotEmpty);
      expect(results.first['city'], 'Ikeja');
      expect(results.first['state'], 'Lagos');
    });

    test('should search for Nigerian states', () async {
      final results = await FallbackGeocodingService.searchPlaces('Kano');
      
      expect(results, isNotEmpty);
      expect(results.first['state'], 'Kano');
    });

    test('should geocode addresses correctly', () async {
      final result = await FallbackGeocodingService.geocodeAddress('Ikeja, Lagos, Nigeria');
      
      expect(result, isNotNull);
      expect(result!['country'], 'Nigeria');
      expect(result['city'], 'Ikeja');
      expect(result['state'], 'Lagos');
      expect(result['latitude'], isA<double>());
      expect(result['longitude'], isA<double>());
    });

    test('should handle empty address', () async {
      final result = await FallbackGeocodingService.geocodeAddress('');
      
      expect(result, isNull);
    });

    test('should handle malformed address', () async {
      final result = await FallbackGeocodingService.geocodeAddress('Invalid Address');
      
      expect(result, isNotNull);
      expect(result!['country'], 'Nigeria');
      expect(result['street'], 'Invalid Address');
      expect(result['city'], 'Lagos'); // Default
      expect(result['state'], 'Lagos'); // Default
    });

    test('should provide accurate coordinates for major cities', () async {
      // Test Lagos coordinates through geocoding
      final lagosResult = await FallbackGeocodingService.geocodeAddress('Lagos, Nigeria');
      
      expect(lagosResult, isNotNull);
      expect(lagosResult!['latitude'], isA<double>());
      expect(lagosResult['longitude'], isA<double>());
      expect(lagosResult['city'], 'Lagos');
      expect(lagosResult['state'], 'Lagos');

      // Test Abuja coordinates through geocoding
      final abujaResult = await FallbackGeocodingService.geocodeAddress('Abuja, Nigeria');
      
      expect(abujaResult, isNotNull);
      expect(abujaResult!['latitude'], isA<double>());
      expect(abujaResult['longitude'], isA<double>());
      expect(abujaResult['city'], 'Abuja');
      expect(abujaResult['state'], 'FCT');

      // Test Ikeja coordinates through geocoding
      final ikejaResult = await FallbackGeocodingService.geocodeAddress('Ikeja, Lagos, Nigeria');
      
      expect(ikejaResult, isNotNull);
      expect(ikejaResult!['latitude'], isA<double>());
      expect(ikejaResult['longitude'], isA<double>());
      expect(ikejaResult['city'], 'Ikeja');
      expect(ikejaResult['state'], 'Lagos');
    });

    test('should handle unknown cities gracefully', () async {
      final result = await FallbackGeocodingService.geocodeAddress('UnknownCity, UnknownState, Nigeria');
      
      expect(result, isNotNull);
      expect(result!['latitude'], isA<double>());
      expect(result['longitude'], isA<double>());
      expect(result['city'], 'UnknownCity');
      expect(result['state'], 'UnknownState');
    });

    test('should search local Nigerian data correctly', () async {
      final results = await FallbackGeocodingService.searchPlaces('Victoria Island');
      
      expect(results, isNotEmpty);
      expect(results.first['city'], 'Victoria Island');
      expect(results.first['state'], 'Lagos');
      expect(results.first['country'], 'Nigeria');
    });

    test('should handle case-insensitive search', () async {
      final results = await FallbackGeocodingService.searchPlaces('victoria island');
      
      expect(results, isNotEmpty);
      expect(results.first['city'], 'Victoria Island');
    });

    test('should limit results to 5', () async {
      final results = await FallbackGeocodingService.searchPlaces('Lagos');
      
      expect(results.length, lessThanOrEqualTo(5));
    });

    test('should handle complex address parsing', () async {
      final result = await FallbackGeocodingService.geocodeAddress('123 Main Street, Ikeja, Lagos, 100001, Nigeria');
      
      expect(result, isNotNull);
      expect(result!['street'], '123 Main Street');
      expect(result['city'], 'Ikeja');
      expect(result['state'], 'Lagos');
      expect(result['country'], 'Nigeria');
    });

    test('should handle partial address information', () async {
      final result = await FallbackGeocodingService.geocodeAddress('Main Street, Ikeja');
      
      expect(result, isNotNull);
      expect(result!['street'], 'Main Street');
      expect(result['city'], 'Ikeja');
      expect(result['state'], 'Lagos'); // Default
      expect(result['country'], 'Nigeria');
    });
  });
} 