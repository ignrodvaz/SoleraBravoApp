import 'dart:io';
import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  final File imageFile;
  const EditorPage({super.key, required this.imageFile});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  bool _showHipometro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
            ),
          ),

          // Overlay oscuro
          if (_showHipometro)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
              ),
            ),

          // Hipometro
          if (_showHipometro)
            Center(
              child: Image.asset(
                'src/hipometro.png',
                fit: BoxFit.contain,
              ),
            ),

          // Botones
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButton(
                    'Análisis Básico',
                    Colors.green.shade700,
                    () {
                      setState(() {
                        _showHipometro = !_showHipometro;
                      });
                    },
                    isActive: _showHipometro,
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    'Triángulo de fuerza',
                    Colors.orange.shade700,
                    () => Navigator.of(context).pop('Triángulo de fuerza'),
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    '3 Paralelas',
                    Colors.blue.shade700,
                    () => Navigator.of(context).pop('3 Paralelas'),
                  ),
                ],
              ),
            ),
          ),

          // Botón cerrar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed, {bool isActive = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color.withOpacity(0.7) : color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
  }
}
