import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Auto-detect Android OAuth client from google-services.json
    // Scopes help ensure proper GMS initialization
    scopes: [
      'email',
      'profile',
    ],
  );

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  // Registrar usuario con email y contraseña
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required bool isPremium,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar el displayName
      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.reload();

      // Guardar datos del usuario en Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'isPremium': isPremium,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('📱 Iniciando Google Sign-In...');
      
      // Realizar el flujo de sign-in de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ El usuario canceló el Google Sign-In');
        return null;
      }

      debugPrint('✅ Usuario de Google seleccionado: ${googleUser.email}');

      // Obtener el token de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint('✅ Tokens obtenidos');

      // Crear las credenciales de Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('✅ Credenciales de Firebase creadas');

      // Iniciar sesión en Firebase con las credenciales de Google
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      debugPrint('✅ Usuario autenticado en Firebase: ${userCredential.user?.email}');

      // Verificar si el usuario es nuevo
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      debugPrint('📝 Nuevo usuario: $isNewUser');

      // Si es un usuario nuevo, crear su documento en Firestore
      if (isNewUser) {
        debugPrint('📝 Creando documento en Firestore...');
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'fullName': userCredential.user!.displayName ?? 'Usuario',
          'isPremium': false,
          'profilePicture': userCredential.user!.photoURL,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });
        debugPrint('✅ Documento creado en Firestore');
      } else {
        debugPrint('📝 Usuario existente, saltando creación de documento');
      }

      debugPrint('✅ Google Sign-In completado exitosamente');
      return userCredential;
    } catch (e) {
      debugPrint('❌ Error en Google Sign-In: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  // Verificar si el usuario es premium
  Future<bool> isPremiumUser(String uid) async {
    try {
      debugPrint('📊 Verificando estado premium del usuario: $uid');
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      bool isPremium = data?['isPremium'] ?? false;
      debugPrint('✅ Premium: $isPremium');
      return isPremium;
    } catch (e) {
      debugPrint('⚠️ Error al verificar premium: $e');
      return false;
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': DateTime.now(),
      };

      if (fullName != null) {
        updateData['fullName'] = fullName;
        await _firebaseAuth.currentUser?.updateDisplayName(fullName);
      }

      updateData.addAll(additionalData ?? {});

      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  // Reenviar correo de verificación
  Future<void> sendVerificationEmail() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
