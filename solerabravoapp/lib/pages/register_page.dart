import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _registerAsPremium = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.amber[700],
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crear cuenta',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                    color: Colors.amber[700]?.withOpacity(0.08),
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
                    color: Colors.amber[700]?.withOpacity(0.05),
                  ),
                ),
              ),
              // Contenido principal
              SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Únete a Solera Bravo',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Nombre completo
                        _buildTextField(
                          controller: _fullNameController,
                          hintText: 'Nombre completo',
                          icon: Icons.person_outlined,
                          enabled: !authProvider.isLoading,
                        ),
                        const SizedBox(height: 16),
                        // Email
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Correo electrónico',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !authProvider.isLoading,
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'Mínimo 6 caracteres',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Confirmar contraseña
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirmar contraseña',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          enabled: !authProvider.isLoading,
                          onVisibilityToggle: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        // Opción Premium - Tarjeta elegante
                        _buildPremiumCard(),
                        const SizedBox(height: 20),
                        // Aceptar términos - Mejorado
                        _buildTermsCheckbox(),
                        const SizedBox(height: 8),
                        // Mensaje de error
                        if (authProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[900]?.withOpacity(0.3),
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
                        const SizedBox(height: 28),
                        // Botón registrarse
                        ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () => _handleRegister(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.amber[700],
                            disabledBackgroundColor:
                                Colors.amber[700]?.withOpacity(0.5),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.amber[100]!,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Crear cuenta',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        // Volver a login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes cuenta? ',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Inicia sesión aquí',
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
                      ],
                    ),
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
                  (obscureText && hintText.contains('Confirmar'))
                      ? (_obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined)
                      : (_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                  color: Colors.amber[700],
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
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

  Widget _buildPremiumCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber[700]!.withOpacity(0.15),
            Colors.amber[600]!.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber[700]!.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: context.read<AuthProvider>().isLoading
              ? null
              : () {
                  setState(() {
                    _registerAsPremium = !_registerAsPremium;
                  });
                },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber[700]!,
                      width: 2,
                    ),
                    color: _registerAsPremium
                        ? Colors.amber[700]
                        : Colors.transparent,
                  ),
                  child: _registerAsPremium
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber[600],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cuenta Premium',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Acceso a todas las funciones avanzadas',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _acceptTerms,
            onChanged: context.read<AuthProvider>().isLoading
                ? null
                : (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
            activeColor: Colors.amber[700],
            side: BorderSide(
              color: Colors.amber[700]!,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lee los términos y condiciones',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.amber[700],
                  ),
                );
              },
              child: RichText(
                text: TextSpan(
                  text: 'Acepto los ',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[300],
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'términos y condiciones',
                      style: GoogleFonts.poppins(
                        color: Colors.amber[600],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegister(BuildContext context) async {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Validaciones
    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorSnackBar(
        context,
        'Por favor completa todos los campos',
      );
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar(
        context,
        'La contraseña debe tener al menos 6 caracteres',
      );
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar(
        context,
        'Las contraseñas no coinciden',
      );
      return;
    }

    if (!_acceptTerms) {
      _showErrorSnackBar(
        context,
        'Debes aceptar los términos y condiciones',
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    bool success = await authProvider.register(
      email: email,
      password: password,
      fullName: fullName,
      isPremium: _registerAsPremium,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Cuenta creada exitosamente!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green[700],
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red[800],
      ),
    );
  }
}
