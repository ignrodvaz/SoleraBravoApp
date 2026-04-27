import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class InfoHipometroPage extends StatelessWidget {
  const InfoHipometroPage({super.key});

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
          'Hipómetro Áureo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Sección de texto explicativo
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Guía de proporciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'El Hipómetro Áureo es una herramienta fundamental para evaluar las proporciones ideales y la biomecánica. En el siguiente documento encontrarás toda la teoría y las guías de uso.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Visor del PDF
          Expanded(
            child: SfPdfViewer.asset(
              'src/hipometro_aureo.pdf', // Aquí lee el PDF de tus assets
              canShowScrollHead: false,
              canShowScrollStatus: true,
            ),
          ),
        ],
      ),
    );
  }
}