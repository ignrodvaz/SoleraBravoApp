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
    clientId: kIsWeb ? '376046740870-o1out8c3jrhqi0rc22q6avl7j60e9vp2.apps.googleusercontent.com' : null,
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
    required String inviteCode,
  }) async {
    try {
      // Verificar el código de invitación
      debugPrint("Verificando código de invitación: $inviteCode");
      var codigoDoc = await _firestore.collection('codigos_invitacion')
      .where('codigo', isEqualTo: inviteCode)
      .limit(1)
      .get();

      if (codigoDoc.docs.isEmpty){
        debugPrint("Código no encontrado");
        throw Exception("CODIGO_INVALIDO");
      }

      var datosCodigo = codigoDoc.docs.first.data();
      String docId = codigoDoc.docs.first.id;

      if(datosCodigo["usado"] == true){
        debugPrint("Código ya utilizado");
        throw Exception("CODIGO_USADO");
      }

      bool codigoDaPremium = datosCodigo['plan'] == 'premium';

      debugPrint("Código válido. Procediendo al registro...");

      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar el displayName
      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.reload();

      bool finalIsPremium = isPremium || codigoDaPremium;

      // Guardar datos del usuario en Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'isPremium': finalIsPremium,
        // Solo se escribe premiumSource cuando el código otorga premium.
        // Protege a este usuario de que el webhook o restore() revoquen su acceso.
        if (finalIsPremium) 'premiumSource': 'codigo',
        'codigoUsado': inviteCode,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      await _firestore.collection("codigos_invitacion").doc(docId).update({
        'usado': true,
        'usadoPor': userCredential.user!.uid,
        'fechaUso': DateTime.now(),
      });

      debugPrint("Registro completado y código quemado");

      return userCredential;
    } on FirebaseAuthException {
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
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Iniciar sesión con Google
// Iniciar sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('📱 Iniciando Google Sign-In...');
      
      // 1. Declaramos la variable una sola vez arriba
      UserCredential userCredential;

      if (kIsWeb) {
        // 🌐 EL NUEVO CAMBIO: RUTA EXCLUSIVA PARA WEB
        // Esto evita el error de la ventana que se cierra sola
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        userCredential = await _firebaseAuth.signInWithPopup(authProvider);
        debugPrint('✅ Usuario autenticado en Web: ${userCredential.user?.email}');
        
      } else {
        // 📱 TU CÓDIGO ORIGINAL: RUTA PARA ANDROID/iOS
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          debugPrint('❌ El usuario canceló el Google Sign-In');
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 2. Asignamos el valor a la variable (sin volver a declararla con 'final')
        userCredential = await _firebaseAuth.signInWithCredential(credential);
        debugPrint('✅ Usuario autenticado en Móvil: ${userCredential.user?.email}');
      }

      // --- ESTO ES IGUAL: GUARDADO EN FIRESTORE ---
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      debugPrint('📝 Nuevo usuario: $isNewUser');

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
    } on FirebaseAuthException {
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
