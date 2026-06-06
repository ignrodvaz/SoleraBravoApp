import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'mis_analisis_page.dart';
import 'pages/image_editor.dart';
import 'pages/paywall_page.dart';
import 'perfil_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'services/analysis_service.dart';
import 'firebase_options.dart';
import 'pages/info_hipometro_page.dart';

// ─── Constantes de color ──────────────────────────────────────────────────────
const _kNavyColor = Color(0xff0c1931);
const _kSplashBg  = Color(0xFF0D1B2A);

/// Máximo de análisis gratuitos por mes calendario.
const int _kFreeMonthlyLimit = 3;

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

  // ─── Navegación ─────────────────────────────────────────────────────────────

  void _navigateToEditor(BuildContext context, File file) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ImageEditorPage(imageFile: file)),
    );
  }

  void _openPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallPage()),
    );
  }

  // ─── Lógica de inicio de análisis ──────────────────────────────────────────

  /// Punto de entrada unificado para todos los análisis.
  ///
  /// Comprueba en orden:
  ///   1. Si [isPremiumType] y el usuario es Free → abre el Paywall.
  ///   2. Si el usuario Free ha alcanzado el límite mensual → abre el Paywall.
  ///   3. Procede a capturar la imagen según [source].
  Future<void> _handleAnalysisStart(
    BuildContext context, {
    required bool isPremiumType,
    required ImageSource source,
  }) async {
    final auth = context.read<AuthProvider>();

    // 1. Análisis exclusivo de Premium
    if (isPremiumType && !auth.isPremium) {
      _openPaywall(context);
      return;
    }

    // 2. Límite mensual para usuarios Free
    if (!auth.isPremium) {
      final monthlyCount = await AnalysisService().getMonthlyAnalysisCount();
      if (!context.mounted) return;

      if (monthlyCount >= _kFreeMonthlyLimit) {
        _showLimitDialog(context, monthlyCount);
        return;
      }
    }

    // 3. Capturar imagen
    if (source == ImageSource.camera) {
      await _takePhoto(context);
    } else {
      await _pickFromGallery(context);
    }
  }

  /// Diálogo informativo cuando el usuario Free ha agotado sus análisis del mes.
  void _showLimitDialog(BuildContext context, int count) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2940),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Límite alcanzado',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Has realizado $_kFreeMonthlyLimit análisis este mes.\n\n'
          'Con Premium tienes análisis ilimitados, además del Triángulo de '
          'fuerza y las Líneas de aplomo.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ahora no', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openPaywall(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ver Premium', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Captura de imágenes ────────────────────────────────────────────────────

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

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Suscripción reactiva: se reconstruye si isPremium cambia
    final isPremium = context.watch<AuthProvider>().isPremium;

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
            child: GestureDetector(
              onTap: isPremium ? null : () => _openPaywall(context),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPremium ? Colors.amber.shade200 : Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isPremium)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.lock_outline, color: Colors.white, size: 12),
                      ),
                    Text(
                      isPremium ? 'Premium ✓' : 'Premium',
                      style: TextStyle(
                        color: isPremium ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
            // Contador de análisis Free (visible solo para usuarios Free)
            if (!isPremium) _FreeUsageIndicator(limit: _kFreeMonthlyLimit),
            const Text(
              'Tipos de análisis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Análisis Básico — disponible para todos
            _AnalysisCard(
              title: 'Análisis Básico',
              icon: Icons.bar_chart,
              color: Colors.green,
              label: 'Gratis',
              isLocked: false,
              onCamera: () => _handleAnalysisStart(
                context,
                isPremiumType: false,
                source: ImageSource.camera,
              ),
              onGallery: () => _handleAnalysisStart(
                context,
                isPremiumType: false,
                source: ImageSource.gallery,
              ),
            ),

            // Triángulo de fuerza — bloqueado para usuarios Free
            _AnalysisCard(
              title: 'Triángulo de fuerza',
              icon: Icons.analytics_outlined,
              color: Colors.orange,
              label: 'Premium',
              isLocked: !isPremium,
              onCamera: () => _handleAnalysisStart(
                context,
                isPremiumType: true,
                source: ImageSource.camera,
              ),
              onGallery: () => _handleAnalysisStart(
                context,
                isPremiumType: true,
                source: ImageSource.gallery,
              ),
            ),

            // Líneas de aplomo — bloqueado para usuarios Free
            _AnalysisCard(
              title: 'Líneas de aplomo',
              icon: Icons.history_toggle_off,
              color: Colors.blue,
              label: 'Premium',
              isLocked: !isPremium,
              onCamera: () => _handleAnalysisStart(
                context,
                isPremiumType: true,
                source: ImageSource.camera,
              ),
              onGallery: () => _handleAnalysisStart(
                context,
                isPremiumType: true,
                source: ImageSource.gallery,
              ),
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

/// Indica al usuario Free cuántos análisis le quedan este mes.
class _FreeUsageIndicator extends StatelessWidget {
  const _FreeUsageIndicator({required this.limit});

  final int limit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: AnalysisService().getMonthlyAnalysisCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final used      = snapshot.data!;
        final remaining = (limit - used).clamp(0, limit);
        final progress  = used / limit;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      remaining > 0
                          ? 'Te quedan $remaining análisis gratis este mes'
                          : 'Has agotado tus análisis gratuitos de este mes',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.blue.withValues(alpha: 0.15),
                  color: remaining > 0 ? Colors.blue : Colors.red,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$used de $limit análisis usados este mes',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : Colors.black54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tarjeta de tipo de análisis.
/// [isLocked] muestra un indicador de candado para contenido Premium bloqueado.
class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.label,
    required this.isLocked,
    required this.onCamera,
    required this.onGallery,
  });

  final String       title;
  final IconData     icon;
  final Color        color;
  final String       label;
  final bool         isLocked;
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
            ? color.withValues(alpha: isLocked ? 0.07 : 0.15)
            : color.withValues(alpha: isLocked ? 0.05 : 0.09),
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
              Icon(
                icon,
                color: isLocked ? color.withValues(alpha: 0.5) : color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? (isDark ? Colors.white38 : Colors.black38)
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              // Badge con candado si está bloqueado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[600] : color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLocked) ...[
                      const Icon(Icons.lock, color: Colors.white, size: 10),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Botones de acción (o banner de desbloqueo)
          const SizedBox(height: 12),
          if (isLocked)
            _UnlockBanner(onTap: onCamera) // onCamera abre el paywall igualmente
          else
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

/// Banner dentro de una tarjeta bloqueada que invita a desbloquear Premium.
class _UnlockBanner extends StatelessWidget {
  const _UnlockBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 18),
            SizedBox(width: 8),
            Text(
              'Desbloquear con Premium',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
