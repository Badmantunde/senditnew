import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/profile/data/profile_api.dart'; // Update path accordingly

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool hideOld = true, hideNew = true, hideConfirm = true;

  Future<void> handlePasswordChange() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showError("All fields are required.");
      return;
    }

    if (newPass != confirmPass) {
      _showError("New passwords do not match.");
      return;
    }

    setState(() => isLoading = true);
    final success = await ProfileApi.changePassword(
  currentPassword: _oldPasswordController.text.trim(),
  newPassword: _newPasswordController.text.trim(),
);
    setState(() => isLoading = false);

    if (success) {
      _showSuccess("Password reset successfully");
      Navigator.pop(context);
    } else {
      _showError("Old password is incorrect.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
  }

  Widget buildPasswordField(String label, TextEditingController controller, bool hide, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: hide,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '********', hintStyle: GoogleFonts.dmSans(color: Color(0xff94A3B8), fontSize: 14),
            suffixIcon: IconButton(
              icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined), color: Color(0xff475569),
              onPressed: toggle,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
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
        title: Text("Reset Password", style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xff333333))),
        leading: BackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildPasswordField("Old Password", _oldPasswordController, hideOld, () {
              setState(() => hideOld = !hideOld);
            }),
            buildPasswordField("New Password", _newPasswordController, hideNew, () {
              setState(() => hideNew = !hideNew);
            }),
            buildPasswordField("Confirm New Password", _confirmPasswordController, hideConfirm, () {
              setState(() => hideConfirm = !hideConfirm);
            }),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : handlePasswordChange,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xffE68A34),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
