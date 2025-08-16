import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:sendit/features/home/presentation/pages/order_tracking_page.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  int _currentImage = 0;
  
  List<dynamic> get imagePaths {
    // Debug: Print the order data to see what image fields are available
    print('🔍 OrderDetailPage image fields:');
    print('  - imageFile: ${widget.order['imageFile']}');
    print('  - imageFilePath: ${widget.order['imageFilePath']}');
    print('  - imagePath: ${widget.order['imagePath']}');
    print('  - All available fields: ${widget.order.keys.toList()}');
    
    // First try to get the uploaded image file from imageFilePath
    if (widget.order['imageFilePath'] != null && widget.order['imageFilePath'].toString().isNotEmpty) {
      try {
        final imageFile = File(widget.order['imageFilePath']);
        if (imageFile.existsSync()) {
          print('✅ Found image file at path: ${widget.order['imageFilePath']}');
          return [imageFile];
        } else {
          print('❌ Image file does not exist at path: ${widget.order['imageFilePath']}');
          print('❌ File path: ${imageFile.absolute.path}');
        }
      } catch (e) {
        print('❌ Error accessing image file: $e');
      }
    }
    
    // Fallback to imageFile if it exists (for backward compatibility)
    if (widget.order['imageFile'] != null) {
      try {
        if (widget.order['imageFile'] is File) {
          final imageFile = widget.order['imageFile'] as File;
          if (imageFile.existsSync()) {
            print('✅ Found image file object');
            return [imageFile];
          }
        } else if (widget.order['imageFile'] is String) {
          // Handle case where imageFile might be a string path
          final imageFile = File(widget.order['imageFile']);
          if (imageFile.existsSync()) {
            print('✅ Found image file from string path: ${widget.order['imageFile']}');
            return [imageFile];
          }
        }
      } catch (e) {
        print('❌ Error handling imageFile: $e');
      }
    }
    
    // Fallback to network image if imagePath exists
    if (widget.order['imagePath'] != null && widget.order['imagePath'].toString().isNotEmpty) {
      print('🔄 Using network image: ${widget.order['imagePath']}');
      return [widget.order['imagePath']];
    }
    
    // Default image if no uploaded image
    print('ℹ️ No uploaded image found, using default image');
    return [
      'assets/images/iphone.png',
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Print order data
    print('🔍 OrderDetailPage received data: ${widget.order}');
    print('🔍 OrderDetailPage field analysis:');
    print('  - itemName: ${widget.order['itemName']}');
    print('  - description: ${widget.order['description']}');
    print('  - quantity: ${widget.order['quantity']}');
    print('  - senderDetails: ${widget.order['senderDetails']}');
    print('  - receiverDetails: ${widget.order['receiverDetails']}');
    print('  - imageFilePath: ${widget.order['imageFilePath']}');
    print('  - imageFile: ${widget.order['imageFile']}');
    print('  - amount: ${widget.order['amount']}');
    print('  - trackingId: ${widget.order['trackingId']}');
    print('  - status: ${widget.order['status']}');
    print('  - payer: ${widget.order['payer']}');
    print('  - paymentMethod: ${widget.order['paymentMethod']}');
    print('  - All available fields: ${widget.order.keys.toList()}');
    
    // Validate that we have the essential data
    if (widget.order['itemName'] == null || widget.order['itemName'].toString().isEmpty) {
      print('⚠️ Warning: Missing item name in order data');
    }
    if (widget.order['senderDetails'] == null && widget.order['senderName'] == null) {
      print('⚠️ Warning: Missing sender details in order data');
    }
    if (widget.order['receiverDetails'] == null && widget.order['receiverName'] == null) {
      print('⚠️ Warning: Missing receiver details in order data');
    }
    if (widget.order['imageFilePath'] == null && widget.order['imageFile'] == null) {
      print('⚠️ Warning: Missing image data in order data');
    }
    
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Order Details',
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // Header with Tracking ID
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: const Color(0xffCCD3D3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tracking ID',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff1D4135),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.order['trackingId'] ?? widget.order['id'] ?? ''),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tracking ID copied')),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.copy, size: 16, color: Color(0xff98A2B3)),
                      const SizedBox(width: 8),
                      Text(
                        widget.order['trackingId'] ?? widget.order['id'] ?? 'SN9056UL',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xffE68A34),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Carousel with Insured Tag
          const SizedBox(height: 12),
          Stack(
            children: [
              CarouselSlider.builder(
                options: CarouselOptions(
                  height: 200,
                  enableInfiniteScroll: false,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImage = index;
                    });
                  },
                ),
                itemCount: imagePaths.length,
                itemBuilder: (context, index, realIndex) {
                  final imageItem = imagePaths[index];
                  return Center(
                    child: imageItem is File
                        ? Image.file(
                            imageItem,
                            fit: BoxFit.cover,
                            width: 300,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ Error loading file image: $error');
                              return Container(
                                width: 300,
                                height: 200,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade400,
                                  size: 48,
                                ),
                              );
                            },
                          )
                        : imageItem is String && imageItem.startsWith('http')
                            ? Image.network(
                                imageItem,
                                fit: BoxFit.cover,
                                width: 300,
                                height: 200,
                                errorBuilder: (context, error, stackTrace) {
                                  print('❌ Error loading network image: $error');
                                  return Container(
                                    width: 300,
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey.shade400,
                                      size: 48,
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                imageItem,
                                fit: BoxFit.cover,
                                width: 300,
                                height: 200,
                                errorBuilder: (context, error, stackTrace) {
                                  print('❌ Error loading asset image: $error');
                                  return Container(
                                    width: 300,
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey.shade400,
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                  );
                },
              ),
              // Show "Insured" tag only if user selected insurance
              if (widget.order['itemInsured'] == 'true')
                Positioned(
                  top: 20,
                  right: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xff1D4135),
                    ),
                    child: Text(
                      'Insured',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
            ],
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imagePaths.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImage == entry.key
                      ? const Color(0xff344054)
                      : const Color(0xffD0D5DD),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Address Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildAddressSection(),
          ),
          const SizedBox(height: 16),

          // Parcel Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildParcelSection(),
          ),
          const SizedBox(height: 16),

          // Sender Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildSectionCard(
              title: 'Sender Details',
              items: [
                {'label': 'Name', 'value': _getSenderName()},
                {'label': 'Phone Number', 'value': _getSenderPhone()},
                {'label': 'Email', 'value': _getSenderEmail()},
              ],
              icons: [Icons.person, Icons.phone, Icons.email],
            ),
          ),
          const SizedBox(height: 16),

          // Receiver Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildSectionCard(
              title: 'Receiver Details',
              items: [
                {'label': 'Name', 'value': _getReceiverName()},
                {'label': 'Phone Number', 'value': _getReceiverPhone()},
                {'label': 'Email', 'value': _getReceiverEmail()},
              ],
              icons: [Icons.person, Icons.phone, Icons.email],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Information (always show)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildPaymentInfoSection(),
          ),
          const SizedBox(height: 16),

          // Date Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildSectionCard(
              title: 'Order Information',
              items: [
                {'label': 'Order Status', 'value': (widget.order['status'] ?? 'Created').toString()},
                {'label': 'Order Date', 'value': (widget.order['date'] ?? 'May 27, 2025').toString()},
                {'label': 'Order Time', 'value': (widget.order['time'] ?? '10:30 am').toString()},
              ],
              icons: [Icons.info, Icons.calendar_today, Icons.access_time],
            ),
          ),

          const SizedBox(height: 24),

          // Track Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingPage(order: widget.order)
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF7931A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Track',
                  style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildParcelImage() {
    // First try to get the uploaded image file from imageFilePath
    if (widget.order['imageFilePath'] != null && widget.order['imageFilePath'].toString().isNotEmpty) {
      try {
        final imageFile = File(widget.order['imageFilePath']);
        if (imageFile.existsSync()) {
          return Image.file(
            imageFile,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/iphone.png', height: 100);
            },
          );
        }
      } catch (e) {
        print('❌ Error accessing image file in parcel section: $e');
      }
    }
    
    // Fallback to imageFile if it exists (for backward compatibility)
    if (widget.order['imageFile'] != null) {
      try {
        if (widget.order['imageFile'] is File) {
          final imageFile = widget.order['imageFile'] as File;
          if (imageFile.existsSync()) {
            return Image.file(
              imageFile,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/iphone.png', height: 100);
              },
            );
          }
        } else if (widget.order['imageFile'] is String) {
          // Handle case where imageFile might be a string path
          final imageFile = File(widget.order['imageFile']);
          if (imageFile.existsSync()) {
            return Image.file(
              imageFile,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/iphone.png', height: 100);
              },
            );
          }
        }
      } catch (e) {
        print('❌ Error handling imageFile in parcel section: $e');
      }
    }
    
    // Fallback to network image if imagePath exists
    if (widget.order['imagePath'] != null && widget.order['imagePath'].toString().isNotEmpty) {
      return Image.network(
        widget.order['imagePath'],
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/iphone.png', height: 100);
        },
      );
    }
    
    // Default image if no uploaded image
    return Image.asset('assets/images/iphone.png', height: 100);
  }

  String _getSenderName() {
    // Try to get name from senderDetails (new structure)
    if (widget.order['senderDetails'] != null && widget.order['senderDetails'] is Map<String, dynamic>) {
      final senderDetails = widget.order['senderDetails'] as Map<String, dynamic>;
      final name = senderDetails['name'];
      if (name != null && name.toString().isNotEmpty) {
        print('✅ Found sender name from senderDetails: $name');
        return name.toString();
      }
    }
    
    // Fallback to old structure
    final fallbackName = widget.order['senderName'] ?? 'N/A';
    print('🔄 Using fallback sender name: $fallbackName');
    return fallbackName;
  }

  String _getSenderPhone() {
    // Try to get phone from senderDetails (new structure)
    if (widget.order['senderDetails'] != null && widget.order['senderDetails'] is Map<String, dynamic>) {
      final senderDetails = widget.order['senderDetails'] as Map<String, dynamic>;
      final phone = senderDetails['phone'];
      if (phone != null && phone.toString().isNotEmpty) {
        print('✅ Found sender phone from senderDetails: $phone');
        return phone.toString();
      }
    }
    
    // Fallback to old structure
    final fallbackPhone = widget.order['senderPhone'] ?? 'N/A';
    print('🔄 Using fallback sender phone: $fallbackPhone');
    return fallbackPhone;
  }

  String _getSenderEmail() {
    // Try to get email from senderDetails (new structure)
    if (widget.order['senderDetails'] != null && widget.order['senderDetails'] is Map<String, dynamic>) {
      final senderDetails = widget.order['senderDetails'] as Map<String, dynamic>;
      final email = senderDetails['email'];
      if (email != null && email.toString().isNotEmpty) {
        print('✅ Found sender email from senderDetails: $email');
        return email.toString();
      }
    }
    
    // Fallback to old structure
    final fallbackEmail = widget.order['senderEmail'] ?? 'N/A';
    print('🔄 Using fallback sender email: $fallbackEmail');
    return fallbackEmail;
  }

  String _getReceiverName() {
    // Try to get name from receiverDetails (new structure)
    if (widget.order['receiverDetails'] != null && widget.order['receiverDetails'] is Map<String, dynamic>) {
      final receiverDetails = widget.order['receiverDetails'] as Map<String, dynamic>;
      final name = receiverDetails['name'];
      if (name != null && name.toString().isNotEmpty) {
        print('✅ Found receiver name from receiverDetails: $name');
        return name.toString();
      }
    }
    
    // Fallback to old structure
    final fallbackName = widget.order['receiverName'] ?? 'N/A';
    print('🔄 Using fallback receiver name: $fallbackName');
    return fallbackName;
  }

  String _getReceiverPhone() {
    // Try to get phone from receiverDetails (new structure)
    if (widget.order['receiverDetails'] != null && widget.order['receiverDetails'] is Map<String, dynamic>) {
      final receiverDetails = widget.order['receiverDetails'] as Map<String, dynamic>;
      final phone = receiverDetails['phone'];
      if (phone != null && phone.toString().isNotEmpty) {
        print('✅ Found receiver phone from receiverDetails: $phone');
        return phone.toString();
      }
    }
    
    // Fallback to old structure
    final fallbackPhone = widget.order['receiverPhone'] ?? 'N/A';
    print('🔄 Using fallback receiver phone: $fallbackPhone');
    return fallbackPhone;
  }

  String _getReceiverEmail() {
    // Try to get email from receiverDetails (new structure)
    if (widget.order['receiverDetails'] != null && widget.order['receiverDetails'] is Map<String, dynamic>) {
      final receiverDetails = widget.order['receiverDetails'] as Map<String, dynamic>;
      final email = receiverDetails['email'];
      if (email != null && email.toString().isNotEmpty) {
        print('✅ Found receiver email from receiverDetails: $email');
        return email.toString();
      }
    }
    
    // Fallback to old structure
    final fallbackEmail = widget.order['receiverEmail'] ?? 'N/A';
    print('🔄 Using fallback receiver email: $fallbackEmail');
    return fallbackEmail;
  }

  Widget buildParcelSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Parcel Details',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff101828),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_outlined, color: Colors.grey,)
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xffE4E7EC)),
          const SizedBox(height: 16),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xffF2F4F7),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                              child: _buildParcelImage(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          buildInfoRow('Sender Name', _getSenderName()),
          buildInfoRow('Item Name', widget.order['itemName'] ?? 'N/A'),
          buildInfoRow('Description', widget.order['description'] ?? 'N/A'),
          buildInfoRow('Weight', '${(widget.order['itemWeight'] ?? '1').toString()}kg'),
          buildInfoRow('Quantity', (widget.order['quantity'] ?? '1').toString()),
          buildInfoRow(
            'Amount',
            (widget.order['amount'] ?? '₦4,120.00').toString(),
            valueColor: const Color(0xffF7931A),
          ),
        ],
      ),
    );
  }

  Widget buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff101828),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff00C853),
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                  Container(
                    width: 2,
                    height: 60,
                    color: const Color(0xffD0D5DD),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff7B61FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pickup',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff98A2B3))),
                    const SizedBox(height: 2),
                    Text(
                      _getPickupAddressText(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff101828)),
                    ),
                    const SizedBox(height: 20),
                    Text('Drop off',
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff98A2B3))),
                    const SizedBox(height: 2),
                    Text(
                      _getDropoffAddressText(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff101828)),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildSectionCard({
    required String title,
    required List<Map<String, dynamic>> items,
    required List<IconData> icons,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff101828),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_outlined, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xffE4E7EC)),
          const SizedBox(height: 16),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final icon = icons[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xff667085)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['label']!,
                      style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xff344054)),
                    ),
                  ),
                  Text(
                    item['value']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff98A2B3),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildPaymentInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE68A34).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xffE68A34).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.payment,
                  size: 18,
                  color: Color(0xffE68A34),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Information',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff101828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xffE4E7EC)),
          const SizedBox(height: 16),
          
          // Payment status with prominent styling
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffFFF4EC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffE68A34).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Color(0xffE68A34),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Payment Status',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff667085),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      widget.order['paymentStatus'] ?? 'Pending Payment',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffE68A34),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment details
          buildInfoRow('Paid By', _getPaidByText()),
          buildInfoRow('Payment Method', _getPaymentMethodText()),
          buildInfoRow('Amount', (widget.order['amount'] ?? '₦5,500').toString(), valueColor: const Color(0xffE68A34)),
          
          const SizedBox(height: 12),
          
          // Information note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getPaymentNoteText(),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xff9EA2AD))),
          Text(value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xff344054),
              )),
        ],
      ),
    );
  }

  String _getPickupAddressText() {
    // Try to get address from senderDetails (new structure)
    if (widget.order['senderDetails'] != null && widget.order['senderDetails'] is Map<String, dynamic>) {
      final senderDetails = widget.order['senderDetails'] as Map<String, dynamic>;
      final address = senderDetails['address'];
      if (address != null && address.toString().isNotEmpty) {
        print('✅ Found pickup address from senderDetails: $address');
        return address.toString();
      }
    }
    
    // Fallback to old structure fields
    final street = widget.order['pickupStreet'] ?? '';
    final city = widget.order['pickupCity'] ?? '';
    final state = widget.order['pickupState'] ?? '';
    
    if (street.isNotEmpty || city.isNotEmpty || state.isNotEmpty) {
      final address = '$street, $city, $state'.replaceAll(RegExp(r'^,\s*|,\s*$|,\s*,'), '').trim();
      print('✅ Found pickup address from old structure: $address');
      return address;
    }
    
    final fallbackAddress = widget.order['pickupAddress'] ?? widget.order['senderAddress'] ?? '12, unity road, ikeja Lagos...';
    print('🔄 Using fallback pickup address: $fallbackAddress');
    return fallbackAddress;
  }

  String _getDropoffAddressText() {
    // Try to get address from receiverDetails (new structure)
    if (widget.order['receiverDetails'] != null && widget.order['receiverDetails'] is Map<String, dynamic>) {
      final receiverDetails = widget.order['receiverDetails'] as Map<String, dynamic>;
      final address = receiverDetails['address'];
      if (address != null && address.toString().isNotEmpty) {
        print('✅ Found dropoff address from receiverDetails: $address');
        return address.toString();
      }
    }
    
    // Fallback to old structure fields
    final street = widget.order['dropoffStreet'] ?? '';
    final city = widget.order['dropoffCity'] ?? '';
    final state = widget.order['dropoffState'] ?? '';
    
    if (street.isNotEmpty || city.isNotEmpty || state.isNotEmpty) {
      final address = '$street, $city, $state'.replaceAll(RegExp(r'^,\s*|,\s*$|,\s*,'), '').trim();
      print('✅ Found dropoff address from old structure: $address');
      return address;
    }
    
    final fallbackAddress = widget.order['dropoffAddress'] ?? widget.order['receiverAddress'] ?? '15, Iyana Ipaja, Lagos.....';
    print('🔄 Using fallback dropoff address: $fallbackAddress');
    return fallbackAddress;
  }

  String _getPaidByText() {
    final payer = widget.order['payer'] ?? 'owner';
    if (payer == 'receiver') {
      return 'Receiver';
    } else if (payer == 'owner') {
      return 'Sender';
    } else {
      return payer.toString();
    }
  }

  String _getPaymentMethodText() {
    final paymentMethod = widget.order['paymentMethod'] ?? 'card';
    if (paymentMethod == 'card') {
      return 'Card Payment';
    } else if (paymentMethod == 'cash') {
      return 'Cash on Delivery';
    } else {
      return paymentMethod.toString();
    }
  }

  String _getPaymentNoteText() {
    final payer = widget.order['payer'] ?? 'owner';
    if (payer == 'receiver') {
      return 'The receiver will pay for this delivery upon receiving the package.';
    } else if (payer == 'owner') {
      return 'Payment has been completed by the sender.';
    } else {
      return 'Payment information for this order.';
    }
  }
}
