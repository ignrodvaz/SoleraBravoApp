import 'dart:io';
import 'package:flutter/material.dart';
import '../services/analysis_service.dart';
import 'package:gal/gal.dart';

class SaveAnalysisPage extends StatefulWidget {
  final File imageFile; // Esta será la captura ya fusionada
  final String analysisType;

  const SaveAnalysisPage({
    super.key,
    required this.imageFile,
    required this.analysisType,
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

Future<void> _saveAnalysis() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // 1. Guardar en Firebase[cite: 2, 3]
      await _analysisService.saveAnalysis(
        imageFile: widget.imageFile,
        analysisType: widget.analysisType,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      // 2. GUARDAR EN LA GALERÍA
      await Gal.putImage(widget.imageFile.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guardado en la nube y en tu galería ✅'),
            backgroundColor: Colors.green,
          ),
        );

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
            // Previsualización de la captura final
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                widget.imageFile,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
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
                  const Text('Tipo de análisis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(widget.analysisType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.analysisType,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _getTypeColor(widget.analysisType)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Campo de notas
            const Text('Notas (opcional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Agrega notas sobre este análisis...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAnalysis,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff0c1931), foregroundColor: Colors.white),
                    child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Análisis Básico': return Colors.green;
      case 'Triángulo de fuerza': return Colors.orange;
      case 'Lineas de aplomo': return Colors.blue;
      default: return Colors.grey;
    }
  }
}