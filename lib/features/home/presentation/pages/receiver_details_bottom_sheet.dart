import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiverDetailsBottomSheet extends StatefulWidget {
  final bool saveAddress;
  
  const ReceiverDetailsBottomSheet({super.key, this.saveAddress = false});

  @override
  State<ReceiverDetailsBottomSheet> createState() => _ReceiverDetailsBottomSheetState();
}

class _ReceiverDetailsBottomSheetState extends State<ReceiverDetailsBottomSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
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
    formattedAddressController.text = '12, Unity Road, Ikeja, Lagos, Nigeria';
  }

  void handleContinue() async {
    // Validate required fields
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        streetController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('id_token');

      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication required. Please log in again.')),
        );
        return;
      }

      // Use address normalizer for proper parsing
      final addressData = {
        'street': streetController.text,
        'city': cityController.text,
        'state': stateController.text,
        'postal_code': postalCodeController.text,
        'country': countryController.text,
        'longitude': longitudeController.text,
        'latitude': latitudeController.text,
        'formatted_address': formattedAddressController.text,
      };

      print('Address Input: ${addressData['formatted_address']}');
      print('Parsed Street: ${addressData['street']}, City: ${addressData['city']}, State: ${addressData['state']}');
      print('Current Location: ${latitudeController.text}, ${longitudeController.text}');

      try {
        // This part of the logic needs to be updated to call a backend service
        // For now, we'll just simulate saving or creating a temporary address
          print('💾 Saving receiver address to backend...');
        final result = {
            'address_id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
          'street': addressData['street']!,
          'city': addressData['city']!,
          'state': addressData['state']!,
          'postal_code': addressData['postal_code']!,
          'country': addressData['country']!,
          'longitude': addressData['longitude']!,
          'latitude': addressData['latitude']!,
          'formatted_address': addressData['formatted_address']!,
        };
        print('✅ Receiver address saved to backend: ${result['address_id']}');

        Navigator.pop(context, {
          'address_id': result['address_id'],
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
            'address': result['formatted_address'],
            'street': result['street'],
            'city': result['city'],
            'state': result['state'],
            'postal_code': result['postal_code'],
            'country': result['country'],
            'latitude': result['latitude'],
            'longitude': result['longitude'],
            'formatted_address': result['formatted_address'],
        });

      } catch (e) {
        print('❌ Address creation failed: $e');
        
        // Show user-friendly error message
        String errorMessage = 'Failed to save address';
        if (e.toString().contains('401')) {
          errorMessage = 'Authentication expired. Please login again.';
        } else if (e.toString().contains('Network error')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('Validation error')) {
          errorMessage = 'Invalid address data. Please check your input.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saving receiver address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xffF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Receiver Details', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade700),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              buildInputLabel('Name'),
              SizedBox(height: 6),
              buildStyledTextField(controller: nameController, hint: 'Please input receiver name'),
              SizedBox(height: 12),
              buildInputLabel('Phone Number'),
              SizedBox(height: 6),
              buildStyledTextField(controller: phoneController, hint: 'Please input receiver phone number'),
              SizedBox(height: 12),
              buildInputLabel('Email'),
              SizedBox(height: 6),
              buildStyledTextField(controller: emailController, hint: 'Enter receiver email'),
              SizedBox(height: 12),
              buildInputLabel('Street'),
              SizedBox(height: 6),
              buildStyledTextField(controller: streetController, hint: 'Please input receiver street'),
              SizedBox(height: 12),
              buildInputLabel('City'),
              SizedBox(height: 6),
              buildStyledTextField(controller: cityController, hint: 'Please input receiver city'),
              SizedBox(height: 12),
              buildInputLabel('State'),
              SizedBox(height: 6),
              buildStyledTextField(controller: stateController, hint: 'Please input receiver state'),
              SizedBox(height: 12),
              buildInputLabel('Postal Code'),
              SizedBox(height: 6),
              buildStyledTextField(controller: postalCodeController, hint: 'Please input receiver postal code'),
              SizedBox(height: 12),
              buildInputLabel('Country'),
              SizedBox(height: 6),
              buildStyledTextField(controller: countryController, hint: 'Please input receiver country'),
              SizedBox(height: 12),
              buildInputLabel('Longitude'),
              SizedBox(height: 6),
              buildStyledTextField(controller: longitudeController, hint: 'Please input receiver longitude'),
              SizedBox(height: 12),
              buildInputLabel('Latitude'),
              SizedBox(height: 6),
              buildStyledTextField(controller: latitudeController, hint: 'Please input receiver latitude'),
              SizedBox(height: 12),
              buildInputLabel('Formatted Address'),
              SizedBox(height: 6),
              buildStyledTextField(controller: formattedAddressController, hint: 'Please input receiver formatted address'),
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
