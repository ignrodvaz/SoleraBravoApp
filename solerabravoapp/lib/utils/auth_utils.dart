import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Widget que muestra contenido solo para usuarios premium
class PremiumOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const PremiumOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isPremium) {
          return child;
        } else {
          return fallback ?? _buildPremiumPrompt(context);
        }
      },
    );
  }

  Widget _buildPremiumPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Función Premium',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta función está disponible solo para usuarios premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navegar a página de actualización a premium
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Actualizar a Premium'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
            child: const Text('Actualizar a Premium'),
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra contenido solo para usuarios autenticados
class AuthRequired extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AuthRequired({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return child;
        } else {
          return fallback ?? const Center(
            child: Text('Por favor inicia sesión'),
          );
        }
      },
    );
  }
}

/// Extensión para verificar estado de autenticación
extension AuthExtension on BuildContext {
  bool get isAuthenticated {
    return read<AuthProvider>().isAuthenticated;
  }

  bool get isPremium {
    return read<AuthProvider>().isPremium;
  }

  String? get userEmail {
    return read<AuthProvider>().user?.email;
  }

  String? get userName {
    return read<AuthProvider>().user?.displayName;
  }

  String? get userId {
    return read<AuthProvider>().user?.uid;
  }
}

/// Diálogo para mostrar que es necesario ser premium
void showPremiumRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Función Premium'),
      content: const Text(
        'Esta función está disponible solo para usuarios premium. '
        '¿Deseas actualizar tu cuenta?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Navegar a página de upgrade
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[800],
          ),
          child: const Text('Actualizar'),
        ),
      ],
    ),
  );
}

/// Snackbar personalizado para autenticación
void showAuthMessage(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Cerrar',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
