import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'save_analysis_page.dart';

class ImageEditorPage extends StatefulWidget {
  final File imageFile;
  const ImageEditorPage({super.key, required this.imageFile});

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  String? _currentOverlay; // 'hipometro' or 'triangulo'
  bool _imageFlipped = false;

  // Variables para mover, escalar y rotar
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _position = Offset.zero;
  Offset _previousPosition = Offset.zero;
  double _rotation = 0.0;
  double _previousRotation = 0.0;

  void _saveAnalysis() {
    if (_currentOverlay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un tipo de análisis'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mapear el overlay al nombre del análisis
    final analysisTypeMap = {
      'hipometro': 'Análisis Básico',
      'Triangulo_Fuerza': 'Triángulo de fuerza',
      'Aplomo': 'Lineas de aplomo',
    };

    final analysisType = analysisTypeMap[_currentOverlay] ?? 'Análisis';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveAnalysisPage(
          imageFile: widget.imageFile,
          analysisType: analysisType,
          overlayType: _currentOverlay!,
          overlayPosition: _position,
          overlayScale: _scale,
          overlayRotation: _rotation,
          imageFlipped: _imageFlipped,
        ),
      ),
    );
  }

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
          if (_currentOverlay != null)
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),

          // 🧩 Overlay movible y escalable
          if (_currentOverlay != null)
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
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0001)
                          ..rotateY(_imageFlipped ? 3.14159 : 0),
                        child: Transform.scale(
                          scale: _scale,
                          child: Image.asset(
                            'src/$_currentOverlay.png',
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
            ),

          // 📊 Botones de acción
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _analysisButton(
                          context,
                          'Análisis Básico',
                          Colors.green.shade400,
                          () {
                            setState(() {
                              if (_currentOverlay == 'hipometro') {
                                _currentOverlay = null;
                              } else {
                                _currentOverlay = 'hipometro';
                              }
                            });
                          },
                          isActive: _currentOverlay == 'hipometro',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _analysisButton(
                          context,
                          'Triángulo de fuerza',
                          Colors.orange.shade400,
                          () {
                            setState(() {
                              if (_currentOverlay == 'Triangulo_Fuerza') {
                                _currentOverlay = null;
                              } else {
                                _currentOverlay = 'Triangulo_Fuerza';
                              }
                            });
                          },
                          isActive: _currentOverlay == 'Triangulo_Fuerza',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _analysisButton(
                          context,
                          'Lineas de aplomo',
                          Colors.blue.shade400,
                          () {
                            setState(() {
                              if (_currentOverlay == 'Aplomo') {
                                _currentOverlay = null;
                              } else {
                                _currentOverlay = 'Aplomo';
                              }
                            });
                          },
                          isActive: _currentOverlay == 'Aplomo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveAnalysis,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Guardar análisis'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 138, 49, 128),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

          // 🔄 Botón invertir overlay (arriba a la derecha)
          Positioned(
            top: 36 + MediaQuery.of(context).padding.top,
            right: 8,
            child: ClipOval(
              child: Material(
                color: _imageFlipped ? Colors.blue : Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.restart_alt, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _imageFlipped = !_imageFlipped;
                    });
                  },
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
