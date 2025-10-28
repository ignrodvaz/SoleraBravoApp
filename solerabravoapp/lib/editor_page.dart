import 'dart:io';

import 'package:flutter/material.dart';

class EditorPage extends StatelessWidget {
  final File imageFile;
  const EditorPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: const Text('Editor de imagen'),
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay para mejorar contraste
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          // Botones de análisis
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop('Análisis Básico');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccionado: Análisis Básico')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Análisis Básico'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop('Triángulo de fuerza');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccionado: Triángulo de fuerza')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Triángulo de fuerza'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop('3 Paralelas');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccionado: 3 Paralelas')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('3 Paralelas'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
