import 'package:flutter/material.dart';
import '../data/profile_api.dart';

class AccountInfoScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const AccountInfoScreen({super.key, required this.profile});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController phone;
  late TextEditingController street;
  late TextEditingController city;
  late TextEditingController stateCtrl;
  late TextEditingController country;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    firstName = TextEditingController(text: p['first_name'] ?? '');
    lastName = TextEditingController(text: p['last_name'] ?? '');
    phone = TextEditingController(text: p['phone'] ?? '');
    street = TextEditingController(text: p['street'] ?? '');
    city = TextEditingController(text: p['city'] ?? '');
    stateCtrl = TextEditingController(text: p['state'] ?? '');
    country = TextEditingController(text: p['country'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Info')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: firstName, decoration: InputDecoration(labelText: 'First Name')),
            TextField(controller: lastName, decoration: InputDecoration(labelText: 'Last Name')),
            TextField(controller: phone, decoration: InputDecoration(labelText: 'Phone')),
            TextField(controller: street, decoration: InputDecoration(labelText: 'Street')),
            TextField(controller: city, decoration: InputDecoration(labelText: 'City')),
            TextField(controller: stateCtrl, decoration: InputDecoration(labelText: 'State')),
            TextField(controller: country, decoration: InputDecoration(labelText: 'Country')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ProfileApi.updateProfile(
                    firstName: firstName.text,
                    lastName: lastName.text,
                    phone: phone.text,
                    street: street.text,
                    city: city.text,
                    state: stateCtrl.text,
                    country: country.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated')));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text('Save Changes'),
            )
          ],
        ),
      ),
    );
  }
}
