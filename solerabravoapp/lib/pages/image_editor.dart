import 'dart:io';

import 'package:flutter/material.dart';

class ImageEditorPage extends StatefulWidget {
  final File imageFile;
  const ImageEditorPage({super.key, required this.imageFile});

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  bool _showHipometro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),

          // Slight overlay to improve contrast when hipometro is shown
          if (_showHipometro) Positioned.fill(child: Container(color: Colors.black.withOpacity(0.2))),

          // Hipometro template (only visible when toggled)
          if (_showHipometro)
            Positioned.fill(
              child: Center(
                child: Image.asset(
                  'src/hipometro.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),

          // Right-side buttons
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _analysisButton(context, 'Análisis Básico', Colors.green.shade700, () {
                    // Toggle hipometro template without closing the editor
                    setState(() {
                      _showHipometro = !_showHipometro;
                    });
                  }),
                  const SizedBox(height: 12),
                  _analysisButton(context, 'Triángulo de fuerza', Colors.orange.shade700, () {
                    Navigator.of(context).pop('Triángulo de fuerza');
                  }),
                  const SizedBox(height: 12),
                  _analysisButton(context, '3 Paralelas', Colors.blue.shade700, () {
                    Navigator.of(context).pop('3 Paralelas');
                  }),
                ],
              ),
            ),
          ),

          // Close button (top-left)
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
    final bool isActive = label == 'Análisis Básico' && _showHipometro;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color.withOpacity(0.8) : color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}
