import 'package:flutter/material.dart';
import 'package:transportes_locales/widgets/mapspage.dart';
import 'package:transportes_locales/widgets/registerpage.dart';
import 'package:transportes_locales/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  // Cambié a StatefulWidget
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Para controlar el estado de carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Imagen de encabezado
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: const Color.fromARGB(255, 245, 245, 245),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      "https://img3.pillowfort.social/posts/44a1658f1e2f47597c2a.gif",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Título
                const Text(
                  "Iniciar Sesión",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtítulo
                const Text(
                  "Ingresa a tu cuenta",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),

                const SizedBox(height: 40),

                // Campo correo
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController, // Agregado controller
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Correo Electrónico",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                
                Container( // Campo contraseña
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController, // Agregado controller
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Contraseña",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                
                SizedBox( // Botón de inicio de sesión
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            
                            _loginUser(context);  // Deshabilitar cuando carga
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "Iniciar sesión",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                
                Row( // Enlace para el registro
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿No tienes una cuenta?",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isLoading
                          ? null // Deshabilitar cuando carga
                          : () {
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                      child: const Text(
                        "Regístrate",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginUser(BuildContext context) async {
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) { // Validaciones básicas
      _showMessage('Por favor completa todos los campos', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      
      final result = await AuthService.loginUser( // Llamar al servicio de login
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        
        _showMessage('¡Bienvenido!', Colors.black87); // Login exitoso

        
        await Future.delayed(const Duration(milliseconds: 1500)); // Navegar a MapsPage después del delay

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapsPage()),
          );
        }
      } else {
        
        _showMessage(
          result['message'] ?? 'Error en el inicio de sesión',  // Error en el login
          Colors.red,
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error de conexión: $error', Colors.red);
    }
  }

  void _showMessage(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    
    _emailController.dispose();  // Limpiar los controladores
    _passwordController.dispose();
    super.dispose();
  }
}
