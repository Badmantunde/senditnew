import 'package:sendit/features/profile/data/address_service.dart';
import 'package:sendit/features/profile/data/address_normalizer.dart';

void main() async {
  print('=== ADDRESS SAVE DEBUG TEST ===\n');

  try {
    // Test 1: Address Normalizer
    print('1. Testing Address Normalizer...');
    final testAddresses = [
      'Ashipa Street, Agege, Lagos',
      'Victoria Island, Lagos',
      'Ikeja, Lagos',
      'Current Location',
      '',
    ];

    for (final address in testAddresses) {
      print('  Testing: "$address"');
      final parsed = AddressNormalizer.parseAndNormalizeAddress(address);
      print('  Result: $parsed');
    }
    print('✅ Address normalizer tests completed\n');

    // Test 2: Address Validation
    print('2. Testing Address Validation...');
    final validationResult = AddressNormalizer.validateAddress(
      street: 'Test Street',
      city: 'Test City',
      state: 'Test State',
      postalCode: '12345',
      country: 'Nigeria',
      longitude: '3.3792',
      latitude: '6.5244',
    );
    print('  Validation errors: $validationResult');
    print('✅ Address validation test completed\n');

    // Test 3: Address Service (if token available)
    print('3. Testing Address Service...');
    try {
      final result = await AddressService.createAddress(
        street: 'Test Street',
        city: 'Test City',
        state: 'Lagos',
        postalCode: '12345',
        country: 'Nigeria',
        longitude: '3.3792',
        latitude: '6.5244',
      );
      print('  ✅ Address created successfully: ${result['address_id']}');
    } catch (e) {
      print('  ❌ Address creation failed: $e');
      print('  This is expected if no valid token is available');
    }
    print('✅ Address service test completed\n');

    // Test 4: Token Check
    print('4. Testing Token Availability...');
    try {
      final token = await AddressService.getToken();
      if (token != null) {
        print('  ✅ Token found: ${token.substring(0, 20)}...');
      } else {
        print('  ❌ No token found');
      }
    } catch (e) {
      print('  ❌ Token check failed: $e');
    }
    print('✅ Token check completed\n');

    print('=== ALL TESTS COMPLETED ===');
  } catch (e) {
    print('❌ Test failed with error: $e');
  }
} 