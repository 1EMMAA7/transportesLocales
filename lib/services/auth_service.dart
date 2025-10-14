import 'dart:convert'; //Libreria para convertir datos JSON
import 'package:http/http.dart' as http; //Libreria HTTP para hacer peticiones

class AuthService {
  //Clase para manejar la autentifcacion

  static const String baseUrl =
      'http://192.168.1.75:3000/api/auth'; //La IP red local

  static Future<Map<String, dynamic>> registerUser({
    // Método estático para registrar usuario
    required String name,
    required String email,
    required String password,
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
          'name': name,
          'email': email,
          'password': password,
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
}
