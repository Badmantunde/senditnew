import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sendit/features/home/presentation/pages/create_order_page.dart';
import 'package:sendit/features/home/presentation/pages/notification_screen.dart';
import 'package:sendit/features/home/presentation/pages/order_history_screen.dart';
import 'package:sendit/features/home/presentation/pages/order_detail_page.dart';
import 'package:sendit/features/profile/presentation/profile_screen.dart';
import 'package:sendit/features/profile/presentation/support_screen.dart';
import 'package:sendit/features/wallet/wallet_screen.dart';
import 'package:sendit/features/wallet/wallet_service.dart';
import 'package:sendit/features/profile/data/avatar_service.dart';
import 'package:sendit/main_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sendit/features/home/presentation/modal/order_modal.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String? firstName;
  String? lastName;
  late String formattedDate;
  bool _showBalance = true;
  int selectedTabIndex = 0;
  late WalletService _walletService;
  late AvatarService _avatarService;
  List<Map<String, dynamic>> createdOrders = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());
    _walletService = WalletService();
    _walletService.initializeBalance();
    _avatarService = AvatarService();
    _initializeAvatarForCurrentUser();
    loadUserName();
    _migrateOldOrders(); // Migrate old orders to user-specific storage
    clearTemplateOrders(); // Clear any existing template orders first
    loadCreatedOrders();
  }

  Future<void> _initializeAvatarForCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      if (userEmail != null && userEmail.isNotEmpty) {
        await _avatarService.setCurrentUser(userEmail);
      } else {
        print('HomePage: No user email found, waiting for user initialization...');
        // Wait for user to be initialized (e.g., during login process)
        final initialized = await _avatarService.waitForUserInitialization();
        if (!initialized) {
          print('HomePage: User initialization failed, falling back to initializeAvatar');
          await _avatarService.initializeAvatar();
        }
      }
    } catch (e) {
      print('Error initializing avatar for current user: $e');
      await _avatarService.initializeAvatar();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Method to migrate old orders to user-specific storage
  Future<void> _migrateOldOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get current user email
      final userEmail = prefs.getString('user_email');
      if (userEmail == null || userEmail.isEmpty) {
        print('❌ Error: No user email found. Cannot migrate orders.');
        return;
      }
      
      // Check if old orders exist
      final oldOrders = prefs.getStringList('created_orders') ?? [];
      if (oldOrders.isEmpty) {
        print('ℹ️ No old orders to migrate');
        return;
      }
      
      print('🔄 Migrating ${oldOrders.length} old orders to user-specific storage for user: $userEmail');
      
      // Create user-specific key for orders
      final userOrdersKey = 'created_orders_$userEmail';
      final existingUserOrders = prefs.getStringList(userOrdersKey) ?? [];
      
      // Combine old orders with existing user orders
      final allOrders = [...existingUserOrders, ...oldOrders];
      
      // Save to user-specific storage
      await prefs.setStringList(userOrdersKey, allOrders);
      
      // Remove old orders
      await prefs.remove('created_orders');
      
      print('✅ Successfully migrated ${oldOrders.length} orders to user-specific storage');
    } catch (e) {
      print('❌ Error migrating old orders: $e');
    }
  }

  // Method to clear any template or test orders from the cache
  Future<void> clearTemplateOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get current user email
      final userEmail = prefs.getString('user_email');
      if (userEmail == null || userEmail.isEmpty) {
        print('❌ Error: No user email found. Cannot clear template orders.');
        return;
      }
      
      // Create user-specific key for orders
      final userOrdersKey = 'created_orders_$userEmail';
      final cachedOrders = prefs.getStringList(userOrdersKey) ?? [];
      
      if (cachedOrders.isNotEmpty) {
        final validOrders = <String>[];
        
        for (final orderJson in cachedOrders) {
          try {
            final order = Map<String, dynamic>.from(jsonDecode(orderJson));
            
            // Keep only valid, non-template orders
            if (_isValidOrder(order)) {
              validOrders.add(orderJson);
            }
          } catch (e) {
            print('❌ Error parsing order during cleanup: $e');
          }
        }
        
        // Update the cache with only valid orders
        if (validOrders.length != cachedOrders.length) {
          await prefs.setStringList(userOrdersKey, validOrders);
          print('🧹 Initial cleanup for user $userEmail: removed ${cachedOrders.length - validOrders.length} template orders');
        }
      }
    } catch (e) {
      print('❌ Error during template order cleanup: $e');
    }
  }

  // Method to manually refresh orders
  Future<void> refreshOrders() async {
    await clearTemplateOrders();
    await loadCreatedOrders();
    print('🔄 Orders refreshed manually');
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh avatar and user data when app is resumed
      _initializeAvatarForCurrentUser();
      loadUserName();
      clearTemplateOrders(); // Clear any template orders
      loadCreatedOrders(); // Load valid orders
    }
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? '';
      lastName = prefs.getString('lastName') ?? '';
    });
  }

  // Method to refresh avatar and user data
  Future<void> refreshUserData() async {
    await _initializeAvatarForCurrentUser();
    await loadUserName();
  }

  // Method to be called when the page becomes visible
  void onPageVisible() {
    refreshUserData();
  }

  Future<void> loadCreatedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get current user email
    final userEmail = prefs.getString('user_email');
    if (userEmail == null || userEmail.isEmpty) {
      print('❌ Error: No user email found. Cannot load orders.');
      setState(() {
        createdOrders = [];
      });
      return;
    }
    
    print('👤 Loading orders for user: $userEmail');
    
    // Create user-specific key for orders
    final userOrdersKey = 'created_orders_$userEmail';
    final cachedOrders = prefs.getStringList(userOrdersKey) ?? [];
    
    print('🔍 Loading ${cachedOrders.length} cached orders for user $userEmail...');
    
    // Filter out template or incomplete orders
    final validOrders = <Map<String, dynamic>>[];
    
    for (final orderJson in cachedOrders) {
      try {
        // First try to reconstruct as Order object to ensure proper field mapping
        final order = Order.fromJson(jsonDecode(orderJson));
        
        // Debug: Print the reconstructed order data
        print('🔍 Reconstructed order: ${order.itemName}');
        print('  - imageFilePath: ${order.imageFile?.path}');
        print('  - imageFile: ${order.imageFile}');
        print('  - imagePath: ${order.imagePath}');
        
        // Check if the image file still exists
        if (order.imageFile != null) {
          print('  - Image file exists: ${order.imageFile!.existsSync()}');
          print('  - Image file size: ${order.imageFile!.existsSync() ? order.imageFile!.lengthSync() : 'N/A'} bytes');
        }
        
        // Convert back to Map for compatibility with existing code
        final orderMap = order.toJson();
        
        // Add the imageFile field back to the map since toJson() doesn't include it
        if (order.imageFile != null) {
          orderMap['imageFile'] = order.imageFile;
        }
        
        // Debug: Print the converted map data
        print('🔍 Converted order map:');
        print('  - imageFilePath: ${orderMap['imageFilePath']}');
        print('  - imageFile: ${orderMap['imageFile']}');
        print('  - imagePath: ${orderMap['imagePath']}');
        
        // Check if this is a valid, complete order (not a template)
        if (_isValidOrder(orderMap)) {
          validOrders.add(orderMap);
        } else {
          print('⚠️ Filtering out incomplete/template order: ${order.itemName}');
        }
      } catch (e) {
        print('❌ Error parsing order JSON: $e');
        // Fallback to direct JSON parsing if Order.fromJson fails
        try {
          final order = Map<String, dynamic>.from(jsonDecode(orderJson));
          
          // Debug: Print the loaded order data
          print('🔍 Loaded order (fallback): ${order['itemName']}');
          print('  - imageFilePath: ${order['imageFilePath']}');
          print('  - imageFile: ${order['imageFile']}');
          print('  - imagePath: ${order['imagePath']}');
          print('  - All available fields: ${order.keys.toList()}');
          
          if (_isValidOrder(order)) {
            validOrders.add(order);
          }
        } catch (fallbackError) {
          print('❌ Fallback parsing also failed: $fallbackError');
          // Remove invalid JSON entries
          cachedOrders.remove(orderJson);
        }
      }
    }
    
    // Update the cached orders to remove invalid ones
    if (cachedOrders.length != validOrders.length) {
      final validOrderJsons = validOrders.map((order) => jsonEncode(order)).toList();
      await prefs.setStringList(userOrdersKey, validOrderJsons);
      print('🧹 Cleaned up cached orders for user $userEmail: removed ${cachedOrders.length - validOrders.length} invalid entries');
    }
    
    setState(() {
      createdOrders = validOrders;
    });
    
    print('✅ Loaded ${validOrders.length} valid orders');
  }

  // Helper method to determine if an order is valid and complete (not a template)
  bool _isValidOrder(Map<String, dynamic> order) {
    // Check for required fields that indicate a real order
    // Support both old and new order structures
    final hasItemName = order['itemName'] != null && order['itemName'].toString().isNotEmpty;
    
    // Check for sender details (new structure)
    final hasSenderDetails = order['senderDetails'] != null && 
                            order['senderDetails'] is Map<String, dynamic> &&
                            order['senderDetails']['name'] != null && 
                            order['senderDetails']['name'].toString().isNotEmpty;
    
    // Check for receiver details (new structure)
    final hasReceiverDetails = order['receiverDetails'] != null && 
                              order['receiverDetails'] is Map<String, dynamic> &&
                              order['receiverDetails']['name'] != null && 
                              order['receiverDetails']['name'].toString().isNotEmpty;
    
    // Check for old structure fields (backward compatibility)
    final hasOldSenderFields = order['senderName'] != null && 
                              order['senderName'].toString().isNotEmpty &&
                              order['senderAddress'] != null && 
                              order['senderAddress'].toString().isNotEmpty;
    
    final hasOldReceiverFields = order['receiverName'] != null && 
                                order['receiverName'].toString().isNotEmpty &&
                                order['receiverAddress'] != null && 
                                order['receiverAddress'].toString().isNotEmpty;
    
    final hasRequiredFields = hasItemName && 
                             (hasSenderDetails || hasOldSenderFields) && 
                             (hasReceiverDetails || hasOldReceiverFields);
    
    // Check if it's not a test/template order
    final isNotTestOrder = !order['itemName'].toString().toLowerCase().contains('test') &&
                          !order['itemName'].toString().toLowerCase().contains('sample') &&
                          !order['itemName'].toString().toLowerCase().contains('dummy') &&
                          !order['itemName'].toString().toLowerCase().contains('mock') &&
                          !order['itemName'].toString().toLowerCase().contains('iphone 16'); // Common test item
    
    // Check if it has a proper status
    final hasValidStatus = order['status'] != null && 
                          order['status'].toString().isNotEmpty &&
                          order['status'] != 'draft' &&
                          order['status'] != 'template';
    
    return hasRequiredFields && isNotTestOrder && hasValidStatus;
  }

  // Method to be called when returning from create order page
  Future<void> onOrderCreated() async {
    await clearTemplateOrders(); // Clear any template orders first
    await loadCreatedOrders(); // Then load the valid orders
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          // Fixed green header section
          Container(
            color: const Color(0xff1D4135),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildUserInfo(),
                      _buildNotificationIcon(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildWalletCard(),
                ],
              ),
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildOrderTabs(screenHeight),
                  const SizedBox(height: 16),
                  _buildBannerAd(),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
          child: ListenableBuilder(
            listenable: _avatarService,
            builder: (context, child) {
              return CircleAvatar(
                radius: 20,
                backgroundImage: _avatarService.avatarUrl != null && _avatarService.avatarUrl!.isNotEmpty
                    ? NetworkImage(_avatarService.avatarUrl!)
                    : AssetImage('assets/images/avi.jpg') as ImageProvider,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                'Hello, ${firstName ?? 'Nelson'}!',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            );
          },
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
  return Container(
    height: 45,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade500),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      decoration: InputDecoration(
        hintText: 'Track your shipment',
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        suffixIcon: Container(
          decoration: const BoxDecoration(
            color: Color(0xff3B524A),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
      ),
    ),
  );
}

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF28D35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Balance',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ListenableBuilder(
                      listenable: _walletService,
                      builder: (context, child) {
                        return Text(
                          _showBalance ? _walletService.getFormattedBalance() : '******',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showBalance = !_showBalance;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _showBalance
                              ? Icons.visibility_outlined
                              : Icons.visibility_off,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (context) => const MainScaffold(startingIndex: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xff166B54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_circle_outline, size: 16),
            label: Text(
              'Fund wallet',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTabs(double screenHeight) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton('Active Order', 0),
              const SizedBox(width: 10),
              _buildTabButton('Create Orders', 1),
            ],
          ),
        ),
        // Tab Content
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          width: double.infinity,
          height: screenHeight * 0.5, // Fixed height instead of minHeight
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: selectedTabIndex == 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/box.png', width: 120),
                    const SizedBox(height: 16),
                    Text('No Active Order',
                        style: GoogleFonts.instrumentSans(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Click "create order" button to get started with creating your order.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                )
              : createdOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'No order has been created',
                            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreateOrderPage()),
                              );
                              // Refresh orders when returning from create order page with success
                              if (result == true) {
                                refreshOrders();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xffE28E3C)),
                              foregroundColor: const Color(0xffE28E3C),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Create Order',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Header with Create Order button and refresh button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Created Orders (${createdOrders.length})',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // Create Order button
                              OutlinedButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const CreateOrderPage()),
                                      );
                                      // Refresh orders when returning from create order page with success
                                      if (result == true) {
                                        refreshOrders();
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xffE28E3C)),
                                      foregroundColor: const Color(0xffE28E3C),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      'Create Order',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Orders List - Now properly scrollable
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: createdOrders.length,
                            itemBuilder: (context, index) {
                              final order = createdOrders[index];
                              
                              // Handle both old and new order structures
                              final itemName = order['itemName'] ?? order['items']?[0]?['name'] ?? 'Unknown Item';
                              
                              return GestureDetector(
                                onTap: () async {
                                  // Debug: Print the actual cached order data
                                  print('🔍 Cached order data for index $index:');
                                  print('  - Full order: $order');
                                  print('  - itemName: ${order['itemName']}');
                                  print('  - description: ${order['description']}');
                                  print('  - quantity: ${order['quantity']}');
                                  print('  - senderDetails: ${order['senderDetails']}');
                                  print('  - receiverDetails: ${order['receiverDetails']}');
                                  print('  - imageFilePath: ${order['imageFilePath']}');
                                  print('  - imageFile: ${order['imageFile']}');
                                  print('  - amount: ${order['amount']}');
                                  print('  - trackingId: ${order['trackingId']}');
                                  
                                  // Navigate to order detail screen with complete order data
                                  // Pass the original cached order data to preserve all information
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailPage(
                                        order: order, // Pass the original cached order data
                                      ),
                                    ),
                                  );
                                  // Refresh orders when returning from order detail screen
                                  if (result == true) {
                                    refreshOrders();
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      // Order Image
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: _buildOrderImage(order),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 12),
                                      
                                      // Item details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Item name
                                            Text(
                                              itemName,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            
                                            // Receiver address
                                            Text(
                                              order['receiverAddress'] ?? order['dropoffAddress']?['formatted_address'] ?? 'No delivery address',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Status and Forward arrow
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(order['status'] ?? 'Created').withOpacity(0.1),
                                            ),
                                            child: Text(
                                              order['status'] ?? 'Created',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: getStatusColor(order['status'] ?? 'Created'),
                                              ),
                                            ),
                                          ),
                                        ],
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
        ],
      ),
    );
  }

  Widget _buildBannerAd() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Container(
        width: double.infinity,
        height: 161,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/ads-banner.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Fund your sendit wallet for fast and easy delivery',
              style: GoogleFonts.instrumentSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainScaffold(startingIndex: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff166B54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_circle_outline_outlined, size: 16),
              label: Text(
                'Fund wallet',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderImage(Map<String, dynamic> order) {
    // Debug: Print the order data to see what fields are available
    print('🔍 Building order image for order: ${order['itemName']}');
    print('🔍 Order image fields: imageFilePath=${order['imageFilePath']}, imageFile=${order['imageFile']}, imagePath=${order['imagePath']}');
    print('🔍 All available fields: ${order.keys.toList()}');
    
    // First try to get the uploaded image file from imageFilePath
    if (order['imageFilePath'] != null && order['imageFilePath'].toString().isNotEmpty) {
      try {
        final imageFile = File(order['imageFilePath']);
        if (imageFile.existsSync()) {
          print('✅ Found image file at path: ${order['imageFilePath']}');
          return Image.file(
            imageFile,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error loading image file: $error');
              return _buildDefaultOrderIcon();
            },
          );
        } else {
          print('❌ Image file does not exist at path: ${order['imageFilePath']}');
        }
      } catch (e) {
        print('❌ Error accessing image file: $e');
      }
    }
    
    // Fallback to imageFile if it exists (for backward compatibility)
    if (order['imageFile'] != null) {
      try {
        if (order['imageFile'] is File) {
          final imageFile = order['imageFile'] as File;
          if (imageFile.existsSync()) {
            print('✅ Found image file object');
            return Image.file(
              imageFile,
              fit: BoxFit.cover,
              width: 60,
              height: 60,
              errorBuilder: (context, error, stackTrace) {
                print('❌ Error loading image file object: $error');
                return _buildDefaultOrderIcon();
              },
            );
          }
        } else if (order['imageFile'] is String) {
          // Handle case where imageFile might be a string path
          final imageFile = File(order['imageFile']);
          if (imageFile.existsSync()) {
            print('✅ Found image file from string path: ${order['imageFile']}');
            return Image.file(
              imageFile,
              fit: BoxFit.cover,
              width: 60,
              height: 60,
              errorBuilder: (context, error, stackTrace) {
                print('❌ Error loading image file from string: $error');
                return _buildDefaultOrderIcon();
              },
            );
          }
        }
      } catch (e) {
        print('❌ Error handling imageFile: $e');
      }
    }
    
    // Fallback to network image if imagePath exists
    if (order['imagePath'] != null && order['imagePath'].toString().isNotEmpty) {
      print('🔄 Trying network image: ${order['imagePath']}');
      return Image.network(
        order['imagePath'],
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading network image: $error');
          return _buildDefaultOrderIcon();
        },
      );
    }
    
    // Default icon if no image
    print('ℹ️ No image found, using default icon');
    return _buildDefaultOrderIcon();
  }

  Widget _buildDefaultOrderIcon() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.inventory_2_outlined,
        color: Colors.grey.shade400,
        size: 24,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like to do',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  title: 'Send a package',
                  desc: 'Request for a rider to pick up or deliver your package for you in real time',
                  svg: 'assets/images/2.svg',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateOrderPage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAction(
                  title: 'Order History',
                  desc: 'Our customer care service line is available from 8am -9pm week days and 9am - 5pm weekends.',
                  svg: 'assets/images/3.svg',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  title: 'Fund your wallet',
                  desc: 'To fund your wallet is very easy, make use of our fast technology & top-up your wallet today',
                  svg: 'assets/images/4.svg',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalletScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAction(
                  title: 'Support',
                  desc: 'Our customer care service line is available from 8am -9pm week days and 9am - 5pm weekends.',
                  svg: 'assets/images/5.svg',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SupportScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTabIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xffE28E3C) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(title,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            )),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required String desc,
    required String svg,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 191,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(svg, height: 32, width: 32),
            const SizedBox(height: 12),
            Text(title,
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600, fontSize: 12, color: const Color(0xff333333))),
            const SizedBox(height: 8),
            Text(desc,
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: const Color(0xff666666), height: 1.4)),
          ],
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orangeAccent;
      case 'in transit':
        return Colors.green;
      case 'delivered':
        return Colors.blue;
      case 'unpaid':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
} 