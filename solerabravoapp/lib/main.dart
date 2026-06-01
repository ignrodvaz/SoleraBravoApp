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
import 'pages/info_hipometro_page.dart';

// ─── Constantes de color ──────────────────────────────────────────────────────
const _kNavyColor  = Color(0xff0c1931);
const _kSplashBg   = Color(0xFF0D1B2A);

// ─── Entry point ─────────────────────────────────────────────────────────────
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

// ─── App root ─────────────────────────────────────────────────────────────────
class SoleraBravoApp extends StatelessWidget {
  const SoleraBravoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Hipómetro Áureo',
          debugShowCheckedModeBanner: false,
          locale: Locale(settings.language),
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xfff9fafc),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

// ─── Auth gate ────────────────────────────────────────────────────────────────
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) return const _LoadingScreen();
        return auth.isAuthenticated ? const MainNavigation() : const LoginPage();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSplashBg,
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
}

// ─── Navegación principal ─────────────────────────────────────────────────────
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // static const: no se recrea en cada rebuild
  static const _pages = <Widget>[
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

// ─── Pantalla de inicio ───────────────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Helper compartido: evita duplicar Navigator.push en cada método
  void _navigateToEditor(BuildContext context, File file) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ImageEditorPage(imageFile: file)),
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (!context.mounted || photo == null) return;
      _navigateToEditor(context, File(photo.path));
    } catch (e) {
      debugPrint('Error al capturar la imagen: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al capturar la imagen')),
      );
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    try {
      // pickImage es suficiente: solo necesitamos una imagen
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (!context.mounted || image == null) return;
      _navigateToEditor(context, File(image.path));
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar imagen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: _kNavyColor,
        elevation: 0,
        title: const Row(
          children: [
            SizedBox(width: 16),
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Hipómetro Áureo',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Premium',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipos de análisis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _AnalysisCard(
              title: 'Análisis Básico',
              icon: Icons.bar_chart,
              color: Colors.green,
              label: 'Gratis',
              onCamera: () => _takePhoto(context),
              onGallery: () => _pickFromGallery(context),
            ),
            _AnalysisCard(
              title: 'Triángulo de fuerza',
              icon: Icons.analytics_outlined,
              color: Colors.orange,
              label: 'Premium',
              onCamera: () => _takePhoto(context),
              onGallery: () => _pickFromGallery(context),
            ),
            _AnalysisCard(
              title: 'Líneas de aplomo',
              icon: Icons.history_toggle_off,
              color: Colors.blue,
              label: 'Premium',
              onCamera: () => _takePhoto(context),
              onGallery: () => _pickFromGallery(context),
            ),
            const SizedBox(height: 16),
            const _TipBanner(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InfoHipometroPage()),
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 24),
                label: const Text(
                  'Guía del Hipómetro Áureo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavyColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets reutilizables ────────────────────────────────────────────────────

/// Tarjeta de tipo de análisis con botones de cámara y galería.
class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.label,
    required this.onCamera,
    required this.onGallery,
  });

  final String       title;
  final IconData     icon;
  final Color        color;
  final String       label;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
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
              ),
            ],
          ),
          // Botones de acción
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Tomar foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kNavyColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Desde galería'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xffd0d4da)),
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Banner de consejo de uso.
class _TipBanner extends StatelessWidget {
  const _TipBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.purple.withValues(alpha: 0.2)
            : const Color.fromARGB(255, 205, 188, 206),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color.fromARGB(255, 194, 15, 210),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Toma la foto de perfil del caballo con buena iluminación y separado de su entorno.',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
