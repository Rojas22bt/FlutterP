import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const _baseUrl = 'https://web-production-ab6a3.up.railway.app/api';

  static Future<Map<String, dynamic>?> login(
    String correo,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/usuario/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Devuelve el usuario
    } else {
      return null;
    }
  }

  static Future<bool> register(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/usuario/registro');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    return response.statusCode == 201;
  }

  static Future<List<dynamic>> obtenerProductosActivos() async {
    final url = Uri.parse('$_baseUrl/inventario/obtener-productos-activos');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener productos activos');
    }
  }

  static Future<http.Response> crearFacturacionRequest(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl/venta/factura');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return response;
  }
}
