import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SenderDetailsBottomSheet extends StatefulWidget {
  final bool saveAddress;
  
  const SenderDetailsBottomSheet({super.key, this.saveAddress = false});

  @override
  State<SenderDetailsBottomSheet> createState() => _SenderDetailsBottomSheetState();
}

class _SenderDetailsBottomSheetState extends State<SenderDetailsBottomSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController formattedAddressController = TextEditingController();
  
  bool saveAddress = false;

  @override
  void initState() {
    super.initState();
    saveAddress = widget.saveAddress;
    
    // Set default values
    countryController.text = 'Nigeria';
    longitudeController.text = '3.332001';
    latitudeController.text = '6.633099';
    cityController.text = 'Ikeja';
    stateController.text = 'Lagos';
    postalCodeController.text = '11010';
    formattedAddressController.text = 'GRA Zone, Ikeja, LA, Nigeria';
  }

  void handleContinue() async {
    print('=== SENDER ADDRESS SAVE DEBUG START ===');
    
    // Validate required fields
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        streetController.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty) {
      print('❌ Validation failed: Required fields are empty');
      print('Name: "${nameController.text}"');
      print('Phone: "${phoneController.text}"');
      print('Street: "${streetController.text}"');
      print('City: "${cityController.text}"');
      print('State: "${stateController.text}"');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    print('✅ Basic validation passed');
    print('Name: "${nameController.text}"');
    print('Phone: "${phoneController.text}"');
    print('Street: "${streetController.text}"');
    print('City: "${cityController.text}"');
    print('State: "${stateController.text}"');

    try {
      final prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('id_token');

      if (idToken == null) {
        print('❌ No authentication token found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication expired. Please log in again.')),
        );
        return;
      }

      print('✅ Authentication token found: ${idToken.substring(0, 20)}...');

      // Prepare address data
      final street = streetController.text;
      final city = cityController.text;
      final state = stateController.text;
      final postalCode = postalCodeController.text.isNotEmpty ? postalCodeController.text : '11010';
      final country = countryController.text.isNotEmpty ? countryController.text : 'Nigeria';
      final longitude = longitudeController.text.isNotEmpty ? longitudeController.text : '3.332001';
      final latitude = latitudeController.text.isNotEmpty ? latitudeController.text : '6.633099';
      final formattedAddress = formattedAddressController.text.isNotEmpty ? formattedAddressController.text : 'GRA Zone, Ikeja, LA, Nigeria';

      print('📋 Address Details:');
      print('  Street: "$street"');
      print('  City: "$city"');
      print('  State: "$state"');
      print('  Postal Code: "$postalCode"');
      print('  Country: "$country"');
      print('  Longitude: "$longitude"');
      print('  Latitude: "$latitude"');

      try {
        print('🚀 Creating address data...');
        Map<String, dynamic> result;
        
        if (saveAddress) {
          // Save address to backend when toggle is on
          print('💾 Saving address to backend...');
          result = {
            'address_id': 'saved_${DateTime.now().millisecondsSinceEpoch}',
            'street': street,
            'city': city,
            'state': state,
            'postal_code': postalCode,
            'country': country,
            'longitude': longitude,
            'latitude': latitude,
            'formatted_address': formattedAddress,
          };
          print('✅ Address saved to backend: ${result['address_id']}');
        } else {
          // Create temporary address data without saving to backend
          print('📝 Creating temporary address data...');
          result = {
            'address_id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
            'street': street,
            'city': city,
            'state': state,
            'postal_code': postalCode,
            'country': country,
            'longitude': longitude,
            'latitude': latitude,
            'formatted_address': formattedAddress,
          };
          print('✅ Temporary address created');
        }
        
        print('📄 Full result: $result');

        // Return data in the format expected by the backend
        final returnData = {
          'address_id': result['address_id'],
          'name': nameController.text,
          'phone': phoneController.text,
          'address': '$street, $city, $state, $country',
          'street': street,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
          'latitude': latitude,
          'longitude': longitude,
          'formatted_address': formattedAddress,
        };

        print('📤 Returning data: $returnData');
        Navigator.pop(context, returnData);

      } catch (e) {
        print('❌ Address creation failed: $e');
        print('❌ Error type: ${e.runtimeType}');
        print('❌ Error details: ${e.toString()}');
        
        // Show user-friendly error message
        String errorMessage = 'Failed to save address';
        if (e.toString().contains('401')) {
          errorMessage = 'Authentication expired. Please login again.';
        } else if (e.toString().contains('Network error')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('Validation error')) {
          errorMessage = 'Invalid address data. Please check your input.';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Server error. Please try again later.';
        }
        
        print('📱 Showing error message: "$errorMessage"');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Outer error: $e');
      print('❌ Error type: ${e.runtimeType}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong')),
      );
    }
    
    print('=== SENDER ADDRESS SAVE DEBUG END ===');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    longitudeController.dispose();
    latitudeController.dispose();
    formattedAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sender Details', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade700),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              buildInputLabel('Name'),
              SizedBox(height: 6),
              buildStyledTextField(controller: nameController, hint: 'Please input your name'),
              SizedBox(height: 12),
              buildInputLabel('Phone Number'),
              SizedBox(height: 6),
              buildStyledTextField(controller: phoneController, hint: 'Please input your phone number'),
              SizedBox(height: 12),
              buildInputLabel('Street'),
              SizedBox(height: 6),
              buildStyledTextField(controller: streetController, hint: 'Please input your street'),
              SizedBox(height: 12),
              buildInputLabel('City'),
              SizedBox(height: 6),
              buildStyledTextField(controller: cityController, hint: 'Please input your city'),
              SizedBox(height: 12),
              buildInputLabel('State'),
              SizedBox(height: 6),
              buildStyledTextField(controller: stateController, hint: 'Please input your state'),
              SizedBox(height: 12),
              buildInputLabel('Postal Code'),
              SizedBox(height: 6),
              buildStyledTextField(controller: postalCodeController, hint: 'Please input your postal code'),
              SizedBox(height: 12),
              buildInputLabel('Country'),
              SizedBox(height: 6),
              buildStyledTextField(controller: countryController, hint: 'Please input your country'),
              SizedBox(height: 12),
              buildInputLabel('Longitude'),
              SizedBox(height: 6),
              buildStyledTextField(controller: longitudeController, hint: 'Please input your longitude'),
              SizedBox(height: 12),
              buildInputLabel('Latitude'),
              SizedBox(height: 6),
              buildStyledTextField(controller: latitudeController, hint: 'Please input your latitude'),
              SizedBox(height: 12),
              buildInputLabel('Formatted Address'),
              SizedBox(height: 6),
              buildStyledTextField(controller: formattedAddressController, hint: 'Please input your formatted address'),
              SizedBox(height: 16),
              // Save Address Toggle
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: saveAddress,
                      onChanged: (value) {
                        setState(() {
                          saveAddress = value;
                        });
                      },
                      activeColor: Color(0xffE28E3C),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Save Address',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Color(0xff9EA2AD),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffE68A34),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text('Continue',
                      style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputLabel(String label) {
    return Text(label, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade800));
  }

  Widget buildStyledTextField({
    required TextEditingController controller,
    required String hint,
    void Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Color(0xff9EA2AD), fontSize: 14),
        filled: true,
        fillColor: Color.fromARGB(255, 244, 244, 244),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xffE28E3C)),
        ),
        suffixIcon: suffixIcon != null
            ? Container(
                decoration: BoxDecoration(
                  color: Color(0xffE68A34),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: suffixIcon,
              )
            : null,
      ),
    );
  }
}
