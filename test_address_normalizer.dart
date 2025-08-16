import 'package:flutter_test/flutter_test.dart';
import 'package:sendit/features/profile/data/address_normalizer.dart';

void main() {
  group('AddressNormalizer Tests', () {
    test('should normalize state names correctly', () {
      expect(AddressNormalizer.normalizeState('lagos'), 'Lagos');
      expect(AddressNormalizer.normalizeState('LAGOS'), 'Lagos');
      expect(AddressNormalizer.normalizeState('  lagos  '), 'Lagos');
      expect(AddressNormalizer.normalizeState('unknown'), 'Lagos'); // Default
      expect(AddressNormalizer.normalizeState('abuja'), 'FCT');
      expect(AddressNormalizer.normalizeState('enugu'), 'Enugu');
    });

    test('should normalize city names correctly', () {
      expect(AddressNormalizer.normalizeCity('lagos'), 'Lagos');
      expect(AddressNormalizer.normalizeCity('ikeja'), 'Ikeja');
      expect(AddressNormalizer.normalizeCity('victoria island'), 'Victoria Island');
      expect(AddressNormalizer.normalizeCity('unknown city'), 'unknown city'); // Return original
    });

    test('should parse and normalize full addresses', () {
      final result = AddressNormalizer.parseAndNormalizeAddress('Tofaan\'s Hopital, Adesulu Street, Ashipa');
      
      expect(result['street'], 'Tofaan\'s Hopital');
      expect(result['city'], 'Adesulu Street'); // Not in mapping, so returns original
      expect(result['state'], 'Lagos'); // Ashipa not in mapping, defaults to Lagos
    });

    test('should parse and normalize partial addresses', () {
      final result = AddressNormalizer.parseAndNormalizeAddress('Tofaan\'s Hopital, Ikeja');
      
      expect(result['street'], 'Tofaan\'s Hopital');
      expect(result['city'], 'Ikeja');
      expect(result['state'], 'Lagos'); // Default
    });

    test('should handle single street addresses', () {
      final result = AddressNormalizer.parseAndNormalizeAddress('Tofaan\'s Hopital');
      
      expect(result['street'], 'Tofaan\'s Hopital');
      expect(result['city'], 'Lagos'); // Default
      expect(result['state'], 'Lagos'); // Default
    });

    test('should handle empty addresses', () {
      final result = AddressNormalizer.parseAndNormalizeAddress('');
      
      expect(result['street'], 'Current Location');
      expect(result['city'], 'Lagos');
      expect(result['state'], 'Lagos');
    });

    test('should validate address data correctly', () {
      final errors = AddressNormalizer.validateAddress(
        street: 'Test Street',
        city: 'Lagos',
        state: 'Lagos',
        postalCode: '1234',
        country: 'Nigeria',
        longitude: '3.3792',
        latitude: '6.5244',
      );
      
      expect(errors, isEmpty);
    });

    test('should detect validation errors', () {
      final errors = AddressNormalizer.validateAddress(
        street: '',
        city: 'Lagos',
        state: 'Lagos',
        postalCode: '',
        country: 'Nigeria',
        longitude: 'invalid',
        latitude: '6.5244',
      );
      
      expect(errors.length, 3); // street, postal_code, longitude
      expect(errors.contains('Street is required'), true);
      expect(errors.contains('Postal code is required'), true);
      expect(errors.contains('Invalid coordinate format'), true);
    });

    test('should format address for display', () {
      final formatted = AddressNormalizer.formatAddressForDisplay(
        street: 'Tofaan\'s Hopital',
        city: 'Ikeja',
        state: 'Lagos',
        postalCode: '1234',
        country: 'Nigeria',
      );
      
      expect(formatted, 'Tofaan\'s Hopital, Ikeja, Lagos, 1234, Nigeria');
    });

    test('should get standardized address for API', () {
      final standardized = AddressNormalizer.getStandardizedAddress(
        street: 'Tofaan\'s Hopital',
        city: 'ikeja',
        state: 'lagos',
        postalCode: '1234',
        country: 'Nigeria',
        longitude: '3.3792',
        latitude: '6.5244',
      );
      
      expect(standardized['street'], 'Tofaan\'s Hopital');
      expect(standardized['city'], 'Ikeja'); // Normalized
      expect(standardized['state'], 'Lagos'); // Normalized
      expect(standardized['postal_code'], '1234');
      expect(standardized['country'], 'Nigeria');
      expect(standardized['longtitude'], '3.3792');
      expect(standardized['latitude'], '6.5244');
    });
  });
} 