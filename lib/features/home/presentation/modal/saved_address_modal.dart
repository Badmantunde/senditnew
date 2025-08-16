import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/profile/data/address_service.dart';
import 'package:sendit/features/profile/domain/entities/address.dart';

class SavedAddressModal extends StatefulWidget {
  final bool isPickup;
  final Function(Address) onAddressSelected;

  const SavedAddressModal({
    super.key,
    required this.isPickup,
    required this.onAddressSelected,
  });

  @override
  State<SavedAddressModal> createState() => _SavedAddressModalState();
}

class _SavedAddressModalState extends State<SavedAddressModal> {
  List<Address> addresses = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final addressData = await AddressService.listAddresses();
      
      if (!mounted) return;
      
      setState(() {
        addresses = addressData.map((json) => Address.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  widget.isPickup ? 'Saved Sender Addresses' : 'Saved Receiver Addresses',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Content
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $error', 
                                style: GoogleFonts.dmSans(color: Colors.red)),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAddresses,
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : addresses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No saved addresses',
                                    style: GoogleFonts.dmSans(fontSize: 18, color: Colors.grey)),
                                SizedBox(height: 8),
                                Text('Add addresses in your profile to use them here',
                                    style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey)),
                                SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Navigate to saved addresses screen
                                    Navigator.pushNamed(context, '/saved-addresses');
                                  },
                                  child: Text('Manage Addresses'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final address = addresses[index];
                              return ListTile(
                                leading: Icon(Icons.location_on, color: Color(0xffE68A34)),
                                title: Text(
                                  address.street,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      address.shortAddress,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (address.isDefault)
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xffE68A34),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Default',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  widget.onAddressSelected(address);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
} 