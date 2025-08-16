import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'avatar_service.dart';

class ProfileApi {
  static const baseUrl = 'https://3j97jn908h.execute-api.us-east-1.amazonaws.com/dev';

  // Get saved token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_token');
  }

  // Generate headers dynamically with token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Get Profile
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found. Please login again.');
    }
    
    final headers = await getHeaders();
    final url = Uri.parse('$baseUrl/profile');

    print('Calling GET $url with headers: $headers');

    final response = await http.get(url, headers: headers);

    print('Profile API status: ${response.statusCode}');
    print('Profile API body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      // Update avatar from backend response
      final backendAvatarUrl = data['avatarUrl'];
      final avatarService = AvatarService();
      
      if (backendAvatarUrl != null && backendAvatarUrl.isNotEmpty) {
        // Backend has a valid avatar URL
        await avatarService.updateAvatar(backendAvatarUrl);
        print('Updated avatar URL from backend: $backendAvatarUrl');
      } else {
        // Backend doesn't have an avatar, but we should still notify the service
        // to ensure it's properly initialized
        await avatarService.initializeAvatar();
        print('Backend returned empty/null avatar URL, keeping current avatar');
      }

      return data;
    } else if (response.statusCode == 401) {
      throw Exception('401: Unauthorized - Token may be expired or invalid');
    } else if (response.statusCode == 403) {
      throw Exception('403: Forbidden - Access denied');
    } else {
      throw Exception('Failed to load profile. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }


  // Update Profile
  static Future<bool> updateProfile({
  required String firstName,
  required String lastName,
  required String phone,
  required String street,
  required String city,
  required String state,
  required String country,
}) async {
  final headers = await getHeaders();
  final body = jsonEncode({
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'street': street,
    'city': city,
    'state': state,
    'country': country,
  });

  final response = await http.put(Uri.parse('$baseUrl/profile'), body: body, headers: headers);
  print('Update Profile Status: ${response.statusCode}');
  print('Update Profile Body: ${response.body}');

  return response.statusCode == 200;
}


  // Change Password
  static Future<bool> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  final token = await getToken();
  final headers = await getHeaders();
  final body = jsonEncode({
    'current_password': currentPassword,
    'new_password': newPassword,
    'access_token': token, // if backend needs it
  });

  final response = await http.put(
    Uri.parse('$baseUrl/profile/password'),
    body: body,
    headers: headers,
  );

  print('Change Password Status: ${response.statusCode}');
  print('Response Body: ${response.body}');

  return response.statusCode == 200;
}


  // Upload Avatar
static Future<String?> uploadAvatar() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) {
    print('No image selected.');
    return null;
  }

  final headers = await getHeaders();
  final bytes = await pickedFile.readAsBytes();
  final base64Image = base64Encode(bytes);

  final body = jsonEncode({'image': 'data:image/jpeg;base64,$base64Image'});

  print('Uploading avatar...');
  print('Headers: $headers');
  print('Body Length: ${body.length}');

  final response = await http.put(
    Uri.parse('$baseUrl/profile/avatar'),
    body: body,
    headers: headers,
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final avatarUrl = data['data']['avatarUrl'];

    // Update the AvatarService which will notify all listeners
    // The service will automatically save to the correct user-specific key
    final avatarService = AvatarService();
    await avatarService.updateAvatar(avatarUrl);

    print('Uploaded avatarUrl: $avatarUrl');
    return avatarUrl;
  } else {
    print('Upload failed with status ${response.statusCode}');
    throw Exception('Failed to upload avatar');
  }
}



}
