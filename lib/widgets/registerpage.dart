import 'package:flutter/material.dart';
import 'package:transportes_locales/services/auth_service.dart';

class RegisterPage extends StatefulWidget {  // Widget con estado mutable
  const RegisterPage({super.key});     // Constructor con clave opcional

  @override
  State<RegisterPage> createState() => _RegisterPageState();  // Crea el estado
}

class _RegisterPageState extends State<RegisterPage> {
  
  final TextEditingController _nameController = TextEditingController(); // Controladores para los TextField
  final TextEditingController _emailController = TextEditingController(); // Controladores para los TextField
  final TextEditingController _passwordController = TextEditingController(); // Controladores para los TextField
  final TextEditingController _confirmPasswordController = TextEditingController(); // Controladores para los TextField

  bool _isLoading = false;  // Controla si está cargando

  
  Future<void> _registerUser() async { // Función para registrar usuario
    
    if (_nameController.text.isEmpty ||  // Validaciones básicas
        _emailController.text.isEmpty || // Validaciones básicas
        _passwordController.text.isEmpty) { // Validaciones básicas
      _showMessage('Por favor completa todos los campos');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) { // Valida que las contraseñas coincidan
      _showMessage('Las contraseñas no coinciden');
      return;
    }

    if (_passwordController.text.length < 6) { // Valida longitud mínima de contraseña
      _showMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() {
      _isLoading = true; // Activa el estado de carga
    });

    try {
      
      final result = await AuthService.registerUser( // Llamar al servicio de registro
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false; // Desactiva el estado de carga
      });

      if (result['success'] == true) { // Registro exitoso
        // Registro exitoso
        _showSuccessMessage('¡Registro exitoso!');
        
        
        await Future.delayed(const Duration(seconds: 2)); // Esperar un poco y regresar al login
        
        if (context.mounted) {  // Verifica que el widget aún esté en el árbol
          Navigator.pop(context); // Regresa a la pantalla anterior
        }
      } else {
        
        _showMessage(result['message'] ?? 'Error en el registro');  // Error en el registro
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error: $error');
    }
  }

  void _showMessage(String message) { // Muestra mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) { // Muestra mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _isLoading
              ? null // Desactiva el botón mientras carga
              : () {
                  Navigator.pop(context);
                },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Permite scroll si el contenido es grande
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                
                Container(  // Imagen/logo
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: Colors.grey[100],
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
                
                
                const Text( // Título
                  "Crear Cuenta",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                
                const Text( // Subtítulo
                  "Regístrate para comenzar",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                
                Container( // Campo de nombre completo
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Nombre completo",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                
                Container( // Campo de correo
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Correo Electrónico",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                
                Container(  // Campo de contraseña
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Contraseña",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                
                Container(  // Campo de confirmar contraseña
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Confirmar contraseña",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                
                SizedBox( // Botón de registro
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Registrarse",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { // Limpia los controladores para evitar memory leaks
    _nameController.dispose();  
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}