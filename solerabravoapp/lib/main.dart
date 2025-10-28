import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'editor_page.dart';
import 'perfil_page.dart';
import 'mis_analisis_page.dart';

void main() {
  runApp(const SoleraBravoApp());
}

class SoleraBravoApp extends StatelessWidget {
  const SoleraBravoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solera Bravo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        scaffoldBackgroundColor: const Color(0xfff9fafc),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MisAnalisisPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Mis análisis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

//
// ---------- HOME PAGE (pestaña Inicio) ----------
//
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget buildAnalysisCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String label,
    bool showButtons = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black87)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          ),
          if (showButtons) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    try {
                      final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                      if (photo != null) {
                        final file = File(photo.path);
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditorPage(imageFile: file)));
                      }
                    } catch (e) {
                      debugPrint('Error al capturar la imagen: $e');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al capturar la imagen')));
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text("Tomar foto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0c1931),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    try {
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                      if (image != null) {
                        final file = File(image.path);
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditorPage(imageFile: file)));
                      }
                    } catch (e) {
                      debugPrint('Error al seleccionar imagen: $e');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al seleccionar imagen')));
                    }
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: const Text("Desde galería"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xffd0d4da)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xff0c1931),
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            const Text(
              "Hipometro Áureo",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Premium",
                  style: TextStyle(color: Colors.black, fontSize: 12)),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Tipos de análisis",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          buildAnalysisCard(
            context,
            title: "Análisis Básico",
            icon: Icons.bar_chart,
            color: Colors.green,
            label: "Gratis",
            showButtons: true,
          ),
          buildAnalysisCard(
            context,
            title: "Triángulo de fuerza",
            icon: Icons.analytics_outlined,
            color: Colors.orange,
            label: "Premium",
            showButtons: true,
          ),
          buildAnalysisCard(
            context,
            title: "3 Paralelas",
            icon: Icons.history_toggle_off,
            color: Colors.blue,
            label: "Premium",
            showButtons: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 205, 188, 206),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: const [
              Icon(Icons.lightbulb_outline, color: Color.fromARGB(255, 194, 15, 210)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Toma la foto de perfil del caballo con buena iluminación y separado de su entorno.",
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

//
// ---------- MIS ANALISIS PAGE (pestaña) ----------
//
class MisAnalisisPage extends StatelessWidget {
  const MisAnalisisPage({super.key});

  Widget buildAnalysisItem({
    required String title,
    required String date,
    required ImageProvider image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text("Ver"),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text("Descargar"),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text("Compartir"),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyses = [
      {"title": "Análisis #1", "date": "15 ene 2024 · 14:30"},
      {"title": "Análisis #2", "date": "14 ene 2024 · 16:45"},
      {"title": "Análisis #3", "date": "12 ene 2024 · 10:20"},
      {"title": "Análisis #4", "date": "10 ene 2024 · 12:15"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1931),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Si usas la navegación por pestañas, mejor cambiar de índice.
            // Aquí hacemos un pop simple por si se abrió mediante Navigator.
            Navigator.maybePop(context);
          },
        ),
        title: const Text("Mis análisis",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text("${analyses.length} análisis guardados",
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(children: [
              Text("${analyses.length}",
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              const Text("Análisis guardados", style: TextStyle(color: Colors.black54)),
            ]),
          ),
          const SizedBox(height: 20),
          for (var a in analyses)
            buildAnalysisItem(
              title: a["title"]!,
              date: a["date"]!,
              image: const AssetImage('assets/images/horse.jpg'),
            ),
        ]),
      ),
    );
  }
}