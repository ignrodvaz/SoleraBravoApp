import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_utils.dart';

/// Ejemplo de cómo integrar autenticación en una página existente
/// 
/// Este archivo muestra patrones de uso común:
/// 1. Verificar si el usuario es premium
/// 2. Proteger funciones solo para premium
/// 3. Mostrar información del usuario
/// 4. Cerrar sesión

class AuthIntegrationExample extends StatelessWidget {
  const AuthIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo de Integración de Auth'),
        backgroundColor: Colors.amber[800],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isAuthenticated) {
            return const Center(
              child: Text('Por favor inicia sesión'),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del usuario
                  _buildUserInfoCard(context, authProvider),
                  const SizedBox(height: 24),

                  // Funciones premium
                  const Text(
                    'Funciones Premium',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (authProvider.isPremium)
                    _buildPremiumFeatures(context)
                  else
                    _buildNonPremiumPrompt(context),

                  const SizedBox(height: 24),
                  // Botón de cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cerrar sesión'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoCard(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.amber[800],
                  child: Text(
                    authProvider.user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.user?.displayName ?? 'Usuario',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        authProvider.user?.email ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: authProvider.isPremium ? Colors.amber[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                authProvider.isPremium ? '👑 Usuario Premium' : 'Usuario Regular',
                style: TextStyle(
                  color: authProvider.isPremium ? Colors.amber[800] : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeatures(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.analytics,
          title: 'Análisis Avanzado',
          description: 'Acceso a análisis detallados y reportes personalizados',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.cloud_upload,
          title: 'Sincronización en la Nube',
          description: 'Sincroniza tus datos en múltiples dispositivos',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.priority_high,
          title: 'Soporte Prioritario',
          description: 'Obtén ayuda prioritaria de nuestro equipo',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.amber[800], size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }

  Widget _buildNonPremiumPrompt(BuildContext context) {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.amber[800]),
                const SizedBox(width: 8),
                const Text(
                  'Funciones Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Estas funciones están disponibles solo para usuarios premium. Actualiza tu cuenta para disfrutar de todas las ventajas.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => showPremiumRequiredDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                ),
                child: const Text('Actualizar a Premium'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                showAuthMessage(
                  context,
                  'Sesión cerrada exitosamente',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
