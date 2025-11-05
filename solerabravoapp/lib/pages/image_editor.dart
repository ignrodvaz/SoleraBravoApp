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

  // Variables para mover, escalar y rotar
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _position = Offset.zero;
  Offset _previousPosition = Offset.zero;
  double _rotation = 0.0;
  double _previousRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📸 Imagen base
          Positioned.fill(
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),

          // 🌙 Capa oscura ligera
          if (_showHipometro)
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),

          // 🧩 Hipómetro movible y escalable
          if (_showHipometro)
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) {
                  _previousScale = _scale;
                  _previousPosition = details.focalPoint - _position;
                  _previousRotation = _rotation;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _scale = _previousScale * details.scale;
                    _rotation = _previousRotation + details.rotation;
                    _position = details.focalPoint - _previousPosition;
                  });
                },
                child: Center(
                  child: Transform.translate(
                    offset: _position,
                    child: Transform.rotate(
                      angle: _rotation,
                      child: Transform.scale(
                        scale: _scale,
                        child: Image.asset(
                          'src/hipometro.png', // 👈 ruta actualizada
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 📊 Botones de acción (fila en la parte inferior)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: _analysisButton(
                      context,
                      'Análisis Básico',
                      Colors.green.shade400,
                      () {
                        setState(() {
                          _showHipometro = !_showHipometro;
                        });
                      },
                      isActive: _showHipometro,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _analysisButton(
                      context,
                      'Triángulo de fuerza',
                      Colors.orange.shade400,
                      () => Navigator.of(context).pop('Triángulo de fuerza'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _analysisButton(
                      context,
                      '3 Paralelas',
                      Colors.blue.shade400,
                      () => Navigator.of(context).pop('3 Paralelas'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ❌ Botón de cierre
          Positioned(
            top: 36 + MediaQuery.of(context).padding.top,
            left: 8,
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
        ],
      ),
    );
  }

  Widget _analysisButton(BuildContext context, String label, Color color,
      VoidCallback onPressed,
      {bool isActive = false}) {
    final Color bg = isActive ? color.withOpacity(0.85) : color.withOpacity(0.95);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
