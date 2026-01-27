import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/analysis_model.dart';

class AnalysisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Guardar un análisis con su imagen
  Future<AnalysisModel?> saveAnalysis({
    required File imageFile,
    required String analysisType,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Generar nombre único para la imagen
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'analisis_${user.uid}_$timestamp.png';
      final filePath = 'users/${user.uid}/analyses/$fileName';

      // Subir imagen a Firebase Storage
      final ref = _storage.ref(filePath);
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/png',
          customMetadata: {
            'userId': user.uid,
            'analysisType': analysisType,
          },
        ),
      );

      // Obtener URL de descarga
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // Crear documento en Firestore
      final analysisRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .doc();

      final analysis = AnalysisModel(
        id: analysisRef.id,
        userId: user.uid,
        title: 'Análisis - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        type: analysisType,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        notes: notes,
      );

      await analysisRef.set(analysis.toFirestore());

      return analysis;
    } catch (e) {
      print('Error guardando análisis: $e');
      rethrow;
    }
  }

  // Obtener todos los análisis del usuario actual
  Stream<List<AnalysisModel>> getUserAnalyses() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AnalysisModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('Error obteniendo análisis: $e');
      return Stream.value([]);
    }
  }

  // Obtener un análisis específico
  Future<AnalysisModel?> getAnalysis(String analysisId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .doc(analysisId)
          .get();

      if (doc.exists) {
        return AnalysisModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo análisis: $e');
      return null;
    }
  }

  // Eliminar un análisis
  Future<bool> deleteAnalysis(String analysisId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el documento para obtener la URL de la imagen
      final analysisDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .doc(analysisId)
          .get();

      if (analysisDoc.exists) {
        final analysis = AnalysisModel.fromFirestore(analysisDoc);

        // Eliminar imagen de Storage
        try {
          final fileRef = _storage.refFromURL(analysis.imageUrl);
          await fileRef.delete();
        } catch (e) {
          print('Error eliminando imagen: $e');
          // Continuar con la eliminación del documento aunque falle la imagen
        }

        // Eliminar documento de Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('analyses')
            .doc(analysisId)
            .delete();

        return true;
      }
      return false;
    } catch (e) {
      print('Error eliminando análisis: $e');
      rethrow;
    }
  }

  // Actualizar notas de un análisis
  Future<void> updateAnalysisNotes(String analysisId, String notes) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .doc(analysisId)
          .update({'notes': notes});
    } catch (e) {
      print('Error actualizando notas: $e');
      rethrow;
    }
  }

  // Contar análisis del usuario
  Future<int> getAnalysisCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('Error contando análisis: $e');
      return 0;
    }
  }
}
