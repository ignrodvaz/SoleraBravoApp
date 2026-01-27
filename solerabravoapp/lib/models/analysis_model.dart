import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisModel {
  final String id;
  final String userId;
  final String title;
  final String type; // "Análisis Básico", "Triángulo de fuerza", "3 Paralelas"
  final String imageUrl; // URL de la imagen en Storage
  final DateTime createdAt;
  final String? notes;

  AnalysisModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.imageUrl,
    required this.createdAt,
    this.notes,
  });

  // Convertir de Firestore a modelo
  factory AnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnalysisModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'Análisis',
      type: data['type'] ?? 'Análisis Básico',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
    );
  }

  // Convertir modelo a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'type': type,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  // Formato de fecha amigable
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Hoy a las ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer a las ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${createdAt.day} ${_getMonthName(createdAt.month)} ${createdAt.year}';
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    return months[month - 1];
  }
}
