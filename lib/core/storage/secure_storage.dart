import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;
  
  // Keys for stored data
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';
  
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();
  
  // Store auth token
  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  // Retrieve auth token
  Future<String> getToken() async {
    return await _storage.read(key: _tokenKey) ?? '';
  }
  
  // Remove auth token (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  // Store user data as JSON string
  Future<void> setUserData(String userData) async {
    await _storage.write(key: _userKey, value: userData);
  }
  
  // Retrieve user data as JSON string
  Future<String?> getUserData() async {
    return await _storage.read(key: _userKey);
  }
  
  // Remove user data
  Future<void> deleteUserData() async {
    await _storage.delete(key: _userKey);
  }
  
  // Store remember me flag
  Future<void> setRememberMe(bool rememberMe) async {
    await _storage.write(key: _rememberMeKey, value: rememberMe.toString());
  }
  
  // Retrieve remember me flag
  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }
  
  // Clear all secure storage (complete logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Check if user is authenticated (has token)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token.isNotEmpty;
  }
}