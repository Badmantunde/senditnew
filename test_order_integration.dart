import 'package:sendit/api/index.dart';

void main() async {
  print('🧪 Testing Order API Integration...');
  
  // Test order creation
  final testItems = [
    {
      'name': 'Iphone 16',
      'description': 'Test description',
      'category': 'electronics',
      'weight': '0.5',
      'quantity': 2,
      'insured': true,
    }
  ];

  final testPickupAddress = {
    'street': 'GRA',
    'state': 'Lagos',
    'city': 'Ikeja',
    'country': 'Nigeria',
    'postal_code': '1234',
    'longitude': '8.687872',
    'latitude': '49.420318',
  };

  final testDropOffAddress = {
    'street': 'Victoria Island',
    'state': 'Lagos',
    'city': 'Lagos',
    'country': 'Nigeria',
    'postal_code': '2345',
    'longitude': '8.687872',
    'latitude': '49.420318',
  };

  try {
    print('📤 Creating test order...');
    final result = await OrderService.createOrder(
      items: testItems,
      pickupAddress: testPickupAddress,
      dropOff: testDropOffAddress,
      paymentMethod: 'paystack',
      payer: 'sender',
    );

    if (result.success) {
      print('✅ Order created successfully!');
      print('📋 Order ID: ${result.data?['order_id']}');
      print('📝 Message: ${result.data?['message']}');
    } else {
      print('❌ Order creation failed');
      print('📝 Error: ${result.message}');
      print('🔢 Status Code: ${result.statusCode}');
    }
  } catch (e) {
    print('💥 Exception occurred: $e');
  }
} 