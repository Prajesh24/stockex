import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockex/core/services/storage/user_session_service.dart';

//provider
final tokenServiceProvider = Provider<TokenService>((ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return TokenService(preferences: sharedPreferences);
});

class TokenService {
  final SharedPreferences _preferences;
  static const String _tokenKey = 'auth_token';

  TokenService({required SharedPreferences preferences})
    : _preferences = preferences;

  //save token
  Future<void> saveToken(String token) async {
    await _preferences.setString(_tokenKey, token);
  }

  //get token
  String? getToken() {
    return _preferences.getString(_tokenKey);
  }

  //remove token
  Future<void> removeToken() async {
    await _preferences.remove(_tokenKey);
  }
}
