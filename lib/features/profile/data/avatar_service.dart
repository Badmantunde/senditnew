import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarService extends ChangeNotifier {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  String? _avatarUrl;
  String? _currentUserEmail;

  String? get avatarUrl => _avatarUrl;
  String? get currentUserEmail => _currentUserEmail;

  // Initialize avatar from SharedPreferences for a specific user
  Future<void> initializeAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      print('AvatarService: initializeAvatar() called');
      print('AvatarService: user_email from SharedPreferences: $userEmail');
      
      if (userEmail != null && userEmail.isNotEmpty) {
        _currentUserEmail = userEmail;
        // Get avatar for specific user
        final userAvatarKey = 'avatarUrl_$userEmail';
        _avatarUrl = prefs.getString(userAvatarKey);
        print('AvatarService: Initialized for user $userEmail with avatar URL: $_avatarUrl');
        print('AvatarService: Used key: $userAvatarKey');
      } else {
        print('AvatarService: No user email found, cannot initialize avatar');
        print('AvatarService: This usually means the user has not logged in yet or the email was cleared');
        print('AvatarService: Will retry in 1 second...');
        
        // Retry after a short delay in case user email is being set
        await Future.delayed(Duration(seconds: 1));
        final retryUserEmail = prefs.getString('user_email');
        if (retryUserEmail != null && retryUserEmail.isNotEmpty) {
          print('AvatarService: User email found on retry: $retryUserEmail');
          await setCurrentUser(retryUserEmail);
          return;
        }
        
        _avatarUrl = null;
      }
    } catch (e) {
      print('AvatarService: Error loading avatar: $e');
      _avatarUrl = null;
    }
    notifyListeners();
  }

  // Check if user is properly initialized
  bool get isUserInitialized => _currentUserEmail != null && _currentUserEmail!.isNotEmpty;

  // Check if avatar URL is valid
  bool get hasValidAvatar => _avatarUrl != null && _avatarUrl!.isNotEmpty;

  // Wait for user to be initialized (useful for components that need to wait for login)
  Future<bool> waitForUserInitialization({Duration timeout = const Duration(seconds: 10)}) async {
    if (isUserInitialized) {
      return true;
    }
    
    print('AvatarService: Waiting for user initialization...');
    final startTime = DateTime.now();
    
    while (!isUserInitialized && DateTime.now().difference(startTime) < timeout) {
      await Future.delayed(Duration(milliseconds: 500));
      
      // Check if user email has been set
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      if (userEmail != null && userEmail.isNotEmpty) {
        await setCurrentUser(userEmail);
        print('AvatarService: User initialized during wait: $userEmail');
        return true;
      }
    }
    
    if (!isUserInitialized) {
      print('AvatarService: User initialization timeout after ${timeout.inSeconds} seconds');
    }
    
    return isUserInitialized;
  }

  // Refresh avatar from SharedPreferences (useful when app resumes)
  Future<void> refreshAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      if (userEmail != null && userEmail.isNotEmpty) {
        final userAvatarKey = 'avatarUrl_$userEmail';
        final storedAvatarUrl = prefs.getString(userAvatarKey);
        
        if (storedAvatarUrl != _avatarUrl) {
          _avatarUrl = storedAvatarUrl;
          _currentUserEmail = userEmail;
          print('AvatarService: Refreshed avatar URL for user $userEmail: $_avatarUrl');
          notifyListeners();
        }
      }
    } catch (e) {
      print('AvatarService: Error refreshing avatar: $e');
    }
  }

  // Update avatar URL for current user
  Future<void> updateAvatar(String? newAvatarUrl) async {
    print('AvatarService: Updating avatar to: $newAvatarUrl');
    
    if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
      _avatarUrl = newAvatarUrl;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final userEmail = prefs.getString('user_email');
        
        if (userEmail != null && userEmail.isNotEmpty) {
          final userAvatarKey = 'avatarUrl_$userEmail';
          await prefs.setString(userAvatarKey, newAvatarUrl);
          _currentUserEmail = userEmail;
          print('AvatarService: Successfully saved avatar URL for user $userEmail to SharedPreferences');
        } else {
          print('AvatarService: No user email found, cannot save avatar');
        }
      } catch (e) {
        print('AvatarService: Error saving avatar: $e');
      }
    } else {
      print('AvatarService: Received empty/null avatar URL, not updating');
    }

    notifyListeners();
  }

  // Set current user and load their avatar
  Future<void> setCurrentUser(String userEmail) async {
    print('AvatarService: setCurrentUser() called with email: $userEmail');
    print('AvatarService: Current user email before switch: $_currentUserEmail');
    
    if (_currentUserEmail != userEmail) {
      _currentUserEmail = userEmail;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        // Store the current user email
        await prefs.setString('user_email', userEmail);
        print('AvatarService: Stored user_email in SharedPreferences: $userEmail');
        
        // Load avatar for this specific user
        final userAvatarKey = 'avatarUrl_$userEmail';
        _avatarUrl = prefs.getString(userAvatarKey);
        
        print('AvatarService: Switched to user $userEmail, avatar URL: $_avatarUrl');
        print('AvatarService: Used key: $userAvatarKey');
        notifyListeners();
      } catch (e) {
        print('AvatarService: Error setting current user: $e');
      }
    } else {
      print('AvatarService: User is already set to $userEmail, no need to switch');
    }
  }

  // Clear avatar for current user (for logout)
  Future<void> clearAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      if (userEmail != null && userEmail.isNotEmpty) {
        final userAvatarKey = 'avatarUrl_$userEmail';
        await prefs.remove(userAvatarKey);
        print('AvatarService: Cleared avatar for user $userEmail');
      }
      
      _avatarUrl = null;
      _currentUserEmail = null;
    } catch (e) {
      print('Error clearing avatar: $e');
    }
    notifyListeners();
  }

  // Clear all user data (for complete logout)
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      if (userEmail != null && userEmail.isNotEmpty) {
        final userAvatarKey = 'avatarUrl_$userEmail';
        await prefs.remove(userAvatarKey);
        print('AvatarService: Removed avatar for user $userEmail');
      }
      
      // Clear user email
      await prefs.remove('user_email');
      
      _avatarUrl = null;
      _currentUserEmail = null;
    } catch (e) {
      print('Error resetting avatar service: $e');
    }
    notifyListeners();
  }

  // Get avatar URL for a specific user (without switching current user)
  Future<String?> getUserAvatar(String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userAvatarKey = 'avatarUrl_$userEmail';
      return prefs.getString(userAvatarKey);
    } catch (e) {
      print('AvatarService: Error getting avatar for user $userEmail: $e');
      return null;
    }
  }

  // Debug method to show current state
  void debugState() {
    print('=== AvatarService Debug State ===');
    print('Current user email: $_currentUserEmail');
    print('Avatar URL: $_avatarUrl');
    print('Has valid avatar: $hasValidAvatar');
    print('Is user initialized: $isUserInitialized');
    
    // Also check SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      final userEmail = prefs.getString('user_email');
      print('SharedPreferences user_email: $userEmail');
      
      if (userEmail != null && userEmail.isNotEmpty) {
        final userAvatarKey = 'avatarUrl_$userEmail';
        final storedAvatarUrl = prefs.getString(userAvatarKey);
        print('User-specific avatar key: $userAvatarKey');
        print('Stored avatar URL: $storedAvatarUrl');
      }
    });
  }
} 