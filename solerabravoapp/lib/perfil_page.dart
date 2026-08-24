import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'providers/auth_provider.dart';
import 'pages/settings_page.dart';
import 'pages/paywall_page.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectamos si el modo oscuro está activo
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final userName = user?.displayName ?? 'Usuario';
        final userEmail = user?.email ?? 'Sin email';
        final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return Scaffold(
          // Quitamos el color fijo para que respete el del Theme (claro u oscuro)
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado superior
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1B2A), // Este lo dejamos oscuro siempre por diseño
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mi perfil",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Configuración de cuenta",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tarjeta de usuario
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar circular
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.amber[200],
                        child: Text(
                          firstLetter,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, // La letra dentro del círculo amarillo siempre negra
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info del usuario
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (authProvider.isPremium)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Premium",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.amber[900],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              authProvider.isPremium ? "Usuario Premium" : "Usuario Regular",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : Colors.black87),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Estadísticas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard("45", "Análisis realizados", Icons.bar_chart, isDark),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Plan Premium
                if (authProvider.isPremium)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF332A15) : const Color(0xFFFFF7E5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              "Plan Premium",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Disfruta de análisis ilimitados y funciones avanzadas.",
                          style: GoogleFonts.poppins(
                            fontSize: 13, 
                            color: isDark ? Colors.white70 : Colors.black54
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _manageSubscription(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            "Gestionar plan",
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF152233) : Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.upgrade_outlined, color: Colors.blue[400]),
                            const SizedBox(width: 8),
                            Text(
                              "Mejora a Premium",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Obtén acceso a funciones avanzadas y análisis ilimitados.",
                          style: GoogleFonts.poppins(
                            fontSize: 13, 
                            color: isDark ? Colors.white70 : Colors.black54
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PaywallPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            "Actualizar ahora",
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Configuración
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Configuración",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.lock_outline, color: isDark ? Colors.white70 : Colors.black87),
                        title: Text("Cambiar contraseña", style: GoogleFonts.poppins(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white54 : Colors.black54),
                        onTap: () {
                          _showChangePasswordDialog(context, authProvider);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          "Cerrar sesión",
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => _handleLogout(context, authProvider),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
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
              await authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 98, 140, 204),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Future<void> _manageSubscription(BuildContext context) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final managementUrl = customerInfo.managementURL;
      if (managementUrl == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró ninguna suscripción activa para gestionar.')),
          );
        }
        return;
      }
      final launched = await launchUrl(Uri.parse(managementUrl), mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la gestión de la suscripción.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir la gestión de la suscripción: $e')),
        );
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider authProvider) {
    final emailController = TextEditingController(text: authProvider.user?.email ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Se enviará un correo para restablecer tu contraseña.'),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa tu correo electrónico')), 
                );
                return;
              }

              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);

              authProvider.clearError();
              final success = await authProvider.resetPassword(email);
              final errorText = authProvider.errorMessage;

              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Se envió el correo para restablecer contraseña. Revisa tu bandeja de entrada y spam.'
                        : (errorText ?? 'No se pudo enviar el correo. Intenta más tarde.'),
                  ),
                ),
              );
            },
            child: const Text('Enviar correo'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.amber[700]),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12, 
              color: isDark ? Colors.white70 : Colors.black54
            ),
          ),
        ],
      ),
    );
  }
}