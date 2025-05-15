import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/user.dart';
import '../../../models/api_response.dart';

class AuthService {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  
  AuthService({ApiClient? apiClient, SecureStorage? secureStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorage();
  
  // Login
  Future<User> login(String email, String password, bool rememberMe) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      isFormData: true,
      body: {
        'email': email,
        'password': password,
      },
    );
    
    if (response.status) {
      final token = response.data['token'];
      final userData = response.data['user'];
      
      // Save token and user data
      await _secureStorage.setToken(token);
      await _secureStorage.setUserData(jsonEncode(userData));
      await _secureStorage.setRememberMe(rememberMe);
      
      return User.fromJson(userData);
    } else {
      throw ApiException(message: response.message);
    }
  }
  
  // Register
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String shopName,
    required String shopAddress,
    required String shopPhone,
    String? shopTaxId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      isFormData: true,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'shop_name': shopName,
        'shop_address': shopAddress,
        'shop_phone': shopPhone,
        'shop_tax_id': shopTaxId,
      },
    );
    
    if (response.status) {
      final token = response.data['token'];
      final userData = response.data['user'];
      
      // Save token and user data
      await _secureStorage.setToken(token);
      await _secureStorage.setUserData(jsonEncode(userData));
      
      return User.fromJson(userData);
    } else {
      throw ApiException(message: response.message);
    }
  }
  
  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _secureStorage.getUserData();
      
      if (userData != null && userData.isNotEmpty) {
        return User.fromJsonString(userData);
      }
      
      // If we have a token but no cached user data, fetch from API
      final isAuthenticated = await _secureStorage.isAuthenticated();
      if (isAuthenticated) {
        return await fetchCurrentUser();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Fetch current user data from API
  Future<User> fetchCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.currentUser);
    
    if (response.status) {
      final userData = response.data;
      
      // Update stored user data
      await _secureStorage.setUserData(jsonEncode(userData));
      
      return User.fromJson(userData);
    } else {
      throw ApiException(message: response.message);
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      // Call logout API endpoint
      await _apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      // Ignore errors on logout API call
    } finally {
      // Clear local storage regardless of API success
      await _secureStorage.clearAll();
    }
  }
  
  // Check authentication status
  Future<bool> isAuthenticated() async {
    return await _secureStorage.isAuthenticated();
  }
}