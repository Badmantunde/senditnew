import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/profile/data/address_service.dart';
import 'package:sendit/features/profile/data/dummy_addresses.dart';
import 'package:sendit/features/profile/domain/entities/address.dart';

class SavedAddressScreen extends StatefulWidget {
  const SavedAddressScreen({super.key});

  @override
  State<SavedAddressScreen> createState() => _SavedAddressScreenState();
}

class _SavedAddressScreenState extends State<SavedAddressScreen> {
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
      print('=== LOADING ADDRESSES ===');
      final addressData = await AddressService.listAddresses();
      print('Raw address data received: ${addressData.length} addresses');
      
      if (!mounted) return;
      
      setState(() {
        addresses = addressData.map((json) => Address.fromJson(json)).toList();
        isLoading = false;
      });
      
      print('=== ADDRESSES LOADED ===');
      print('Processed addresses count: ${addresses.length}');
      for (final address in addresses) {
        print('- ${address.street}, ${address.city}');
      }
    } catch (e) {
      print('=== ERROR LOADING ADDRESSES ===');
      print('Error: $e');
      
      if (!mounted) return;
      
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      final success = await AddressService.deleteAddress(addressId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address deleted successfully'), backgroundColor: Colors.green),
        );
        _loadAddresses();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete address: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _populateWithDummyAddresses() async {
    try {
      // Show loading state
      if (!mounted) return;
      
      setState(() {
        isLoading = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adding dummy addresses...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      print('=== STARTING DUMMY ADDRESS POPULATION ===');
      
      // Add dummy addresses
      await DummyAddresses.addAllDummyAddresses();
      
      print('=== DUMMY ADDRESSES ADDED, NOW RELOADING ===');
      
      // Force reload the addresses list
      await _loadAddresses();
      
      print('=== RELOAD COMPLETE ===');
      print('Current addresses count: ${addresses.length}');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added ${DummyAddresses.addresses.length} dummy addresses'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      print('=== ERROR IN POPULATION ===');
      print('Error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add dummy addresses: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _testApiConnection() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Testing API connection...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      print('=== TESTING API CONNECTION ===');
      final addressData = await AddressService.listAddresses();
      print('API test successful! Found ${addressData.length} addresses');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API connection successful! Found ${addressData.length} addresses'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('=== API TEST FAILED ===');
      print('Error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API test failed: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showEditAddressDialog(Address address) {
    final streetController = TextEditingController(text: address.street);
    final cityController = TextEditingController(text: address.city);
    final stateController = TextEditingController(text: address.state);
    final postalCodeController = TextEditingController(text: address.postalCode);
    final countryController = TextEditingController(text: address.country);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Address', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: streetController,
                decoration: InputDecoration(labelText: 'Street'),
              ),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: stateController,
                decoration: InputDecoration(labelText: 'State'),
              ),
              TextField(
                controller: postalCodeController,
                decoration: InputDecoration(labelText: 'Postal Code'),
              ),
              TextField(
                controller: countryController,
                decoration: InputDecoration(labelText: 'Country'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await AddressService.updateAddress(
                  addressId: address.addressId,
                  street: streetController.text,
                  city: cityController.text,
                  state: stateController.text,
                  postalCode: postalCodeController.text,
                  country: countryController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Address updated successfully'), backgroundColor: Colors.green),
                );
                _loadAddresses();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update address: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Saved Address',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_dummy') {
                _populateWithDummyAddresses();
              } else if (value == 'test_api') {
                _testApiConnection();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'add_dummy',
                child: Row(
                  children: [
                    Icon(Icons.add_location, size: 16),
                    SizedBox(width: 8),
                    Text('Add Dummy Addresses'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'test_api',
                child: Row(
                  children: [
                    Icon(Icons.bug_report, size: 16),
                    SizedBox(width: 8),
                    Text('Test API Connection'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error', style: GoogleFonts.dmSans(color: Colors.red)),
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
                          Text(
                            'No saved addresses',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first address to get started',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _populateWithDummyAddresses,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffE68A34),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Populate with Dummy Addresses',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: addresses.length,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey[300],
                        thickness: 0.5,
                      ),
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(
                            address.street,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            '${address.city} ${address.country}',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditAddressDialog(address);
                              } else if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Address'),
                                    content: Text('Are you sure you want to delete this address?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteAddress(address.addressId);
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 16, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: addresses.isNotEmpty
          ? FloatingActionButton(
              onPressed: _populateWithDummyAddresses,
              backgroundColor: Color(0xffE68A34),
              child: Icon(Icons.add_location, color: Colors.white),
              tooltip: 'Add Dummy Addresses',
            )
          : null,
    );
  }
}
