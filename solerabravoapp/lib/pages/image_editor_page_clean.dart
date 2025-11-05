import 'dart:io';

import 'package:flutter/material.dart';

class ImageEditorPageClean extends StatelessWidget {
  final File imageFile;
  const ImageEditorPageClean({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.25))),
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                  height: 64,
                  child: Image.asset(
                    'assets/hipometro.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _analysisButton(context, 'Análisis Básico', Colors.green.shade700, () {
                    Navigator.of(context).pop('Análisis Básico');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccionado: Análisis Básico')));
                  }),
                  const SizedBox(height: 12),
                  _analysisButton(context, 'Triángulo de fuerza', Colors.orange.shade700, () {
                    Navigator.of(context).pop('Triángulo de fuerza');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccionado: Triángulo de fuerza')));
                  }),
                  const SizedBox(height: 12),
                  _analysisButton(context, '3 Paralelas', Colors.blue.shade700, () {
                    Navigator.of(context).pop('3 Paralelas');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccionado: 3 Paralelas')));
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            top: 36,
            left: 8,
            child: SafeArea(
              child: ClipOval(
                child: Material(
                  color: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisButton(BuildContext context, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}
