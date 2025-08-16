import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:sendit/features/home/presentation/pages/realtime_tracking_map.dart';

class OrderTrackingPage extends StatefulWidget {
  final Map<String, dynamic> order;
  
  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  Map<String, String> get order => {
    'id': (widget.order['id'] ?? 'N/A').toString(),
    'pickup': _getPickupAddressText(),
    'dropoff': _getDropoffAddressText(),
    'date': (widget.order['date'] ?? 'N/A').toString(),
    'time': (widget.order['time'] ?? 'N/A').toString(),
  };

  final List<Map<String, String>> statusUpdates = List.generate(5, (index) => {
    'status': 'Order Accepted',
    'date': 'June 01, 2025',
    'time': '09:20 am'
  });

  bool showReceiver = false;
  bool showParcel = false;
  bool showDate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text('Tracking', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RealtimeTrackingMap()),
              );
            },
            icon: const Icon(Icons.location_pin, color: Colors.grey),
          )

        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xffD2DCDC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tracking ID', style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xff1D4135))),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: order['id']!));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tracking ID copied')));
                      },
                      child: const Icon(Icons.copy, size: 16, color: Color(0xff98A2B3)),
                    ),
                    const SizedBox(width: 8),
                    Text(order['id']!, style: GoogleFonts.dmSans(color: const Color(0xffE68A34), fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      CustomPaint(
                        size: const Size(2, 40),
                        painter: DottedLinePainter(),
                      ),
                      const Icon(Icons.circle, size: 16, color: Color(0xff5932EA))
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xff98A2B3))),
                        const SizedBox(height: 2),
                        Text(order['pickup']!, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              children: List.generate(
                                (constraints.maxWidth / 6).floor(),
                                (index) => Container(
                                  width: 3,
                                  height: 1,
                                  color: const Color(0xffD0D5DD),
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text('Drop off', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xff98A2B3))),
                        const SizedBox(height: 2),
                        Text(order['dropoff']!, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Order Status', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xff101828))),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    itemCount: statusUpdates.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final isLast = index == statusUpdates.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff06B217),
                                  ),
                                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 50,
                                    color: const Color(0xff06B217),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 0),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xffF9FAFB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(statusUpdates[index]['status']!, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xff101828))),
                                      const SizedBox(height: 4),
                                      Text(statusUpdates[index]['date']!, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xff9CA3AF))),
                                    ],
                                  ),
                                  Text(statusUpdates[index]['time']!, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xff9CA3AF))),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          buildExpandableTile('Receiver Details', showReceiver, () => setState(() => showReceiver = !showReceiver), [
            buildInfoRow('Name', (widget.order['receiverName'] ?? 'N/A').toString()),
            buildInfoRow('Phone', (widget.order['receiverPhone'] ?? 'N/A').toString()),
            buildInfoRow('Email', (widget.order['receiverEmail'] ?? 'N/A').toString()),
          ]),
          buildExpandableTile('Parcel Details', showParcel, () => setState(() => showParcel = !showParcel), [
            buildInfoRow('Sender Name', (widget.order['senderName'] ?? 'N/A').toString()),
            buildInfoRow('Item Name', (widget.order['itemName'] ?? 'N/A').toString()),
            buildInfoRow('Weight', '${widget.order['itemWeight'] ?? '1'}kg'),
            buildInfoRow('Quantity', (widget.order['itemQuantity'] ?? '1').toString()),
            buildInfoRow('Amount', (widget.order['amount'] ?? '₦0.00').toString()),
          ]),
          buildExpandableTile('Date Information', showDate, () => setState(() => showDate = !showDate), [
            buildInfoRow('Order Date', order['date']!),
            buildInfoRow('Order Time', order['time']!),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget buildExpandableTile(String title, bool expanded, VoidCallback onTap, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
              trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              onTap: onTap,
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(children: children),
              )
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xff9EA2AD))),
          Text(value, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xff344054))),
        ],
      ),
    );
  }

  String _getPickupAddressText() {
    final street = widget.order['pickupStreet']?.toString() ?? '';
    final city = widget.order['pickupCity']?.toString() ?? '';
    final state = widget.order['pickupState']?.toString() ?? '';
    
    if (street.isNotEmpty || city.isNotEmpty || state.isNotEmpty) {
      return '$street, $city, $state'.replaceAll(RegExp(r'^,\s*|,\s*$|,\s*,'), '').trim();
    }
    
    return widget.order['pickupAddress']?.toString() ?? '12, unity road, ikeja Lagos...';
  }

  String _getDropoffAddressText() {
    final street = widget.order['dropoffStreet']?.toString() ?? '';
    final city = widget.order['dropoffCity']?.toString() ?? '';
    final state = widget.order['dropoffState']?.toString() ?? '';
    
    if (street.isNotEmpty || city.isNotEmpty || state.isNotEmpty) {
      return '$street, $city, $state'.replaceAll(RegExp(r'^,\s*|,\s*$|,\s*,'), '').trim();
    }
    
    return widget.order['dropoffAddress']?.toString() ?? '15, Iyana Ipaja, Lagos.....';
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffD0D5DD)
      ..strokeWidth = 2;

    const dashHeight = 4;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}