import 'dart:convert'; // Libreria para convertir datos JSON
import 'package:http/http.dart' as http; // Libreria HTTP para hacer peticiones

class AuthService {
  // Clase para manejar la autenticación

  static const String baseUrl =
      'https://hpj1hbd6-3000.usw3.devtunnels.ms/api/auth'; // La IP red local

  static Future<Map<String, dynamic>> registerUser({
    // Método estático para registrar usuario
    required String fullName,
    required String email,
    required String password,
    String? phone, // Parámetro opcional para el teléfono
  }) async {
    // Método asíncrono
    try {
      // Manejo de errores
      final response = await http.post(
        // Hace petición POST
        Uri.parse('$baseUrl/register'), // Construye URL completa
        headers: {
          // Headers de la petición
          'Content-Type': 'application/json', // Indica que envía JSON
        },
        body: json.encode({
          // Convierte datos a JSON
          'fullName': fullName,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(
        response.body,
      ); // Decodifica respuesta

      if (response.statusCode == 201) {
        // Si el registro fue exitoso (201 Created)
        return {
          'success': true,
          'message': responseData['message'], // Mensaje del servidor
          'token': responseData['token'], // Token de autenticación
          'user': responseData['user'], // Datos del usuario
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ??
                  'Error en el registro', // Mensaje de error
        };
      }
    } catch (error) {
      // Si hay error de conexión
      return {
        // Retorna error de conexión
        'success': false,
        'message': 'Error de conexión: $error',
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Login exitoso 200
        return {
          'success': true,
          'message': responseData['message'],
          'token': responseData['token'],
          'user': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el login',
        };
      }
    } catch (error) {
      return {'success': false, 'message': 'Error de conexión: $error'};
    }
  }

  // Método adicional para actualizar perfil del usuario
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'fullName': fullName,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'user': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al actualizar perfil',
        };
      }
    } catch (error) {
      return {'success': false, 'message': 'Error de conexión: $error'};
    }
  }
}