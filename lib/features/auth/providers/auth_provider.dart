import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  
  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.authenticating;
  
  // Constructor - checks if the user is already authenticated
  AuthProvider() {
    _checkAuthStatus();
  }
  
  // Check the current authentication status
  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        _user = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Login
  Future<bool> login(String email, String password, bool rememberMe) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _user = await _authService.login(email, password, rememberMe);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String shopName,
    required String shopAddress,
    required String shopPhone,
    String? shopTaxId,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        shopName: shopName,
        shopAddress: shopAddress,
        shopPhone: shopPhone,
        shopTaxId: shopTaxId,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    
    try {
      await _authService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Refresh user data
  Future<void> refreshUser() async {
    try {
      _user = await _authService.fetchCurrentUser();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}