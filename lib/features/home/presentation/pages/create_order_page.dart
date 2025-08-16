import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sendit/api/index.dart';
import 'package:sendit/features/home/presentation/modal/order_modal.dart';
import 'package:sendit/features/home/presentation/modal/saved_address_modal.dart';
import 'package:sendit/features/home/presentation/pages/confirm_order_page.dart';
import 'package:sendit/features/home/presentation/pages/receiver_details_bottom_sheet.dart';
import 'package:sendit/features/profile/domain/entities/address.dart';
import 'package:sendit/features/home/presentation/pages/sender_details_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  bool saveSenderAddress = false;
  bool saveReceiverAddress = false;

  Future<void> saveAddressToLocalList(Map<String, dynamic> address, {required String type}) async {
    print('💾 Starting to save $type address to local cache...');
  final prefs = await SharedPreferences.getInstance();
  final key = type == 'sender' ? 'saved_sender_addresses' : 'saved_receiver_addresses';

  List<String> existing = prefs.getStringList(key) ?? [];

  // Avoid duplicates by checking if the address already exists
  final newEntry = jsonEncode(address);
  if (!existing.contains(newEntry)) {
    existing.add(newEntry);
    await prefs.setStringList(key, existing);
    print('✅ $type address saved to local cache. Total $type addresses: ${existing.length}');
    print('📍 Address details: $address');
  } else {
    print('ℹ️ $type address already exists in cache, skipping...');
  }
}

Future<void> saveCreatedOrderToLocal(Order order) async {
  print('💾 Starting to save order to local cache...');
  final prefs = await SharedPreferences.getInstance();
  
  // Get current user email
  final userEmail = prefs.getString('user_email');
  if (userEmail == null || userEmail.isEmpty) {
    print('❌ Error: No user email found. Cannot save order.');
    return;
  }
  
  print('👤 Saving order for user: $userEmail');
  
  // Create user-specific key for orders
  final userOrdersKey = 'created_orders_$userEmail';
  final existing = prefs.getStringList(userOrdersKey) ?? [];

  // Convert order to JSON and append
  final orderJson = jsonEncode(order.toJson());
  
  // Debug: Print the order data being saved
  print('🔍 Order being saved:');
  print('  - itemName: ${order.itemName}');
  print('  - imageFile: ${order.imageFile}');
  print('  - imageFilePath: ${order.imageFile?.path}');
  print('  - JSON data: ${order.toJson()}');
  
  existing.add(orderJson);

  await prefs.setStringList(userOrdersKey, existing);
  print('✅ Order saved to local cache for user $userEmail. Total orders: ${existing.length}');
  print('📋 Order details: ${order.toJson()}');
}

// Function to display cached data for debugging
Future<void> displayCachedData() async {
  print('🔍 Checking cached data...');
  final prefs = await SharedPreferences.getInstance();
  
  // Get current user email
  final userEmail = prefs.getString('user_email');
  if (userEmail == null || userEmail.isEmpty) {
    print('❌ Error: No user email found. Cannot display cached data.');
    return;
  }
  
  print('👤 Checking cached data for user: $userEmail');
  
  // Create user-specific key for orders
  final userOrdersKey = 'created_orders_$userEmail';
  final cachedOrders = prefs.getStringList(userOrdersKey) ?? [];
  print('📦 Cached Orders for user $userEmail (${cachedOrders.length}):');
  for (int i = 0; i < cachedOrders.length; i++) {
    try {
      final orderData = jsonDecode(cachedOrders[i]);
      print('  Order ${i + 1}: ${orderData['itemName']} - ${orderData['status']}');
    } catch (e) {
      print('  Order ${i + 1}: Invalid JSON');
    }
  }
  
  // Check cached sender addresses
  final cachedSenderAddresses = prefs.getStringList('saved_sender_addresses') ?? [];
  print('📍 Cached Sender Addresses (${cachedSenderAddresses.length}):');
  for (int i = 0; i < cachedSenderAddresses.length; i++) {
    try {
      final addressData = jsonDecode(cachedSenderAddresses[i]);
      print('  Sender ${i + 1}: ${addressData['name']} - ${addressData['address']}');
    } catch (e) {
      print('  Sender ${i + 1}: Invalid JSON');
    }
  }
  
  // Check cached receiver addresses
  final cachedReceiverAddresses = prefs.getStringList('saved_receiver_addresses') ?? [];
  print('📍 Cached Receiver Addresses (${cachedReceiverAddresses.length}):');
  for (int i = 0; i < cachedReceiverAddresses.length; i++) {
    try {
      final addressData = jsonDecode(cachedReceiverAddresses[i]);
      print('  Receiver ${i + 1}: ${addressData['name']} - ${addressData['address']}');
    } catch (e) {
      print('  Receiver ${i + 1}: Invalid JSON');
    }
  }
}


  Map<String, dynamic> pickupAddress = {};

  void openSenderDetailsBottomSheet() async {
  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SenderDetailsBottomSheet(saveAddress: saveSenderAddress),
  );

  if (result != null) {
    print('🔍 Sender address result: $result');
    // Check if we have essential address components
    if ((result['address'] != null && result['address'].toString().isNotEmpty) ||
        (result['street'] != null && result['city'] != null)) {
      setState(() {
        pickupAddress = Map<String, String>.from(result.map((key, value) => MapEntry(key, value.toString())));
      });
      print('✅ Pickup address set: $pickupAddress');
    } else {
      print('❌ Invalid sender address data received');
    }
  }
}

