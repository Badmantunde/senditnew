import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class RealtimeTrackingMap extends StatelessWidget {
  const RealtimeTrackingMap({super.key});

  @override
  Widget build(BuildContext context) {
    final pickupLocation = LatLng(6.5244, 3.3792);
    final dropOffLocation = LatLng(6.6175, 3.3631);
    final riderLocation = LatLng(6.5800, 3.3700);

    final polylinePoints = [
      pickupLocation,
      LatLng(6.5400, 3.3750),
      LatLng(6.5600, 3.3720),
      LatLng(6.5800, 3.3700),
      LatLng(6.6000, 3.3670),
      dropOffLocation,
    ];

    final completedPath = polylinePoints.sublist(0, 4);
    final remainingPath = polylinePoints.sublist(3);

    return Scaffold(
  backgroundColor: const Color(0xffF9FAFB),
  appBar: AppBar(
    backgroundColor: Colors.white,
    elevation: 1,
    centerTitle: true,
    title: Text(
      "Track Delivery",
      style: GoogleFonts.dmSans(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black87),
      onPressed: () => Navigator.of(context).pop(),
    ),
  ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: riderLocation,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sendit',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: completedPath,
                    color: const Color(0xff5932EA),
                    strokeWidth: 4,
                  ),
                  Polyline(
                    points: remainingPath,
                    color: Colors.grey.shade700,
                    strokeWidth: 4,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Pickup Marker
                  Marker(
                    point: pickupLocation,
                    width: 180,
                    height: 100,
                    child: Column(
                      children: [
                        const Icon(Icons.circle, color: Color(0xff0EBC93), size: 16),
                        Container(
                          width: 180,
                          height: 56,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/location_marker2.svg',
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ikeja",
                                      style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      "12, Unity road, Ikeja, Lagos",
                                      style: GoogleFonts.dmSans(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Drop-off Marker
                  Marker(
                    point: dropOffLocation,
                    width: 180,
                    height: 100,
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xff5932EA), size: 24),
                        Container(
                          width: 180,
                          height: 56,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/location_marker.svg',
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Iyana Ipaja",
                                      style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      "15, iyana ipaja, Lagos, Nigeria",
                                      style: GoogleFonts.dmSans(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rider Marker
                      Marker(
                        point: riderLocation,
                        width: 60,
                        height: 60,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircleAvatar(
                                backgroundImage: AssetImage('assets/images/rider.png'),
                                radius: 16, // reduced from 20
                              ),
                              SizedBox(height: 2),
                              Icon(Icons.delivery_dining, color: Colors.green, size: 18),
                            ],
                          ),
                        ),
                      ),

                ],
              ),
            ],
          ),
        //info card
          Positioned(
  top: 16,
  left: 16,
  right: 16,
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vertical dotted line with status icons
        Column(
          children: [
            // Green check circle
            const Icon(Icons.check_circle, size: 20, color: Colors.green),
            // Dotted line
            Container(
              width: 1,
              height: 40,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.grey,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (_) => Container(
                      width: 1,
                      height: 4,
                      color: Colors.grey.shade400,
                    )),
                  );
                },
              ),
            ),
            // Purple dot
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xff5932EA),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),

        const SizedBox(width: 12),

        // Pickup & Dropoff info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup section
              Text('Pickup', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text('12, unity road, ikeja Lagos...',
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
              
              // Horizontal dotted divider
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 1,
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: List.generate((constraints.maxWidth / 6).floor(), (index) {
                        return Container(
                          width: 3,
                          height: 1,
                          color: index % 2 == 0 ? Colors.grey.shade300 : Colors.transparent,
                        );
                      }),
                    );
                  },
                ),
              ),

              // Dropoff section
              Text('Dropoff', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text('15, iyana ipaja, Lagos.....',
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    ),
  ),
),


          // Draggable Scrollable Sheet
          DraggableScrollableSheet(
  initialChildSize: 0.35,
  minChildSize: 0.25,
  maxChildSize: 0.85,
  builder: (context, scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff0C3A2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Top rider info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('assets/images/rider.png'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.account_circle, color: Colors.green, size: 18),
                                const Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Icon(Icons.check_circle, size: 10, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Text("John Doe",
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              )),
                          ],
                        ),
                        Text("+2348192671092",
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Colors.white,
                          )),
                      ],
                    ),
                    const Spacer(),
                    _iconCircle(Icons.call),
                    const SizedBox(width: 12),
                    _iconCircle(Icons.chat),
                  ],
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: 0.7,
                    minHeight: 6,
                    backgroundColor: Colors.black26,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5932EA)),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Estimated Time – 10 : 30 am",
                        style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13)),
                    Row(
                      children: [
                        Text('Arriving in', style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white)),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.directions_bike, color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text("15 minutes",
                                  style: GoogleFonts.dmSans(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // White bottom section fills remaining space
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Text("Order Status", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...List.generate(5, (index) => buildStatusTile(index)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
),

        ],
      ),
    );
  }

  Widget buildStatusTile(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              if (index != 4)
                Container(
                  width: 1.5,
                  height: 60,
                  color: Color(0xff06B217),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order Accepted", style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("June 01, 2025", style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                      Text("09:20 am", style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget _iconCircle(IconData icon) {
  return Container(
    width: 36,
    height: 36,
    decoration: const BoxDecoration(
      color: Colors.white30,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: Colors.white),
  );
}
