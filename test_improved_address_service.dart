import 'package:flutter_test/flutter_test.dart';
import 'package:sendit/features/profile/data/address_service.dart';
import 'package:sendit/features/profile/data/address_normalizer.dart';

void main() {
  group('Improved AddressService Tests', () {
    test('should parse and normalize address correctly', () {
      final result = AddressNormalizer.parseAndNormalizeAddress('Ashipa Street, Agege, Lagos, 100276, Nigeria');
      
      expect(result['street'], 'Ashipa Street');
      expect(result['city'], 'Agege');
      expect(result['state'], 'Lagos');
    });

    test('should handle address with unknown city and state', () {
      final result = AddressNormalizer.parseAndNormalizeAddress('Tofaan\'s Hopital, Adesulu Street, Ashipa');
      
      expect(result['street'], 'Tofaan\'s Hopital');
      expect(result['city'], 'Adesulu Street'); // Not in mapping, returns original
      expect(result['state'], 'Lagos'); // Ashipa not in mapping, defaults to Lagos
    });

    test('should validate address data correctly', () {
      final errors = AddressNormalizer.validateAddress(
        street: 'Ashipa Street',
        city: 'Agege',
        state: 'Lagos',
        postalCode: '1234',
        country: 'Nigeria',
        longitude: '3.313076',
        latitude: '6.6274303',
      );
      
      expect(errors, isEmpty);
    });

    test('should detect validation errors', () {
      final errors = AddressNormalizer.validateAddress(
        street: '',
        city: 'Agege',
        state: 'Lagos',
        postalCode: '',
        country: 'Nigeria',
        longitude: 'invalid',
        latitude: '6.6274303',
      );
      
      expect(errors.length, 3); // street, postal_code, longitude
      expect(errors.contains('Street is required'), true);
      expect(errors.contains('Postal code is required'), true);
      expect(errors.contains('Invalid coordinate format'), true);
    });

    test('should get standardized address for API', () {
      final standardized = AddressNormalizer.getStandardizedAddress(
        street: 'Ashipa Street',
        city: 'agege',
        state: 'lagos',
        postalCode: '1234',
        country: 'Nigeria',
        longitude: '3.313076',
        latitude: '6.6274303',
      );
      
      expect(standardized['street'], 'Ashipa Street');
      expect(standardized['city'], 'Agege'); // Normalized
      expect(standardized['state'], 'Lagos'); // Normalized
      expect(standardized['postal_code'], '1234');
      expect(standardized['country'], 'Nigeria');
      expect(standardized['longtitude'], '3.313076');
      expect(standardized['latitude'], '6.6274303');
    });

    test('should handle empty address input', () {
      final result = AddressNormalizer.parseAndNormalizeAddress('');
      
      expect(result['street'], 'Current Location');
      expect(result['city'], 'Lagos');
      expect(result['state'], 'Lagos');
    });

    test('should handle single street address', () {
      final result = AddressNormalizer.parseAndNormalizeAddress('Ashipa Street');
      
      expect(result['street'], 'Ashipa Street');
      expect(result['city'], 'Lagos'); // Default
      expect(result['state'], 'Lagos'); // Default
    });

    test('should handle street and city only', () {
      final result = AddressNormalizer.parseAndNormalizeAddress('Ashipa Street, Agege');
      
      expect(result['street'], 'Ashipa Street');
      expect(result['city'], 'Agege');
      expect(result['state'], 'Lagos'); // Default
    });

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

    test('should format address for display', () {
      final formatted = AddressNormalizer.formatAddressForDisplay(
        street: 'Ashipa Street',
        city: 'Agege',
        state: 'Lagos',
        postalCode: '1234',
        country: 'Nigeria',
      );
      
      expect(formatted, 'Ashipa Street, Agege, Lagos, 1234, Nigeria');
    });
  });
} 