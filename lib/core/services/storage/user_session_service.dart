import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔹 SharedPreferences Provider (override in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in main.dart',
  );
});

/// 🔹 User Session Provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  //  Keys
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'user_email';
  static const String _keyFullName = 'user_full_name';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyProfileImage = 'user_profile_image';

  /// ✅Save session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
    String? profileImage,  
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyFullName, fullName);

      if (phoneNumber != null) {
      await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
    }

    if (profileImage != null) {
      await _prefs.setString(_keyProfileImage, profileImage);
    }
  }

  /// Auth state
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// 👤 User getters
  String? getUserId() => _prefs.getString(_keyUserId);
  String? getEmail() => _prefs.getString(_keyEmail);
  String? getFullName() => _prefs.getString(_keyFullName);
  String? getPhoneNumber() => _prefs.getString(_keyUserPhoneNumber);
  String? getProfileImage() => _prefs.getString(_keyProfileImage);

 // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyFullName);
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyProfileImage);  
  }
}
