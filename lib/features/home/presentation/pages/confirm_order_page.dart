import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/home/presentation/modal/shipping_flow_modal.dart';
import 'package:sendit/features/home/presentation/pages/create_order_page.dart';

class ConfirmOrderPage extends StatelessWidget {
  final Map<String, String> sender;
  final Map<String, String> receiver;
  final String itemName;
  final String quantity;
  final String description;
  final File? previewImage;

  const ConfirmOrderPage({
    super.key,
    required this.sender,
    required this.receiver,
    required this.itemName,
    required this.quantity,
    required this.description,
    this.previewImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('New Order', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Color(0xffCCD3D3),
                child: Text(
                  'Confirm Details',
                  style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff1D4135)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  SizedBox(height: 16),
              
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: 1.0,
                      backgroundColor: Color(0xffd6ddeb),
                      valueColor: AlwaysStoppedAnimation(Color(0xff198038)),
                    ),
                  ),
                  SizedBox(height: 24),
              
                  // Item Preview Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (previewImage != null)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(previewImage!, width: 100, height: 100, fit: BoxFit.cover),
                            ),
                          ),
                        SizedBox(height: 16),
                        Text("Item Name", style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                        Text(itemName, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text("Quantity", style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                        Text(quantity, style: GoogleFonts.dmSans(fontSize: 14)),
                        SizedBox(height: 8),
                        Text("Description", style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                        Text(description, style: GoogleFonts.dmSans(fontSize: 14)),
                        SizedBox(height: 16),
                        Divider(height: 2,),
                        SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => CreateOrderPage()));
                              },
                              icon: Icon(Icons.add_circle, size: 16),
                              label: Text("Add another item", style: GoogleFonts.instrumentSans(fontSize: 12),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffF8F8FA),
                                foregroundColor: Color(0xffE68A34),
                                elevation: 0,
                                side: BorderSide(color: Color(0xffD6DDEB)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '(Maximum of 3 items can be added to your shipment)',
                              style: GoogleFonts.dmSans(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              
                  SizedBox(height: 24),
                  
                  // Combined Address Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
              
                            )
                          ]
                        ),
                        child: Column(
                          children: [
                            buildAddressSummary("Pickup", sender, onEdit: () {}),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: SvgPicture.asset('assets/images/swap.svg', width: 44,)
                                  ),
                                  Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
                                ],
                              ),
                            ),
                            buildAddressSummary("Drop off", receiver, onEdit: () {}),
                          ],
                        ),
                      ),
              
              
                  SizedBox(height: 32),
              
                  // Get Quote Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                          final result = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (context) => ShipmentFlowModal(
                              orderData: {
                                'itemName': itemName,
                                'description': description,
                                'category': 'electronics', // Default category
                                'weight': '1', // Default weight
                                'quantity': int.tryParse(quantity) ?? 1,
                                'insured': false, // Default insurance
                                'pickupAddress': sender,
                                'dropoffAddress': receiver,
                                'imageFile': previewImage,
                              },
                            ),
                          );
                          
                          // If order was successfully created, return to home page with refresh signal
                          if (result == true) {
                            // Navigate back to home page with success result
                            Navigator.pop(context, true); // Return to CreateOrderPage with success
                          }
                        },
              
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffE28E3C),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Get quote',
                        style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 50,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddressSummary(String title, Map<String, String> address, {VoidCallback? onEdit}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                SvgPicture.asset(
                      title == "Pickup" 
                        ? 'assets/images/pick.svg' 
                        : 'assets/images/locator.svg',
                      height: 20,
                      width: 20,
                    ),

                SizedBox(width: 8),
                Text(title, style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xffE68A34),
                ),
                child: Text('Edit Details'),
              )
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              SvgPicture.asset('assets/images/person-orange.svg'),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address['name'] ?? '', style: GoogleFonts.dmSans(fontSize: 14)),
                    Text(address['phone'] ?? '', style: GoogleFonts.dmSans(fontSize: 14)),
                    if (address['email'] != null)
                      Text(address['email']!, style: GoogleFonts.dmSans(fontSize: 14)),
                    Text(address['address'] ?? '', style: GoogleFonts.dmSans(fontSize: 14)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
