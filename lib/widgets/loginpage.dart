import 'package:flutter/material.dart';
import 'package:transportes_locales/widgets/administratorspage.dart';
import 'package:transportes_locales/widgets/mapspage.dart';
import 'package:transportes_locales/widgets/registerpage.dart';
import 'package:transportes_locales/services/authservice.dart';
import 'package:transportes_locales/models/usermodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Paleta de colores fríos (consistente con RegisterPage)
  final Color _primaryColor = const Color(0xFF2C5F9B); // Azul profundo - Confianza
  final Color _secondaryColor = const Color(0xFF4A90A4); // Azul verdoso - Calma
  final Color _accentColor = const Color(0xFF6BB2B2); // Verde azulado - Equilibrio
  final Color _backgroundLight = const Color(0xFFF8FBFE); // Azul muy claro - Pureza
  final Color _cardColor = const Color(0xFFE3F2FD); // Azul claro - Tranquilidad
  final Color _textPrimary = const Color(0xFF2C3E50); // Azul oscuro - Profesionalismo
  final Color _textSecondary = const Color(0xFF5D6D7E); // Gris azulado - Neutralidad
  final Color _successColor = const Color(0xFF27AE60); // Verde esmeralda - Crecimiento
  final Color _warningColor = const Color(0xFFE74C3C); // Rojo coral - Precaución
  final Color _gradientStart = const Color(0xFF667EEA); // Púrpura azulado
  final Color _gradientEnd = const Color(0xFF764BA2); // Púrpura

  Future<void> _loginUser(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Por favor completa todos los campos', _warningColor);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        final user = User.fromJson(result['user'] ?? result);
        
        _showSuccessMessage('¡Bienvenido ${user.fullName}!');

        await Future.delayed(const Duration(milliseconds: 1500));

        if (context.mounted) {
          if (user.isTerminalAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdministratorsPage(user: user),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MapsPage(user: user),
              ),
            );
          }
        }
      } else {
        _showMessage(
          result['message'] ?? 'Error en el inicio de sesión',
          _warningColor,
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error de conexión: $error', _warningColor);
    }
  }

  void _showMessage(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header con gradiente
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_gradientStart, _gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 20,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                            ),
                            child: Icon(
                              Icons.login_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Bienvenido de Nuevo",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Ingresa a tu cuenta para continuar",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Sección de formulario
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lock_outline, color: _primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Inicio de Sesión",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          _buildTextField(
                            controller: _emailController,
                            hintText: "Correo electrónico",
                            icon: Icons.email_outlined,
                            iconColor: _secondaryColor,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildPasswordField(),
                          
                          const SizedBox(height: 8),
                          
                          // Enlace de recuperación de contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading ? null : () {
                                // TODO: Implementar recuperación de contraseña
                                _showMessage('Función en desarrollo', _primaryColor);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: _primaryColor,
                              ),
                              child: Text(
                                "¿Olvidaste tu contraseña?",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _primaryColor,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Botón de inicio de sesión
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _loginUser(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Iniciar Sesión",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Enlace a registro
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿No tienes una cuenta?",
                            style: TextStyle(
                              fontSize: 15,
                              color: _textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegisterPage(),
                                      ),
                                    );
                                  },
                            child: Text(
                              "Regístrate",
                              style: TextStyle(
                                fontSize: 15,
                                color: _primaryColor,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Texto informativo de seguridad
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _accentColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.security_outlined, color: _accentColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Tu seguridad es nuestra prioridad. Todos los datos están encriptados.",
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _cardColor.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: _textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: _textSecondary.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(icon, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _cardColor.withOpacity(0.5)),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(color: _textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: "Contraseña",
          hintStyle: TextStyle(color: _textSecondary.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(Icons.lock_outline, color: _secondaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _textSecondary.withOpacity(0.5),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}