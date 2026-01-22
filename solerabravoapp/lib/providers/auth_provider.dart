import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPremium = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _isPremium;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Escuchar cambios de autenticación
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        _isPremium = await _authService.isPremiumUser(user.uid);
      } else {
        _isPremium = false;
      }
      notifyListeners();
    });
  }

  // Registrar
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    bool isPremium = false,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        isPremium: isPremium,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  // Iniciar sesión
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signOut();
      _user = null;
      _isPremium = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
    }
  }

  // Actualizar perfil
  Future<bool> updateProfile({
    required String fullName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (_user == null) return false;
      _isLoading = true;
      notifyListeners();

      await _authService.updateUserProfile(
        uid: _user!.uid,
        fullName: fullName,
        additionalData: additionalData,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Mapear errores de Firebase a mensajes en español
  String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'El email ya está registrado';
    } else if (error.contains('invalid-email')) {
      return 'Email inválido';
    } else if (error.contains('weak-password')) {
      return 'La contraseña es muy débil';
    } else if (error.contains('user-not-found')) {
      return 'Usuario no encontrado';
    } else if (error.contains('wrong-password')) {
      return 'Contraseña incorrecta';
    } else if (error.contains('too-many-requests')) {
      return 'Demasiados intentos fallidos. Intenta más tarde';
    }
    return 'Error de autenticación';
  }
}
