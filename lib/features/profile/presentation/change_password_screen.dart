import 'package:flutter/material.dart';
import '../data/profile_api.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPw = TextEditingController();
  final newPw = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: currentPw, decoration: InputDecoration(labelText: 'Current Password'), obscureText: true),
            TextField(controller: newPw, decoration: InputDecoration(labelText: 'New Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ProfileApi.changePassword(
                    currentPassword: currentPw.text,
                    newPassword: newPw.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password changed')));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text('Change Password'),
            )
          ],
        ),
      ),
    );
  }
}
