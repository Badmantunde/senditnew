import 'package:sendit/features/profile/data/address_service.dart';

class DummyAddresses {
  static final List<Map<String, dynamic>> addresses = [
    {
      'street': '12, Unity road, ikeja',
      'city': 'Ikeja',
      'state': 'Lagos',
      'postal_code': '100001',
      'country': 'Nigeria',
      'longtitude': '3.3792',
      'latitude': '6.6018',
    },
    {
      'street': '3B Ogunlana Drive, Off Masha Road, Surulere',
      'city': 'Surulere',
      'state': 'Lagos',
      'postal_code': '100002',
      'country': 'Nigeria',
      'longtitude': '3.3569',
      'latitude': '6.4924',
    },
    {
      'street': '15 Olayemi Street, Off Allen Avenue',
      'city': 'Ikeja',
      'state': 'Lagos',
      'postal_code': '100003',
      'country': 'Nigeria',
      'longtitude': '3.3654',
      'latitude': '6.6018',
    },
    {
      'street': '78B Admiralty Way, Lekki Phase 1',
      'city': 'Lekki',
      'state': 'Lagos',
      'postal_code': '100004',
      'country': 'Nigeria',
      'longtitude': '3.4736',
      'latitude': '6.4391',
    },
    {
      'street': '25 Victoria Island Crescent, Victoria Island',
      'city': 'Victoria Island',
      'state': 'Lagos',
      'postal_code': '100005',
      'country': 'Nigeria',
      'longtitude': '3.4219',
      'latitude': '6.4281',
    },
    {
      'street': '7 Ahmadu Bello Way, Victoria Island',
      'city': 'Victoria Island',
      'state': 'Lagos',
      'postal_code': '100006',
      'country': 'Nigeria',
      'longtitude': '3.4219',
      'latitude': '6.4281',
    },
    {
      'street': '42 Awolowo Road, Ikoyi',
      'city': 'Ikoyi',
      'state': 'Lagos',
      'postal_code': '100007',
      'country': 'Nigeria',
      'longtitude': '3.4219',
      'latitude': '6.4528',
    },
    {
      'street': '18 Banana Island Road, Banana Island',
      'city': 'Banana Island',
      'state': 'Lagos',
      'postal_code': '100008',
      'country': 'Nigeria',
      'longtitude': '3.4219',
      'latitude': '6.4528',
    },
  ];

  // Method to add all dummy addresses
  static Future<void> addAllDummyAddresses() async {
    for (final address in addresses) {
      try {
        await AddressService.createAddress(
          street: address['street'],
          city: address['city'],
          state: address['state'],
          postalCode: address['postal_code'],
          country: address['country'],
          longitude: address['longtitude'],
          latitude: address['latitude'],
        );
        print('Added dummy address: ${address['street']}');
      } catch (e) {
        print('Failed to add dummy address: ${address['street']} - $e');
      }
    }
  }

  // Method to add a specific number of dummy addresses
  static Future<void> addDummyAddresses(int count) async {
    final addressesToAdd = addresses.take(count).toList();
    for (final address in addressesToAdd) {
      try {
        await AddressService.createAddress(
          street: address['street'],
          city: address['city'],
          state: address['state'],
          postalCode: address['postal_code'],
          country: address['country'],
          longitude: address['longtitude'], // Required field
          latitude: address['latitude'],    // Required field
        );
        print('Added dummy address: ${address['street']}');
      } catch (e) {
        print('Failed to add dummy address: ${address['street']} - $e');
      }
    }
  }
} 