Map<String, String> dropoffAddress = {};

void openReceiverDetailsBottomSheet() async {
  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ReceiverDetailsBottomSheet(saveAddress: saveReceiverAddress),
  );

  if (result != null) {
    print('🔍 Receiver address result: $result');
    // Check if we have essential address components
    if ((result['address'] != null && result['address'].toString().isNotEmpty) ||
        (result['street'] != null && result['city'] != null)) {
      setState(() {
        dropoffAddress = Map<String, String>.from(result.map((key, value) => MapEntry(key, value.toString())));
      });
      print('✅ Dropoff address set: $dropoffAddress');
    } else {
      print('❌ Invalid receiver address data received');
    }
  }
}

void openSavedAddressModal({required bool isPickup}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SavedAddressModal(
        isPickup: isPickup,
        onAddressSelected: (Address address) {
          setState(() {
            if (isPickup) {
              pickupAddress = address.toOrderAddress();
            } else {
              dropoffAddress = address.toOrderAddress();
            }
          });
        },
      );
    },
  );
}

void openFavoriteReceiverModal(
    BuildContext context, Function(Map<String, dynamic>) onSelected) async {
  final prefs = await SharedPreferences.getInstance();
  final savedList = prefs.getStringList('saved_receiver_addresses') ?? [];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.7,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Favorite',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              SizedBox(height: 4),
              Divider(color: Colors.grey.shade200),

              // Address List
              Expanded(
                child: ListView.separated(
                  itemCount: savedList.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final decoded = Map<String, dynamic>.from(
                      jsonDecode(savedList[index]),
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(decoded); // Pass selected item instantly
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFFFFF4E7),
                              child: Icon(Icons.person, color: Colors.orange),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    decoded['name'] ?? '',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    decoded['phone'] ?? '',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    decoded['address'] ?? '',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}









  int currentStep = 0;

  final TextEditingController itemNameController = TextEditingController();
  String selectedCategory = '';
  String selectedWeight = '';
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isInsured = false;
  File? selectedFile;


  final List<String> categories = ['Electronics', 'Fashion', 'Documents', 'Groceries'];
  final List<String> weightRanges = ['0.5', '1', '2', '5', '10'];

  List<File> selectedFiles = [];

void pickFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: true,
  );

  if (result != null && result.files.isNotEmpty) {
    try {
      final List<File> permanentFiles = [];
      
      for (final path in result.paths) {
        if (path != null) {
          final originalFile = File(path);
          if (originalFile.existsSync()) {
            // Get the app's documents directory for permanent storage
            final appDir = await getApplicationDocumentsDirectory();
            final imagesDir = Directory('${appDir.path}/order_images');
            
            // Create the images directory if it doesn't exist
            if (!imagesDir.existsSync()) {
              imagesDir.createSync(recursive: true);
            }
            
            // Generate a unique filename
            final fileName = 'order_image_${DateTime.now().millisecondsSinceEpoch}_${originalFile.path.split('/').last}';
            final permanentPath = '${imagesDir.path}/$fileName';
            
            // Copy the file to permanent location
            final permanentFile = await originalFile.copy(permanentPath);
            permanentFiles.add(permanentFile);
            
            print('✅ Image copied to permanent location: $permanentPath');
          }
        }
      }
      
      setState(() {
        selectedFiles = permanentFiles;
      });
    } catch (e) {
      print('❌ Error copying image files: $e');
      // Fallback to original files if copying fails
      setState(() {
        selectedFiles = result.paths.whereType<String>().map((path) => File(path)).toList();
      });
    }
  }
}




  void validateAndGoToShipping() {
    if (itemNameController.text.isEmpty ||
        selectedCategory.isEmpty ||
        selectedWeight.isEmpty ||
        quantityController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required item details')),
      );
      return;
    }

    setState(() {
      currentStep = 1;
    });
  }

