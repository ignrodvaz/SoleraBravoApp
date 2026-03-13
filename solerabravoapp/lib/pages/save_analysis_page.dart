import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../services/analysis_service.dart';

class SaveAnalysisPage extends StatefulWidget {
  final File imageFile;
  final String analysisType;
  final String overlayType;
  final Offset overlayPosition;
  final double overlayScale;
  final double overlayRotation;
  final bool imageFlipped;

  const SaveAnalysisPage({
    super.key,
    required this.imageFile,
    required this.analysisType,
    required this.overlayType,
    required this.overlayPosition,
    required this.overlayScale,
    required this.overlayRotation,
    this.imageFlipped = false,
  });

  @override
  State<SaveAnalysisPage> createState() => _SaveAnalysisPageState();
}

class _SaveAnalysisPageState extends State<SaveAnalysisPage> {
  final _notesController = TextEditingController();
  bool _isSaving = false;
  late AnalysisService _analysisService;

  @override
  void initState() {
    super.initState();
    _analysisService = AnalysisService();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<File> _mergeImageWithOverlay() async {
    try {
      // Leer la imagen original
      final imageBytes = await widget.imageFile.readAsBytes();
      final baseImage = img.decodeImage(imageBytes);

      if (baseImage == null) {
        throw Exception('No se pudo procesar la imagen base');
      }

      // Cargar el overlay desde assets
      final overlayAsset = widget.overlayType;
      final assetData = await DefaultAssetBundle.of(context)
          .load('src/$overlayAsset.png');
      var overlayImage = img.decodeImage(Uint8List.view(assetData.buffer));

      if (overlayImage == null) {
        throw Exception('No se pudo procesar el overlay');
      }

      // Invertir overlay si es necesario
      if (widget.imageFlipped) {
        overlayImage = img.flipHorizontal(overlayImage);
      }

      // Crear imagen combinada
      img.Image result =
          img.Image(width: baseImage.width, height: baseImage.height);

      // Copiar imagen base
      result = img.compositeImage(result, baseImage, dstX: 0, dstY: 0);

      // Calcular posición del overlay con escala y rotación
      final centerX = baseImage.width / 2;
      final centerY = baseImage.height / 2;

      // Redimensionar overlay según escala
      final scaledWidth = (overlayImage.width * widget.overlayScale).toInt();
      final scaledHeight = (overlayImage.height * widget.overlayScale).toInt();

      img.Image scaledOverlay = img.copyResize(
        overlayImage,
        width: scaledWidth,
        height: scaledHeight,
      );

      // Posición del overlay (relativa al centro)
      final posX = (centerX + widget.overlayPosition.dx).toInt() -
          (scaledWidth ~/ 2);
      final posY = (centerY + widget.overlayPosition.dy).toInt() -
          (scaledHeight ~/ 2);

      // Componer el overlay sobre la imagen base
      result = img.compositeImage(
        result,
        scaledOverlay,
        dstX: posX,
        dstY: posY,
      );

      // Guardar imagen combinada como PNG
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'analysis_$timestamp.png';
      final outputFile = File('${directory.path}/$fileName');

      await outputFile.writeAsBytes(img.encodePng(result));
      return outputFile;
    } catch (e) {
      print('Error combinando imágenes: $e');
      rethrow;
    }
  }

  Future<void> _saveAnalysis() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Combinar imagen con overlay
      final mergedFile = await _mergeImageWithOverlay();

      // Guardar en Firebase
      final analysis = await _analysisService.saveAnalysis(
        imageFile: mergedFile,
        analysisType: widget.analysisType,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      // Limpiar archivo temporal
      await mergedFile.delete().catchError((_) {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Análisis guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a las pantallas anteriores
        Navigator.of(context).pop(true);
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        print('Error guardando análisis: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9fafc),
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1931),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Guardar análisis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La imagen se combinará con el overlay ${widget.overlayType}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Información del análisis
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de análisis',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(widget.analysisType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.analysisType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor(widget.analysisType),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Campo de notas
            const Text(
              'Notas (opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Agrega notas sobre este análisis...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xff0c1931),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAnalysis,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0c1931),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Guardar análisis'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Análisis Básico':
        return Colors.green;
      case 'Triángulo de fuerza':
        return Colors.orange;
      case '3 Paralelas':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
