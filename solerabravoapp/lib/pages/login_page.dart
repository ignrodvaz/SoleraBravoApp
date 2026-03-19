import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Stack(
            children: [
              // Fondo con decoraciones
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber[700]?.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber[700]?.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Contenido principal
              SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Header
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.amber[700]!,
                                        Colors.amber[600]!,
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.health_and_safety_rounded,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Solera Bravo',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Formulario
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bienvenido',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Accede a tu cuenta',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // Email
                                _buildTextField(
                                  controller: _emailController,
                                  hintText: 'Correo electrónico',
                                  icon: Icons.email_outlined,
                                  enabled: !authProvider.isLoading,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),
                                // Contraseña
                                _buildTextField(
                                  controller: _passwordController,
                                  hintText: 'Contraseña',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  enabled: !authProvider.isLoading,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                // Recuperar contraseña
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        _showForgotPasswordDialog(context),
                                    child: Text(
                                      '¿Olvidaste tu contraseña?',
                                      style: GoogleFonts.poppins(
                                        color: Colors.amber[700],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                // Mensaje de error
                                if (authProvider.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red[900]?.withValues(alpha: 0.3),
                                        border: Border.all(
                                          color: Colors.red[700]!,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: GoogleFonts.poppins(
                                          color: Colors.red[200],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 32),
                                // Botón de inicio de sesión
                                ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => _handleLogin(context),
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Colors.amber[700],
                                    disabledBackgroundColor:
                                        Colors.amber[700]?.withValues(alpha: 0.5),
                                    foregroundColor: Colors.white,
                                    elevation: 8,
                                    shadowColor: Colors.amber[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.amber[100]!,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Iniciar sesión',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 24),
                                // Registrarse
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '¿No tienes cuenta? ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Regístrate aquí',
                                        style: GoogleFonts.poppins(
                                          color: Colors.amber[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Divisor
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[600],
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'o continúa con',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[600],
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Botón Google Sign-In
                                ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => _handleGoogleSignIn(context),
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.white.withValues(alpha: 0.5),
                                    foregroundColor: Colors.black87,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.amber[700]!),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.g_mobiledata,
                                              size: 20,
                                              color: Colors.black87,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Iniciar sesión con Google',
                                              style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey[500],
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.amber[700],
        ),
        suffixIcon: onVisibilityToggle != null
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.amber[700],
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey[600]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey[700]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.amber[700]!,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey[800]!,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa todos los campos',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red[800],
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    bool success = await authProvider.login(
      email: email,
      password: password,
    );
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '¡Bienvenido!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green[700],
        ),
      );
      navigator.pop();
    }
  }

  void _handleGoogleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    try {
      bool success = await authProvider.loginWithGoogle();

      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '¡Bienvenido!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
          ),
        );
        // AuthWrapper will handle navigation automatically
      } else {
        final errorMessage = authProvider.errorMessage ?? 'Error al iniciar sesión con Google';
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Error inesperado: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recuperar contraseña',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ingresa tu correo electrónico para recibir un enlace de recuperación',
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: emailController,
                hintText: 'Correo electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        String email = emailController.text.trim();
                        if (email.isEmpty) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Ingresa tu correo electrónico')),
                          );
                          return;
                        }

                        Navigator.pop(dialogContext);

                        // Limpiar errores previos
                        authProvider.clearError();
                        bool success = await authProvider.resetPassword(email);
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Enviar',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
