// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String _errorMessage = '';
  bool _rememberMe = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Check authentication status on initialization
    _checkAuthStatus();
  }

  // Initialize by checking if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      _rememberMe = await _authService.getRememberMe();

      if (isAuth) {
        _user = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Login method
  Future<bool> login(String email, String password, bool rememberMe) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authService.login(email, password, rememberMe);

      if (response.status) {
        // Load the user data after successful login
        _user = await _authService.getCurrentUser();
        _rememberMe = rememberMe;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String shopName,
    required String shopAddress,
    String? shopPhone,
    String? shopTaxId,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        shopName: shopName,
        shopAddress: shopAddress,
        shopPhone: shopPhone,
        shopTaxId: shopTaxId,
      );

      if (response.status) {
        // Load the user data after successful registration
        _user = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Registration failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      debugPrint('AuthProvider: Starting logout process');
      _status = AuthStatus.unauthenticated; // Set status segera

      // Panggil API logout (tapi jangan tunggu hasilnya untuk melanjutkan)
      _authService.logout().then((_) {
        debugPrint('AuthProvider: API logout completed');
      }).catchError((e) {
        debugPrint('AuthProvider: API logout error: $e');
      });

      // Langsung hapus data lokal tanpa menunggu API
      debugPrint('AuthProvider: Clearing local storage');
      await _authService.clearStorage();

      _user = null;
      debugPrint('AuthProvider: Logout completed successfully');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AuthProvider: Error during logout: $e');
      // Pastikan status tetap diubah meskipun ada error
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true; // Tetap kembalikan true agar UI berpindah
    }
  }

  // Di class AuthProvider, tambahkan metode ini
  Future<void> initializeAuth() async {
    if (_status == AuthStatus.initial) {
      try {
        final isAuth = await _authService.isAuthenticated();
        _rememberMe = await _authService.getRememberMe();

        if (isAuth) {
          debugPrint('Token ditemukan, mencoba mendapatkan data user...');
          final user = await _authService.getCurrentUser();

          if (user != null) {
            _user = user;
            _status = AuthStatus.authenticated;
            debugPrint('User berhasil diambil: ${user.name}');
          } else {
            // Token ada tapi gagal mendapatkan user, mungkin token sudah tidak valid
            debugPrint('Token ada tapi gagal mendapatkan user');
            _status = AuthStatus.unauthenticated;
            await _authService.clearStorage(); // Hapus token yang tidak valid
          }
        } else {
          debugPrint('Tidak ada token tersimpan');
          _status = AuthStatus.unauthenticated;
        }
      } catch (e) {
        debugPrint('Error saat memeriksa status autentikasi: $e');
        _status = AuthStatus.unauthenticated;
        await _authService.clearStorage(); // Hapus token jika ada error
      }

      notifyListeners();
    }

    // Tunggu sampai status tidak initial lagi
    while (_status == AuthStatus.initial) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Reset error message
  void resetError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Toggle remember me
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }
}
