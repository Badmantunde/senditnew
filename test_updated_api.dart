import 'package:sendit/api/index.dart';

void main() async {
  print('🧪 Testing Updated API Service with Profile-style Headers...');
  
  // Test order creation with new header pattern
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
    print('📤 Creating test order with updated API service...');
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
      
      // Check if it's an authentication error
      if (result.statusCode == 401) {
        print('🔐 Authentication error - token may be missing or expired');
      }
    } else {
      print('❌ Order creation failed');
      print('📝 Error: ${result.message}');
      print('🔢 Status Code: ${result.statusCode}');
    }
  } catch (e) {
    print('💥 Exception occurred: $e');
  }
  
  print('\n🔍 Testing API Service Methods...');
  
  // Test GET method
  try {
    print('📡 Testing GET method...');
    final getResult = await ApiService.get<Map<String, dynamic>>('/orders');
    print('GET Status: ${getResult.statusCode}');
    print('GET Success: ${getResult.success}');
  } catch (e) {
    print('GET Error: $e');
  }
  
  // Test POST method
  try {
    print('📡 Testing POST method...');
    final postResult = await ApiService.post<Map<String, dynamic>>(
      '/orders/compute',
      body: {
        'items': testItems,
        'pickup_address': testPickupAddress,
        'drop_off': testDropOffAddress,
        'payer': 'sender',
      },
    );
    print('POST Status: ${postResult.statusCode}');
    print('POST Success: ${postResult.success}');
  } catch (e) {
    print('POST Error: $e');
  }
} 