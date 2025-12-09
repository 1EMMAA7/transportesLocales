import 'package:flutter/material.dart';
import 'package:transportes_locales/services/authservice.dart';
import 'package:transportes_locales/models/usermodel.dart';
import 'package:transportes_locales/widgets/mapspage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  // Paleta de colores fríos
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

  Future<void> _registerUser() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showMessage('Por favor completa todos los campos obligatorios');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Las contraseñas no coinciden');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.registerUser(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        isTerminalAdmin: false, // Siempre false - solo usuarios normales
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        final user = User.fromJson(result['user'] ?? result);
        
        _showSuccessMessage('¡Registro exitoso!');

        await Future.delayed(const Duration(seconds: 2));
        
        if (context.mounted) {
          // Siempre navega a MapsPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MapsPage(user: user),
            ),
          );
        }
      } else {
        _showMessage(result['message'] ?? 'Error en el registro');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _warningColor,
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
    // Determinar si es desktop basado en el ancho de la pantalla
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    
    return Scaffold(
      backgroundColor: _backgroundLight,
      body: SafeArea(
        child: isDesktop ? _buildWebLayout() : _buildMobileLayout(),
      ),
    );
  }

  // ==================== DISEÑO WEB/CHROME ====================
  Widget _buildWebLayout() {
  return Scaffold(
    backgroundColor: _backgroundLight,
    body: Row(
      children: [
        // Panel izquierdo decorativo
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _gradientStart.withOpacity(0.95),
                  _gradientEnd.withOpacity(0.95),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.directions_bus_filled,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    "Transportes Locales",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Panel derecho con formulario
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de regreso (solo ícono)
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: _textPrimary, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Título principal
                  Text(
                    "Crear Cuenta",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Completa tus datos para comenzar",
                    style: TextStyle(
                      fontSize: 16,
                      color: _textSecondary,
                    ),
                  ),
                  
                  SizedBox(height: 50),
                  
                  // Formulario centrado
                  Container(
                    width: 500,
                    child: Column(
                      children: [
                        // Nombre completo
                        _buildSimpleTextField(
                          controller: _fullNameController,
                          hintText: "Nombre completo",
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: 24),
                        
                        // Email
                        _buildSimpleTextField(
                          controller: _emailController,
                          hintText: "Correo electrónico",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 24),
                        
                        // Teléfono
                        _buildSimpleTextField(
                          controller: _phoneController,
                          hintText: "Teléfono (opcional)",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 24),
                        
                        // Contraseña
                        _buildSimpleTextField(
                          controller: _passwordController,
                          hintText: "Contraseña",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        SizedBox(height: 24),
                        
                        // Confirmar contraseña
                        _buildSimpleTextField(
                          controller: _confirmPasswordController,
                          hintText: "Confirmar contraseña",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        
                        SizedBox(height: 40),
                        
                        // Botón de registro
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : Text(
                                    "Crear Cuenta",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        SizedBox(height: 30),
                        
                        // Enlace para iniciar sesión
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "¿Ya tienes cuenta? Inicia sesión",
                            style: TextStyle(
                              color: _primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 40),
                        
                        // Información de seguridad
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.security,
                                color: _accentColor,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Tus datos están protegidos",
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 14,
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
        ),
      ],
    ),
  );
}

// Widget auxiliar para campos de texto simples
Widget _buildSimpleTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  bool isPassword = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Container(
    decoration: BoxDecoration(
      color: _backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _textSecondary.withOpacity(0.1),
      ),
    ),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(
        color: _textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: _textSecondary.withOpacity(0.6),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        prefixIcon: Icon(
          icon,
          color: _secondaryColor,
          size: 22,
        ),
        suffixIcon: isPassword
            ? Icon(
                Icons.visibility_off_outlined,
                color: _textSecondary.withOpacity(0.4),
                size: 20,
              )
            : null,
      ),
    ),
  );
}

  // ==================== DISEÑO MÓVIL ====================
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            height: 200,
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
                          Icons.person_add_alt_1,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Crear Cuenta",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Comienza tu viaje con nosotros",
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
                
                // Información de tipo de cuenta (solo usuario)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: _primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cuenta de Usuario",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Para pasajeros - Acceso completo al mapa de rutas",
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Campos del formulario
                _buildFormSection(),
                
                const SizedBox(height: 32),
                
                // Botón de registro
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
                    onPressed: _isLoading ? null : _registerUser,
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
                              Icon(Icons.person_add, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                "Crear Cuenta",
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
                
                const SizedBox(height: 24),
                
                // Texto informativo
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
                      Icon(Icons.security, color: _accentColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Tus datos están protegidos y encriptados",
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
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Información Personal",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Completa tus datos para continuar",
          style: TextStyle(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        
        _buildTextField(
          controller: _fullNameController,
          hintText: "Nombre completo",
          icon: Icons.person_outline,
          iconColor: _secondaryColor,
        ),
        const SizedBox(height: 20),
        
        _buildTextField(
          controller: _emailController,
          hintText: "Correo electrónico",
          icon: Icons.email_outlined,
          iconColor: _secondaryColor,
          keyboardType: TextInputType.emailAddress,
        ),
        
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          hintText: "Teléfono (opcional)",
          icon: Icons.phone_outlined,
          iconColor: _secondaryColor,
          keyboardType: TextInputType.phone,
        ),
        
        const SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          hintText: "Contraseña",
          icon: Icons.lock_outline,
          iconColor: _secondaryColor,
          isPassword: true,
        ),
        
        const SizedBox(height: 20),
        _buildTextField(
          controller: _confirmPasswordController,
          hintText: "Confirmar contraseña",
          icon: Icons.lock_outline,
          iconColor: _secondaryColor,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _cardColor.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: TextStyle(color: _textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: _textSecondary.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(icon, color: iconColor),
          suffixIcon: isPassword ? Icon(Icons.visibility_off_outlined, color: _textSecondary.withOpacity(0.5)) : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}