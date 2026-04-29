import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'mis_analisis_page.dart';
import 'pages/image_editor.dart';
import 'perfil_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'firebase_options.dart';

// 👇 AQUÍ IMPORTAMOS TU NUEVA PÁGINA DEL PDF 👇
import 'pages/info_hipometro_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('❌ Error al inicializar Firebase: $e');
  }
  runApp(const SoleraBravoApp());
}

class SoleraBravoApp extends StatelessWidget {
  const SoleraBravoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Hipómetro Áureo', // 👈 Título actualizado
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          scaffoldBackgroundColor: const Color(0xfff9fafc),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Si no hay usuario pero está cargando inicial, mostrar splash
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D1B2A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Inicializando...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (authProvider.isAuthenticated) {
          return const MainNavigation();
        } else {
          return const LoginPage();
        }
      },
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
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImageEditorPage(imageFile: file)));
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
                      final List<XFile> images = await picker.pickMultiImage(
                        imageQuality: 85,
                        requestFullMetadata: false,
                      ) ?? [];
                      
                      if (images.isNotEmpty) {
                        final file = File(images.first.path);
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImageEditorPage(imageFile: file)));
                      }
                    } catch (e) {
                      debugPrint('Error al seleccionar imagen: $e');
                      try {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                          requestFullMetadata: false,
                        );
                        if (image != null) {
                          final file = File(image.path);
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImageEditorPage(imageFile: file)));
                        }
                      } catch (e2) {
                        debugPrint('Error al seleccionar imagen: $e2');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al seleccionar imagen')));
                      }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
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
              title: "Lineas de aplomo",
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
            
            // 👇 AQUÍ ESTÁ EL NUEVO BOTÓN DE LA GUÍA 👇
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoHipometroPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book_rounded, size: 24),
                label: const Text(
                  'Guía del Hipómetro Áureo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0c1931),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 16), // Espacio extra al final para que no quede pegado abajo
          ]
        ),
      ),
    );
  }
}