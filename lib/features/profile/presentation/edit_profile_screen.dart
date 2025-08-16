import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/profile/data/profile_api.dart';
import 'package:sendit/features/profile/data/avatar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;

  late AvatarService _avatarService;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.profile['first_name'] ?? '');
    lastNameController = TextEditingController(text: widget.profile['last_name'] ?? '');
    phoneController = TextEditingController(text: widget.profile['phone'] ?? '');

    _avatarService = AvatarService();
    _initializeAvatarForCurrentUser();
  }

  Future<void> _initializeAvatarForCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      if (userEmail != null && userEmail.isNotEmpty) {
        await _avatarService.setCurrentUser(userEmail);
      } else {
        print('EditProfileScreen: No user email found, waiting for user initialization...');
        // Wait for user to be initialized (e.g., during login process)
        final initialized = await _avatarService.waitForUserInitialization();
        if (!initialized) {
          print('EditProfileScreen: User initialization failed, falling back to initializeAvatar');
          await _avatarService.initializeAvatar();
        }
      }
    } catch (e) {
      print('Error initializing avatar for current user: $e');
      await _avatarService.initializeAvatar();
    }
  }

  Future<void> handleAvatarUpload() async {
    final uploadedUrl = await ProfileApi.uploadAvatar();

    if (uploadedUrl != null && mounted) {
      // The AvatarService will automatically update and notify listeners
      // No need to manually set state here
    }
  }

  Future<void> handleSave() async {
    setState(() => isSaving = true);

    final success = await ProfileApi.updateProfile(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phone: phoneController.text.trim(),
      street: '',
      city: '', // removed
      state: '', // removed
      country: '', // removed
    );

    setState(() => isSaving = false);

    if (success) {
    // ✅ Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstNameController.text.trim());
    await prefs.setString('lastName', lastNameController.text.trim());
    
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update profile'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget buildField(String label, TextEditingController controller, {TextInputType? inputType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter $label',
            hintStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      appBar: AppBar(
        title: Text("Account information", style: GoogleFonts.instrumentSans(fontSize: 16, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ListenableBuilder(
                        listenable: _avatarService,
                        builder: (context, child) {
                          return CircleAvatar(
                            radius: 40,
                            backgroundImage: _avatarService.avatarUrl != null && _avatarService.avatarUrl!.isNotEmpty
                                ? NetworkImage(_avatarService.avatarUrl!)
                                : AssetImage('assets/images/avi.jpg') as ImageProvider,
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: handleAvatarUpload,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("${firstNameController.text} ${lastNameController.text}",
                      style: GoogleFonts.instrumentSans(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(widget.profile['email'] ?? '',
                      style: GoogleFonts.dmSans(
                          color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: buildField("First Name", firstNameController)),
                SizedBox(width: 12),
                Expanded(child: buildField("Last Name", lastNameController)),
              ],
            ),
            buildField("Phone Number", phoneController, inputType: TextInputType.phone),

            SizedBox(height: 32,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : handleSave,
                child: isSaving
                    ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xffE68A34),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
