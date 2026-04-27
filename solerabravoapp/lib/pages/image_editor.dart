import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'save_analysis_page.dart';

class ImageEditorPage extends StatefulWidget {
  final File imageFile;
  const ImageEditorPage({super.key, required this.imageFile});

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  String? _currentOverlay;
  bool _imageFlipped = false;
  
  // Llave para la captura de pantalla
  final GlobalKey _captureKey = GlobalKey();

  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _position = Offset.zero;
  Offset _previousPosition = Offset.zero;
  double _rotation = 0.0;
  double _previousRotation = 0.0;

  // Función mágica para hacer la captura
  Future<File?> _captureImage() async {
    try {
      RenderRepaintBoundary boundary = _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Alta calidad
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/captura_$timestamp.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      return imageFile;
    } catch (e) {
      debugPrint("Error en la captura: $e");
      return null;
    }
  }

  void _saveAnalysis() async {
    if (_currentOverlay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un tipo de análisis'), backgroundColor: Colors.orange),
      );
      return;
    }

    // Mostrar un indicador de carga mientras procesa la imagen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Hacer la captura
    File? capturedImage = await _captureImage();
    
    // Cerrar el indicador de carga
    if (mounted) Navigator.pop(context);

    if (capturedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al procesar la imagen'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final analysisTypeMap = {
      'hipometro': 'Análisis Básico',
      'Triangulo_Fuerza': 'Triángulo de fuerza',
      'Aplomo': 'Lineas de aplomo',
    };

    final analysisType = analysisTypeMap[_currentOverlay] ?? 'Análisis';

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SaveAnalysisPage(
            imageFile: capturedImage, // Pasamos la CAPTURA
            analysisType: analysisType,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📸 ESTO ES LO QUE SALDRÁ EN LA CAPTURA
          RepaintBoundary(
            key: _captureKey,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(widget.imageFile, fit: BoxFit.cover, gaplessPlayback: true),
                
                if (_currentOverlay != null)
                  Container(color: Colors.black.withOpacity(0.2)),

                if (_currentOverlay != null)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
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
                              child: Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.all(40.0),
                                child: Image.asset(
                                  'src/$_currentOverlay.png',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 📊 BOTONES (ESTO SE QUEDA FUERA DE LA CAPTURA)
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _analysisButton(context, 'Básico', Colors.green.shade400, () {
                          setState(() => _currentOverlay = _currentOverlay == 'hipometro' ? null : 'hipometro');
                        }, isActive: _currentOverlay == 'hipometro'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _analysisButton(context, 'Triángulo', Colors.orange.shade400, () {
                          setState(() => _currentOverlay = _currentOverlay == 'Triangulo_Fuerza' ? null : 'Triangulo_Fuerza');
                        }, isActive: _currentOverlay == 'Triangulo_Fuerza'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _analysisButton(context, 'Aplomo', Colors.blue.shade400, () {
                          setState(() => _currentOverlay = _currentOverlay == 'Aplomo' ? null : 'Aplomo');
                        }, isActive: _currentOverlay == 'Aplomo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveAnalysis,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Continuar al guardado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 138, 49, 128),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ❌ Botón de cierre
          Positioned(
            top: 36 + MediaQuery.of(context).padding.top, left: 8,
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

          // 🔄 Botón invertir overlay
          Positioned(
            top: 36 + MediaQuery.of(context).padding.top, right: 8,
            child: ClipOval(
              child: Material(
                color: _imageFlipped ? Colors.blue : Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.restart_alt, color: Colors.white),
                  onPressed: () => setState(() => _imageFlipped = !_imageFlipped),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisButton(BuildContext context, String label, Color color, VoidCallback onPressed, {bool isActive = false}) {
    final Color bg = isActive ? color.withOpacity(0.85) : color.withOpacity(0.95);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
    );
  }
}