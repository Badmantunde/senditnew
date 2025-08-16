import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendit/features/profile/presentation/edit_profile_screen.dart';
import 'package:sendit/features/profile/presentation/referral_screen.dart';
import 'package:sendit/features/profile/presentation/saved_address_screen.dart';
import 'package:sendit/features/profile/presentation/support_screen.dart';
import 'package:sendit/features/profile/presentation/verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/profile_api.dart';
import '../data/avatar_service.dart';
import 'security_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  Future<Map<String, dynamic>>? profileFuture;
  bool pushNotificationsEnabled = false;
  late AvatarService _avatarService;


  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _avatarService = AvatarService();
  _initializeAvatarForCurrentUser();
  _loadProfileWithToken();
}

Future<void> _initializeAvatarForCurrentUser() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    
    if (userEmail != null && userEmail.isNotEmpty) {
      await _avatarService.setCurrentUser(userEmail);
    } else {
      print('ProfileScreen: No user email found, waiting for user initialization...');
      // Wait for user to be initialized (e.g., during login process)
      final initialized = await _avatarService.waitForUserInitialization();
      if (!initialized) {
        print('ProfileScreen: User initialization failed, falling back to initializeAvatar');
        await _avatarService.initializeAvatar();
      }
    }
  } catch (e) {
    print('Error initializing avatar for current user: $e');
    await _avatarService.initializeAvatar();
  }
}

@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  if (state == AppLifecycleState.resumed) {
    // Refresh profile data when app is resumed, but preserve avatar
    _loadProfileWithToken();
    // Re-initialize avatar for current user to ensure it's still displayed
    _initializeAvatarForCurrentUser();
  }
}

Future<void> _loadProfileWithToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('id_token');
    
    if (token == null || token.isEmpty) {
      // If no token, redirect to login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    
    setState(() {
      profileFuture = ProfileApi.getProfile().then((profile) {
        // After profile is loaded, refresh avatar service for current user
        _initializeAvatarForCurrentUser();
        return profile;
      });
    });
  } catch (e) {
    print('Error loading profile: $e');
    // Set a future that will throw the error so FutureBuilder can handle it
    setState(() {
      profileFuture = Future.error(e);
    });
  }
}

  Future<void> _debugAvatar() async {
    try {
      // Use the AvatarService debug method
      _avatarService.debugState();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Avatar Debug: Check console for details'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Avatar debug error: $e');
    }
  }

  Future<void> _logout() async {
  try {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Logout user
      // await SessionService.logout(); // This line was removed as per the edit hint
      
      // Navigate to login
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (route) => false,
        );
      }
    }
  } catch (e) {
    print('Error during logout: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error during logout: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}





  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xffF8F8FA),
    appBar: AppBar(
      title: Text('Profile', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      foregroundColor: Colors.black,
                actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  profileFuture = ProfileApi.getProfile();
                });
                _avatarService.initializeAvatar();
              },
            ),
          ],
    ),
    body: profileFuture == null
        ? Center(child: CircularProgressIndicator())
        : FutureBuilder<Map<String, dynamic>>(
            future: profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          String errorMessage = 'An error occurred while loading your profile.';
          
          if (snapshot.error.toString().contains('401') || snapshot.error.toString().contains('403')) {
            errorMessage = 'Your session has expired. Please login again.';
          } else if (snapshot.error.toString().contains('No authentication token')) {
            errorMessage = 'Please login to access your profile.';
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: GoogleFonts.dmSans(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Go to Login'),
                ),
              ],
            ),
          );
        }

        final profile = snapshot.data!;
        final fullName =
            '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}';

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar and Info
              Center(
                child: Column(
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
                    SizedBox(height: 12),
                    Text(fullName,
                        style: GoogleFonts.instrumentSans(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text(profile['email'] ?? '',
                        style: GoogleFonts.dmSans(color: Colors.grey.shade600)),
                    SizedBox(height: 12),

                    // Edit profile button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(profile: profile),
                          ),
                        );

                        if (updated == true) {
                          setState(() {
                            profileFuture = ProfileApi.getProfile();
                          });
                          await _avatarService.initializeAvatar();
                        }
                      },
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(26, 29, 65, 53),
                        foregroundColor: Color(0xff1d4135),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              _buildSectionCard('ACCOUNT', [
                _buildListTile(
                  SvgPicture.asset('assets/images/acct-icon.svg',
                      width: 24, height: 24),
                  'Account Information',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditProfileScreen(profile: profile)),
                  ),
                ),
                _buildListTile(
                  SvgPicture.asset('assets/images/security.svg',
                      width: 24, height: 24),
                  'Security',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SecurityScreen()),
                  ),
                ),
                _buildListTile(
                  SvgPicture.asset('assets/images/addy.svg',
                      width: 24, height: 24),
                  'My Address',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SavedAddressScreen()),
                  ),
                ),
                _buildListTile(
                  SvgPicture.asset('assets/images/veri.svg',
                      width: 24, height: 24),
                  'Verification Status',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VerificationScreen()),
                  ),
                ),
                _buildListTile(
                  SvgPicture.asset('assets/images/support.svg',
                      width: 24, height: 24),
                  'Support',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SupportScreen()),
                  ),
                ),
                _buildListTile(
                  SvgPicture.asset('assets/images/shaare.svg',
                      width: 24, height: 24),
                  'Refer and share app',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReferralScreen()),
                  ),
                ),
              ]),
              SizedBox(height: 24),
              _buildSectionCard('OTHERS', [
                SwitchListTile(
                  value: pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() => pushNotificationsEnabled = value);
                  },
                  activeColor: Color(0xffE68A34),
                  secondary: SvgPicture.asset('assets/images/noti.svg',
                      width: 24, height: 24),
                  title: Text('Push notification',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                  subtitle: Text('Update your account information',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: Color(0xff9ea2ad))),
                ),
                _buildListTile(
                  SvgPicture.asset('assets/images/dark.svg',
                      width: 24, height: 24),
                  'Dark mode',
                  onTap: () {
                    // Future implementation
                  },
                ),
                _buildListTile(
                  SvgPicture.asset('assets/images/rate.svg',
                      width: 24, height: 24),
                  'Rate us',
                  onTap: () {
                    // Future implementation
                  },
                ),
                _buildListTile(
                  SvgPicture.asset('assets/images/logout.svg',
                      width: 24, height: 24),
                  'Logout',
                  onTap: _logout,
                ),
                _buildListTile(
                  Icon(Icons.bug_report, size: 24, color: Colors.blue),
                  'Debug Avatar',
                  onTap: _debugAvatar,
                ),
              ]),
            ],
          ),
        );
      },
    ),
  );
}


  Widget _buildSectionCard(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.normal, color: Color(0xff7c7c7c))),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(10, 29, 65, 53),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(Widget leadingIcon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: leadingIcon,
      title: Text(title,
          style: GoogleFonts.instrumentSans(fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xff454A53))),
      subtitle: Text('Update your account information',
          style: GoogleFonts.dmSans(fontSize: 12, color: Color(0xff9ea2ad))),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: Color.fromARGB(156, 37, 49, 93)),
      onTap: onTap,
    );
  }
}
