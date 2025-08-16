import 'package:sendit/features/profile/data/address_service.dart';
import 'package:sendit/features/profile/data/dummy_addresses.dart';

void main() async {
  print('Testing Address Management API...\n');

  try {
    // Test 1: Add dummy addresses
    print('1. Adding dummy addresses...');
    await DummyAddresses.addDummyAddresses(3);
    print('✓ Added 3 dummy addresses\n');

    // Test 2: List addresses
    print('2. Listing addresses...');
    final addresses = await AddressService.listAddresses();
    print('✓ Found ${addresses.length} addresses');
    for (final address in addresses) {
      print('  - ${address['street']}, ${address['city']}');
    }
    print('');

    // Test 3: Get address by ID
    if (addresses.isNotEmpty) {
      print('3. Getting address by ID...');
      final firstAddress = addresses.first;
      final addressId = firstAddress['address_id'];
      final address = await AddressService.getAddressById(addressId);
      print('✓ Retrieved address: ${address['street']}, ${address['city']}\n');

      // Test 4: Update address
      print('4. Updating address...');
      final updatedAddress = await AddressService.updateAddress(
        addressId: addressId,
        street: 'Updated ${address['street']}',
        city: address['city'],
        state: address['state'],
        postalCode: address['postal_code'],
        country: address['country'],
      );
      print('✓ Updated address: ${updatedAddress['street']}\n');

      // Test 5: Delete address
      print('5. Deleting address...');
      final deleted = await AddressService.deleteAddress(addressId);
      if (deleted) {
        print('✓ Address deleted successfully\n');
      } else {
        print('✗ Failed to delete address\n');
      }
    }

    print('All tests completed successfully!');
  } catch (e) {
    print('Test failed with error: $e');
  }
} 