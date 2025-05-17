// lib/features/auth/services/auth_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_kasir_cerdas_app/core/api/api_client.dart';
import 'package:flutter_kasir_cerdas_app/core/api/api_endpoints.dart';
import 'package:flutter_kasir_cerdas_app/core/storage/secure_storage.dart';
import 'package:flutter_kasir_cerdas_app/models/api_response.dart';
import 'package:flutter_kasir_cerdas_app/models/user.dart';

class AuthService {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthService({ApiClient? apiClient, SecureStorage? secureStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorage();

  // Login method that calls the API and returns the response
  Future<ApiResponse> login(
      String email, String password, bool rememberMe) async {
    try {
      // Call login API endpoint with form data
      final response = await _apiClient.post(
        ApiEndpoints.login,
        body: {
          'email': email,
          'password': password,
        },
        isFormData: true,
      );

      // If successful, save the token and user data to secure storage
      if (response.status) {
        final token = response.data?['token'] as String?;
        if (token != null) {
          await _secureStorage.setToken(token);
        }

        final userData = response.data?['user'];
        if (userData != null) {
          final userJson = json.encode(userData);
          await _secureStorage.setUserData(userJson);
        }

        // Save remember me preference
        await _secureStorage.setRememberMe(rememberMe);
      }

      return response;
    } catch (e) {
      // Handle errors and rethrow to be caught by the provider
      rethrow;
    }
  }

  // Get the current authenticated user from secure storage
  Future<User?> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.getUserData();
      if (userJson != null && userJson.isNotEmpty) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<ApiResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String shopName,
    required String shopAddress,
    String? shopPhone,
    String? shopTaxId,
  }) async {
    try {
      // Prepare the request body
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'shop_name': shopName,
        'shop_address': shopAddress,
      };

      // Add optional fields only if they are not null
      if (shopPhone != null) {
        body['shop_phone'] = shopPhone;
      }

      if (shopTaxId != null) {
        body['shop_tax_id'] = shopTaxId;
      }

      // Call register API endpoint with form data
      final response = await _apiClient.post(
        ApiEndpoints.register,
        body: body,
        isFormData: true,
      );

      // If successful, save the token and user data to secure storage
      if (response.status) {
        final token = response.data?['token'] as String?;
        if (token != null) {
          await _secureStorage.setToken(token);
        }

        final userData = response.data?['user'];
        if (userData != null) {
          final userJson = json.encode(userData);
          await _secureStorage.setUserData(userJson);
        }
      }

      return response;
    } catch (e) {
      // Handle errors and rethrow to be caught by the provider
      rethrow;
    }
  }

  Future<ApiResponse> logout() async {
    try {
      // Call logout API endpoint
      final response = await _apiClient.post(ApiEndpoints.logout);

      // Clear storage regardless of API response
      await _secureStorage.clearAll();

      return response;
    } catch (e) {
      // Still clear storage even if API call fails
      await _secureStorage.clearAll();

      // Log error but don't re-throw as logout should succeed locally even if API fails
      debugPrint('Error during logout API call: $e');

      // Return a success response to indicate local logout was successful
      return ApiResponse(
        status: true,
        message: 'Logged out successfully',
      );
    }
  }

  // Di class AuthService, tambahkan/modifikasi metode ini
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.getToken();

      if (token.isEmpty) {
        return false;
      }

      // Opsional: Validasi token dengan API
      // Bila Anda memiliki endpoint untuk validasi token
      // Contoh: panggil /api/auth/validate-token atau sejenisnya

      return true;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }

// Tambahkan metode baru untuk membersihkan storage
  Future<void> clearStorage() async {
    await _secureStorage.clearAll();
  }

  // Get remember me preference
  Future<bool> getRememberMe() async {
    return await _secureStorage.getRememberMe();
  }
}
