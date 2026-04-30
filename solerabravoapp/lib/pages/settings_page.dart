import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // Detectamos si el modo oscuro está activo para pintar la pantalla de un color u otro
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Ya no forzamos el color claro, usamos el que toque según el tema
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A), // La barra superior siempre la mantenemos oscura por diseño
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ajustes',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                // APARIENCIA
                _buildSectionHeader('Apariencia', isDark),
                _buildSettingCard(
                  icon: Icons.brightness_4,
                  title: 'Modo oscuro',
                  description: 'Cambia la apariencia de la aplicación',
                  trailing: Switch(
                    value: settingsProvider.darkMode,
                    onChanged: (value) {
                      settingsProvider.toggleDarkMode();
                    },
                    activeColor: Colors.amber[700],
                  ),
                  isDark: isDark,
                ),

                // NOTIFICACIONES
                _buildSectionHeader('Notificaciones', isDark),
                _buildSettingCard(
                  icon: Icons.notifications,
                  title: 'Notificaciones',
                  description: settingsProvider.notificationsEnabled
                      ? 'Notificaciones activadas'
                      : 'Notificaciones desactivadas',
                  trailing: Switch(
                    value: settingsProvider.notificationsEnabled,
                    onChanged: (value) {
                      settingsProvider.toggleNotifications();
                    },
                    activeColor: Colors.amber[700],
                  ),
                  isDark: isDark,
                ),
                if (settingsProvider.notificationsEnabled)
                  _buildSettingCard(
                    icon: Icons.volume_up,
                    title: 'Sonido de notificaciones',
                    description:
                        settingsProvider.notificationSound ? 'Activado' : 'Desactivado',
                    trailing: Switch(
                      value: settingsProvider.notificationSound,
                      onChanged: (value) {
                        settingsProvider.toggleNotificationSound();
                      },
                      activeColor: Colors.amber[700],
                    ),
                    isDark: isDark,
                  ),

                // IDIOMA
                // _buildSectionHeader('Idioma', isDark),
                // _buildLanguageSelector(settingsProvider, isDark),

                // PRIVACIDAD Y DATOS
                _buildSectionHeader('Privacidad y datos', isDark),
                _buildSettingCard(
                  icon: Icons.lock_outline,
                  title: 'Datos de análisis',
                  description: 'Ayuda a mejorar la app compartiendo datos anónimos',
                  trailing: Switch(
                    value: settingsProvider.analyticsEnabled,
                    onChanged: (value) {
                      settingsProvider.toggleAnalytics();
                    },
                    activeColor: Colors.amber[700],
                  ),
                  isDark: isDark,
                ),
                _buildClickableSettingCard(
                  icon: Icons.delete_outline,
                  title: 'Borrar datos en caché',
                  description: 'Libera espacio eliminando datos temporales',
                  onTap: () => _showClearCacheDialog(context, isDark),
                  isDark: isDark,
                ),

                // INFORMACIÓN
                _buildSectionHeader('Información', isDark),
                _buildClickableSettingCard(
                  icon: Icons.info_outline,
                  title: 'Acerca de la app',
                  description: 'Ver versión y detalles',
                  onTap: () => _showAboutDialog(context, isDark),
                  isDark: isDark,
                ),
                _buildClickableSettingCard(
                  icon: Icons.help_outline,
                  title: 'Ayuda y soporte',
                  description: 'Contacta con nuestro equipo',
                  onTap: () => _showHelpDialog(context, isDark),
                  isDark: isDark,
                ),
                _buildClickableSettingCard(
                  icon: Icons.description_outlined,
                  title: 'Términos y condiciones',
                  description: 'Lee nuestros términos',
                  onTap: () => _showTermsDialog(context, isDark),
                  isDark: isDark,
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54, // Color de texto dinámico
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String description,
    required Widget trailing,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white, // Fondo de tarjeta dinámico
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildClickableSettingCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber[700], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }

  // Widget _buildLanguageSelector(SettingsProvider settingsProvider, bool isDark) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Icons.language, color: Colors.amber[700], size: 24),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Idioma',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                   color: isDark ? Colors.white : Colors.black87,
  //                 ),
  //               ),
  //               const SizedBox(height: 2),
  //               Text(
  //                 'Selecciona tu idioma preferido',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 12,
  //                   color: isDark ? Colors.white54 : Colors.black54,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         DropdownButton<String>(
  //           value: settingsProvider.language,
  //           dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
  //           onChanged: (newValue) {
  //             if (newValue != null) {
  //               settingsProvider.setLanguage(newValue);
  //             }
  //           },
  //           items: [
  //             DropdownMenuItem(
  //               value: 'es',
  //               child: Text(
  //                 'Español',
  //                 style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87),
  //               ),
  //             ),
  //             DropdownMenuItem(
  //               value: 'en',
  //               child: Text(
  //                 'English',
  //                 style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87),
  //               ),
  //             ),
  //           ],
  //           underline: const SizedBox(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showClearCacheDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text(
          'Borrar datos en caché',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          '¿Deseas borrar los datos temporales? Esto liberará aproximadamente 50 MB de espacio.',
          style: GoogleFonts.poppins(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: isDark ? Colors.amber[300] : Colors.amber[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<SettingsProvider>(context, listen: false).clearCache();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Datos en caché eliminados',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
            ),
            child: Text(
              'Borrar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text(
          'Acerca de Solera Bravo App',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Versión: 1.0.0',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Desarrollado por: Solera Bravo Team',
                style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Una aplicación esencial para análisis avanzados y gestión inteligente de datos.',
                style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
            ),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text(
          'Ayuda y Soporte',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem('Email:', 'soporte@solerabravo.com', isDark),
              _buildHelpItem('Página web:', 'www.solerabravo.com', isDark),
              _buildHelpItem('Teléfono:', '+34 XXX XXX XXX', isDark),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
            ),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text(
          'Términos y Condiciones',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Al usar esta aplicación, aceptas nuestros términos y condiciones:\n\n'
            '1. Uso responsable: La información es solo para propósitos educativos y de análisis.\n\n'
            '2. Privacidad: Tus datos se mantienen confidenciales.\n\n'
            '3. Propiedad intelectual: Todo el contenido está protegido.\n\n'
            '4. Limitación de responsabilidad: La aplicación se proporciona "tal cual".\n\n'
            '5. Cambios: Podemos actualizar estos términos en cualquier momento.',
            style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
            ),
            child: Text(
              'Entendido',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.blue[300] : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}