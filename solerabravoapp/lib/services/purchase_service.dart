import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Servicio que encapsula toda la lógica de compras in-app con RevenueCat.
///
/// CONFIGURACIÓN NECESARIA:
/// 1. Crea una cuenta en https://app.revenuecat.com
/// 2. Configura un Entitlement llamado "premium"
/// 3. Crea dos Products: "premium_monthly" y "premium_annual"
/// 4. Crea un Offering con esos dos packages
/// 5. Sustituye las API keys de abajo con las de tu dashboard
class PurchaseService {
  // ⚠️ REEMPLAZA CON TUS API KEYS (RevenueCat Dashboard → API Keys)
  static const String _androidApiKey = 'goog_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  static const String _iosApiKey     = 'appl_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

  /// ID del Entitlement en RevenueCat Dashboard > Entitlements.
  /// Debe llamarse exactamente "premium".
  static const String entitlementId = 'premium';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth     _auth      = FirebaseAuth.instance;

  // ─── Inicialización ────────────────────────────────────────────────────────

  /// Inicializa el SDK de RevenueCat y vincula el UID de Firebase.
  /// Llamar justo después de que Firebase Auth confirme sesión activa.
  Future<void> initialize(String uid) async {
    try {
      final String apiKey = defaultTargetPlatform == TargetPlatform.android
          ? _androidApiKey
          : _iosApiKey;

      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

      final config = PurchasesConfiguration(apiKey);
      await Purchases.configure(config);

      // Vincula el usuario de RevenueCat con el UID de Firebase
      await Purchases.logIn(uid);
      debugPrint('✅ RevenueCat inicializado y vinculado a uid: $uid');
    } catch (e) {
      debugPrint('⚠️ Error al inicializar RevenueCat: $e');
    }
  }

  // ─── Offerings (planes disponibles) ───────────────────────────────────────

  /// Devuelve los Offerings configurados en RevenueCat.
  /// Puede ser null si no hay conexión o si los productos no están configurados.
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) {
        debugPrint('⚠️ No hay un Offering "current" configurado en RevenueCat');
      }
      return offerings;
    } catch (e) {
      debugPrint('❌ Error obteniendo offerings: $e');
      return null;
    }
  }

  // ─── Compra ────────────────────────────────────────────────────────────────

  /// Ejecuta la compra de un [Package] de RevenueCat.
  /// Devuelve true si el entitlement "premium" queda activo tras la compra.
  Future<bool> purchase(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final hasPremium = customerInfo.entitlements.active.containsKey(entitlementId);
      if (hasPremium) await syncPremiumToFirestore(isPremium: true);
      return hasPremium;
    } catch (e) {
      // purchases_flutter lanza una excepción si el usuario cancela.
      // La capturamos para no mostrar error — el usuario simplemente vuelve al paywall.
      debugPrint('⚠️ Compra no completada: $e');
      return false;
    }
  }

  // ─── Restaurar compras ─────────────────────────────────────────────────────

  /// Restaura compras anteriores del usuario.
  /// Devuelve true si el entitlement "premium" queda activo.
  Future<bool> restore() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasPremium = customerInfo.entitlements.active.containsKey(entitlementId);
      await syncPremiumToFirestore(isPremium: hasPremium);
      return hasPremium;
    } catch (e) {
      debugPrint('❌ Error restaurando compras: $e');
      return false;
    }
  }

  // ─── Consulta de estado ────────────────────────────────────────────────────

  /// Consulta el estado premium actual directamente desde RevenueCat.
  /// Usar para refrescar tras una compra o restauración.
  Future<bool> checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      debugPrint('❌ Error consultando estado premium: $e');
      return false;
    }
  }

  // ─── Sincronización con Firestore ─────────────────────────────────────────

  /// Actualiza el campo [isPremium] del usuario en Firestore.
  /// También es llamado por el webhook de Cloud Functions cuando RevenueCat
  /// notifica un cambio de suscripción (renovación, cancelación, etc.).
  ///
  /// Cuando [isPremium] es false, comprueba primero si el usuario tiene
  /// [premiumSource] == 'codigo': en ese caso no escribe nada, para preservar
  /// el acceso concedido por un código de invitación.
  /// Cuando [isPremium] es true, escribe también [premiumSource] == 'suscripcion',
  /// lo que indica que el acceso pasa a estar ligado a la suscripción de pago
  /// (y deja de estar protegido frente a revocaciones futuras).
  Future<void> syncPremiumToFirestore({required bool isPremium}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('⚠️ No hay usuario autenticado — no se puede sincronizar premium');
      return;
    }
    try {
      // Antes de revocar, comprobar que el premium no viene de un código.
      if (!isPremium) {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.data()?['premiumSource'] == 'codigo') {
          debugPrint('🛡 Premium por código — revocación ignorada (uid: $uid)');
          return;
        }
      }

      await _firestore.collection('users').doc(uid).update({
        'isPremium': isPremium,
        // Al confirmar una compra, el origen pasa a ser 'suscripcion'.
        // A partir de aquí el acceso está ligado a RevenueCat.
        if (isPremium) 'premiumSource': 'suscripcion',
        'premiumSyncedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Firestore actualizado: isPremium=$isPremium (uid: $uid)');
    } catch (e) {
      debugPrint('⚠️ Error sincronizando isPremium en Firestore: $e');
    }
  }

  // ─── Cierre de sesión ──────────────────────────────────────────────────────

  /// Desvincula al usuario de RevenueCat al hacer logout.
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
      debugPrint('✅ RevenueCat: sesión cerrada');
    } catch (e) {
      debugPrint('⚠️ Error al cerrar sesión en RevenueCat: $e');
    }
  }
}
