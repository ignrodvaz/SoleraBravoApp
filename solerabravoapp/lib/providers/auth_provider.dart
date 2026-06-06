import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/auth_service.dart';
import '../services/purchase_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService     _authService     = AuthService();
  final PurchaseService _purchaseService = PurchaseService();

  User?   _user;
  bool    _isLoading  = false;
  String? _errorMessage;
  bool    _isPremium  = false;

  /// Evita registrar el listener de RevenueCat más de una vez.
  bool _revenueCatListenerRegistered = false;

  /// Activo mientras register() está en curso.
  /// Evita que _onAuthStateChanged notifique con isPremium=false antes de que
  /// el documento de Firestore termine de escribirse.
  bool _registrationInProgress = false;

  // ─── Getters ────────────────────────────────────────────────────────────────
  User?   get user            => _user;
  bool    get isLoading       => _isLoading;
  String? get errorMessage    => _errorMessage;
  bool    get isPremium       => _isPremium;
  bool    get isAuthenticated => _user != null;

  // ─── Constructor ─────────────────────────────────────────────────────────────
  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged, onError: (error) {
      debugPrint('❌ Error en stream de autenticación: $error');
    });
  }

  Future<void> _onAuthStateChanged(User? user) async {
    try {
      debugPrint('🔄 Cambio de autenticación: ${user?.email}');
      _user = user;

      if (_registrationInProgress) {
        // register() está esperando a que Firestore termine de escribir el
        // documento. Le cedemos el control: él leerá isPremium correcto y
        // llamará a notifyListeners(). Aquí solo preparamos RevenueCat.
        if (user != null) {
          await _purchaseService.initialize(user.uid);
          _registerRevenueCatListener();
        }
        return;
      }

      if (user != null) {
        // 1. Carga rápida desde Firestore (fuente de verdad offline)
        _isPremium = await _authService.isPremiumUser(user.uid);
        notifyListeners();

        // 2. Inicializa RevenueCat y vincula al usuario
        await _purchaseService.initialize(user.uid);

        // 3. Registra listener para cambios en tiempo real de RevenueCat
        _registerRevenueCatListener();
      } else {
        _isPremium = false;
        await _purchaseService.logOut();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Error al procesar cambio de autenticación: $e');
      notifyListeners();
    }
  }

  /// Registra el listener de CustomerInfo de RevenueCat (solo una vez).
  /// Se activa automáticamente cuando RevenueCat detecta un cambio de suscripción
  /// (compra, renovación, cancelación, expiración…).
  void _registerRevenueCatListener() {
    if (_revenueCatListenerRegistered) return;
    _revenueCatListenerRegistered = true;

    Purchases.addCustomerInfoUpdateListener((CustomerInfo customerInfo) async {
      final hasPremium = customerInfo.entitlements.active
          .containsKey(PurchaseService.entitlementId);

      if (hasPremium != _isPremium) {
        debugPrint('🔔 RevenueCat: cambio de premium → $hasPremium');
        _isPremium = hasPremium;
        notifyListeners();
        // Sincroniza el nuevo estado en Firestore
        await _purchaseService.syncPremiumToFirestore(isPremium: hasPremium);
      }
    });

    debugPrint('✅ Listener de RevenueCat registrado');
  }

  // ─── Refresco manual de premium ──────────────────────────────────────────────

  /// Consulta RevenueCat directamente y actualiza el estado.
  /// Llamar después de una compra o restauración exitosa.
  Future<void> refreshPremiumStatus() async {
    try {
      final hasPremium = await _purchaseService.checkPremiumStatus();
      if (hasPremium != _isPremium) {
        _isPremium = hasPremium;
        notifyListeners();
        debugPrint('🔄 Premium refrescado: $_isPremium');
      }
    } catch (e) {
      debugPrint('⚠️ Error al refrescar estado premium: $e');
    }
  }

  // ─── Registrar ────────────────────────────────────────────────────────────────
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    bool isPremium = false,
    required String inviteCode,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      // Señalamos a _onAuthStateChanged que no lea isPremium todavía:
      // el documento de Firestore aún no existe cuando authStateChanges dispara.
      _registrationInProgress = true;
      notifyListeners();

      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        isPremium: isPremium,
        inviteCode: inviteCode,
      );

      // En este punto el documento ya está escrito en Firestore (el await
      // anterior lo espera). Leemos isPremium con el valor correcto.
      final uid = _authService.currentUser?.uid ?? _user?.uid;
      if (uid != null) {
        _isPremium = await _authService.isPremiumUser(uid);
        debugPrint('✅ isPremium tras registro: $_isPremium');
      }

      _registrationInProgress = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _registrationInProgress = false;
      _isLoading = false;
      if (e.toString().contains('CODIGO_INVALIDO')) {
        _errorMessage = 'El código de invitación no existe o es incorrecto.';
      } else if (e.toString().contains('CODIGO_USADO')) {
        _errorMessage = 'Este código de invitación ya ha sido utilizado.';
      } else {
        _errorMessage = _getErrorMessage(e.toString());
      }
      notifyListeners();
      return false;
    }
  }

  // ─── Iniciar sesión ───────────────────────────────────────────────────────────
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

  // ─── Google Sign-In ───────────────────────────────────────────────────────────
  Future<bool> loginWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithGoogle();

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

  // ─── Cerrar sesión ────────────────────────────────────────────────────────────
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

  // ─── Actualizar perfil ────────────────────────────────────────────────────────
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

  // ─── Restablecer contraseña ───────────────────────────────────────────────────
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

  // ─── Limpiar error ────────────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Mensajes de error en español ────────────────────────────────────────────
  String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use'))  return 'El email ya está registrado';
    if (error.contains('invalid-email'))         return 'Email inválido';
    if (error.contains('weak-password'))         return 'La contraseña es muy débil';
    if (error.contains('user-not-found'))        return 'Usuario no encontrado';
    if (error.contains('wrong-password'))        return 'Contraseña incorrecta';
    if (error.contains('too-many-requests'))     return 'Demasiados intentos fallidos. Intenta más tarde';
    return 'Error de autenticación';
  }
}