void submitOrder() async {
  // Validate required fields
  if (itemNameController.text.isEmpty ||
      selectedCategory.isEmpty ||
      selectedWeight.isEmpty ||
      quantityController.text.isEmpty ||
      descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all required item details')),
    );
    return;
  }

  // Validate addresses
  if (pickupAddress.isEmpty || dropoffAddress.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please add both Sender and Receiver details')),
    );
    return;
  }

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );

  try {
    // Prepare items for API
    final items = [
      {
        'name': itemNameController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': selectedCategory.toLowerCase(),
        'weight': selectedWeight,
        'quantity': int.tryParse(quantityController.text) ?? 1,
        'insured': isInsured,
      }
    ];

    // Debug: Print the data being sent
    print('🔍 Debug - Items being sent: $items');
    print('🔍 Debug - Pickup Address: $pickupAddress');
    print('🔍 Debug - Dropoff Address: $dropoffAddress');

    // Create order using API service
    final result = await OrderService.createOrder(
      items: items,
      pickupAddress: pickupAddress,
      dropOff: dropoffAddress,
      paymentMethod: 'card', // Use 'card' instead of 'paystack' to match API spec
      payer: 'owner', // Default payer
    );

    // Hide loading indicator
    Navigator.pop(context);

    if (result.success) {
      // Save addresses if requested
      if (saveSenderAddress) {
        await saveAddressToLocalList(pickupAddress, type: 'sender');
      }
      if (saveReceiverAddress) {
        await saveAddressToLocalList(dropoffAddress, type: 'receiver');
      }

      // Create and save order locally with all details including images
      final order = Order(
        itemName: itemNameController.text.trim(),
        quantity: quantityController.text.trim(),
        description: descriptionController.text.trim(),
        receiverAddress: dropoffAddress['formatted_address'] ?? dropoffAddress['address'] ?? 'No address',
        status: 'Created',
        imageFile: selectedFiles.isNotEmpty ? selectedFiles.first : null, // Save the first uploaded image
        trackingId: result.data?['order_id']?.toString(),
        senderDetails: {
          'name': pickupAddress['name'],
          'phone': pickupAddress['phone'],
          'address': pickupAddress['formatted_address'] ?? pickupAddress['address'],
        },
        receiverDetails: {
          'name': dropoffAddress['name'],
          'phone': dropoffAddress['phone'],
          'address': dropoffAddress['formatted_address'] ?? dropoffAddress['address'],
        },
        amount: result.data?['total_cost']?.toString() ?? 'N/A',
        payer: 'owner',
      );
      
      // Debug: Print image information
      if (selectedFiles.isNotEmpty) {
        print('🔍 Image file selected: ${selectedFiles.first.path}');
        print('🔍 Image file exists: ${selectedFiles.first.existsSync()}');
        print('🔍 Image file size: ${selectedFiles.first.lengthSync()} bytes');
        print('🔍 Image file absolute path: ${selectedFiles.first.absolute.path}');
      } else {
        print('⚠️ No image files selected');
      }
      
      await saveCreatedOrderToLocal(order);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order created successfully! Order ID: ${result.data?['order_id']}'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to home page with refresh flag
      Navigator.pop(context, true);
    } else {
      // Debug: Print the full API response for validation errors
      print('❌ API Error Response: ${result.message}');
      print('❌ API Status Code: ${result.statusCode}');
      print('❌ API Data: ${result.data}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to create order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // Hide loading indicator
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error creating order: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  Widget buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          minHeight: 8,
          value: currentStep == 0 ? 0.3 : 0.7,
          backgroundColor: Color(0xffd6ddeb),
          valueColor: AlwaysStoppedAnimation(Color(0xff198038)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      appBar: AppBar(
        title: Text('New Order', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xffffffff),
        foregroundColor: Color(0xff333333),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: currentStep == 0 ? buildItemDetails() : buildShippingInfo(),
        ),
      ),
    );
  }

  Widget buildItemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeader('Item details'),
        SizedBox(height: 16),
        buildProgressBar(),
        SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item Name', style: GoogleFonts.dmSans(fontSize: 14)),
                  SizedBox(height: 8),
              TextField(
                controller: itemNameController,
                decoration: InputDecoration(
                  hintText: 'iphone 15 Pro Max',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  filled: true,
                  fillColor: Color(0xffffffff),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xffD6DDEB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xffE28E3C)),
              ),
              ),),
                ],
              ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Category',
                style: GoogleFonts.dmSans(fontSize: 14),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory.isEmpty ? null : selectedCategory,
                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => selectedCategory = value ?? ''),
                decoration: InputDecoration(
                  hintText: '-Select category-',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  filled: true,
                  fillColor: Color(0xffffffff),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xffD6DDEB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xffE28E3C)),
                  ),
                ),
                style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          
          Row(
            children: [
              Expanded(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight Range (Kg)',
              style: GoogleFonts.dmSans(fontSize: 14),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedWeight.isEmpty ? null : selectedWeight,
              items: weightRanges
                  .map((weight) => DropdownMenuItem(value: weight, child: Text('$weight Kg')))
                  .toList(),
              onChanged: (value) => setState(() => selectedWeight = value ?? ''),
              decoration: InputDecoration(
                hintText: 'Item weight',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                filled: true,
                fillColor: Color(0xffffffff),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xffD6DDEB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xffE28E3C)),
                ),
              ),
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            ),
          ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantity',
              style: GoogleFonts.dmSans(fontSize: 14),
            ),
            SizedBox(height: 8),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter item quantity',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                filled: true,
                fillColor: Color(0xffffffff),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xffD6DDEB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xffE28E3C)),
                ),
              ),
            ),
          ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Description',
                style: GoogleFonts.dmSans(fontSize: 14),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
          hintText: 'Enter item description',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          filled: true,
          fillColor: Color(0xffffffff),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xffD6DDEB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xffE28E3C)),
          ),
                ),
              ),
              SizedBox(height: 12),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Add Insurance', style: GoogleFonts.dmSans(fontSize: 14)),
    Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: isInsured,
            onChanged: (value) => setState(() => isInsured = value),
            
            activeColor: Color(0xffE28E3C)
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Insure my parcel',
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    ),
  ],
),

        SizedBox(height: 12),

        GestureDetector(
          onTap: pickFile,
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: selectedFiles.isEmpty
    ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 30, color: Colors.grey),
          Text(
            'Choose files',
            style: GoogleFonts.dmSans(color: Color(0xff0066CC)),
          ),
          Text(
            '(JPG, PNG. Max 5MB each)',
            style: GoogleFonts.dmSans(color: Color(0xff041438), fontSize: 12),
          ),
        ],
      )
    : Wrap(
  spacing: 8,
  runSpacing: 8,
  children: selectedFiles.asMap().entries.map((entry) {
    int index = entry.key;
    File file = entry.value;

    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFiles.removeAt(index);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }).toList(),
)



            ),
          ),
        ),

        SizedBox(height: 24),
        SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: validateAndGoToShipping,
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xffE28E3C),  // Use your primary orange color for consistency
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
    ),
    child: Text(
      'Next',
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
            ],
          ),
          SizedBox(height: 12),
          
            ],
          ),
        ),

      ],
    );
  }
  
  Widget buildShippingInfo() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionHeader('Shipping Information'),
      SizedBox(height: 16),
  
      buildProgressBar(),
      SizedBox(height: 24),
      // Choose from saved address
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: GestureDetector(
          onTap: () => openSavedAddressModal(isPickup: true), 
          child: Text(
            'Choose from saved address',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Color(0xffE68A34),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xffE68A34),
            ),
          ),
        ),
      ),
      SizedBox(height: 16),
  
      // Pickup Address Card
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: buildAddressCard(
          title: 'Pickup',
          buttonText: 'Add Sender Details',
          addressType: 'sender',
          icon: Icons.person,
          onAdd: openSenderDetailsBottomSheet,
          addressText: pickupAddress.isNotEmpty
              ? '${pickupAddress['name'] ?? ''}\n${pickupAddress['phone'] ?? ''}\n${pickupAddress['address'] ?? ''}'
              : null,
            
        ),
      ),
  
      
      SizedBox(height: 24),
  
      // Select from favorite
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: GestureDetector(
          onTap: () => openFavoriteReceiverModal(context, (selectedAddress) {
          setState(() {
            dropoffAddress = Map<String, String>.from(selectedAddress);
          });
        }),
          child: Text(
            'Select from favorite',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Color(0xffE68A34),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xffE68A34),
            ),
          ),
        ),
      ),
      SizedBox(height: 16),
  
      // Dropoff Address Card
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: buildAddressCard(
          title: 'Dropoff',
          buttonText: 'Add Receiver Details',
          addressType: 'receiver',
          icon: Icons.person,
          onAdd: openReceiverDetailsBottomSheet,
          addressText: dropoffAddress.isNotEmpty
              ? '${dropoffAddress['name'] ?? ''}\n${dropoffAddress['phone'] ?? ''}\n${dropoffAddress['email'] ?? ''}\n${dropoffAddress['address'] ?? ''}'
              : null,
            
            
        ),
      ),
      SizedBox(height: 24),
  
      // Next Button
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => navigateToOrderDetails(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffE28E3C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Next',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}

Widget buildAddressCard({
  required String title,
  required String buttonText,
  required String addressType,
  required IconData icon,
  required VoidCallback onAdd,
  String? addressText,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          blurRadius: 6,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            OutlinedButton(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xffE28E3C),
                side: BorderSide(color: Color(0xffD6DDEB)),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.dmSans(fontSize: 12),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
                addressText != null && addressText.isNotEmpty
                    ? 'assets/images/person-orange.svg'  // when details are filled
                    : 'assets/images/person-grey.svg',  // default
                width: 42,
                height: 42,
              ),



            SizedBox(width: 12),
            Expanded(
              child: addressText != null && addressText.isNotEmpty
                  ? Text(
                      addressText,
                      style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade800),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                    )
                  : SizedBox.shrink(),  // Show nothing when no address
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                  value: addressType == 'sender' ? saveSenderAddress : saveReceiverAddress,
                  onChanged: (value) {
                    setState(() {
                      if (addressType == 'sender') {
                        saveSenderAddress = value;
                      } else {
                        saveReceiverAddress = value;
                      }
                    });
                  },
                  activeColor: Color(0xffE28E3C)
                ),
            ),

            Text('Save Address', style: GoogleFonts.dmSans(fontSize: 14, color: Color(0xff9EA2AD))),
          ],
        ),
      ],
    ),
  );
}

  

  Widget sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      color: Color(0xffCCD3D3),
      child: Text(
        title,
        style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff1D4135)),
      ),
    );
  }

  void navigateToOrderDetails() async {
    // Validate required fields
    if (itemNameController.text.isEmpty ||
        selectedCategory.isEmpty ||
        selectedWeight.isEmpty ||
        quantityController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required item details')),
      );
      return;
    }

    // Validate addresses
    if (pickupAddress.isEmpty || dropoffAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add both Sender and Receiver details')),
      );
      return;
    }

    print('🔍 Navigating to ConfirmOrderPage with:');
    print('🔍 Pickup Address: $pickupAddress');
    print('🔍 Dropoff Address: $dropoffAddress');
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmOrderPage(
          sender: Map<String, String>.from(pickupAddress),
          receiver: Map<String, String>.from(dropoffAddress),
          itemName: itemNameController.text.trim(),
          quantity: quantityController.text.trim(),
          description: descriptionController.text.trim(),
          previewImage: selectedFiles.isNotEmpty ? selectedFiles.first : null,
        ),
      ),
    );
    
    // If order was successfully created, return to home page with refresh signal
    if (result == true) {
      Navigator.pop(context, true); // Return to home page with success
    }
  }

}
