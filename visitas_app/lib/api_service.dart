import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // TOKEN JWT
  static String? _token;

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  static Map<String, String> get headers {
    return {
      "Content-Type": "application/json",
      if (_token != null) "Authorization": "Bearer $_token",
    };
  }

  //  URL BASE
  static const String _local = "http://localhost:3000";
  static const String _emulator = "http://10.0.2.2:3000";
  static const String _physicalDevice = "https://palatable-boaster-faculty.ngrok-free.dev";

  static String get baseUrl {
    if (kIsWeb) return _local;
    return _physicalDevice;
  }

  //  LOGIN (JWT)
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      if (data["token"] != null) {
        await saveToken(data["token"]);
      }
      return data;
    }

    throw Exception(data["error"] ?? "Error login");
  }

  // CLIENTES
  static Future<List<dynamic>> getClientes() async {
    final res = await http.get(
      Uri.parse("$baseUrl/clientes"),
      headers: headers,
    );

    if (res.statusCode == 200) return jsonDecode(res.body);

    throw Exception("Error clientes");
  }

  //  VISITAS
  static Future<List<dynamic>> getVisitas(int usuarioId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/visitas/$usuarioId"),
      headers: headers,
    );

    if (res.statusCode == 200) return jsonDecode(res.body);

    throw Exception("Error visitas");
  }

  static Future<List> getVisitasHoy(int usuarioId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/visitas/hoy/$usuarioId"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Error visitas hoy");
  }

  static Future<Map<String, dynamic>> iniciarVisitaConUbicacion(
    int usuarioId,
    int clienteId,
    double lat,
    double lon,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/visitas/iniciar"),
      headers: headers,
      body: jsonEncode({
        "usuario_id": usuarioId,
        "cliente_id": clienteId,
        "lat": lat,
        "lon": lon,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) return data;

    throw Exception(data["error"] ?? "Error iniciar visita");
  }

  static Future<Map<String, dynamic>> finalizarVisita(
    int usuarioId,
    String notas,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/visitas/finalizar"),
      headers: headers,
      body: jsonEncode({
        "usuario_id": usuarioId,
        "notas": notas,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) return data;

    throw Exception(data["error"] ?? "Error finalizar visita");
  }

  static Future<Map<String, dynamic>> finalizarVisitaConUbicacion(
    int usuarioId,
    int clienteId,
    double lat,
    double lon,
    String notas,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/visitas/finalizar"),
      headers: headers,
      body: jsonEncode({
        "usuario_id": usuarioId,
        "cliente_id": clienteId,
        "lat": lat,
        "lon": lon,
        "notas": notas,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) return data;

    throw Exception(data["error"] ?? "Error finalizar visita");
  }

  static Future<bool> hayVisitaActiva(int usuarioId) async {
    final visitas = await getVisitas(usuarioId);
    return visitas.any((v) => v["estado"] == "en_curso");
  }

  static Future<void> actualizarNotas(int visitaId, String notas) async {
    final res = await http.put(
      Uri.parse("$baseUrl/visitas/notas"),
      headers: headers,
      body: jsonEncode({
        "visita_id": visitaId,
        "notas": notas,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Error actualizar notas");
    }
  }

  //  USUARIO
  static Future<Map<String, dynamic>> getUser(int id) async {
    final res = await http.get(
      Uri.parse("$baseUrl/usuario/$id"),
      headers: headers,
    );

    if (res.statusCode == 200) return jsonDecode(res.body);

    throw Exception("Error usuario");
  }

  static Future<void> updateUser(
    int id,
    String telefono,
    String? passActual,
    String? passNueva,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/usuario/$id"),
      headers: headers,
      body: jsonEncode({
        "telefono": telefono,
        "password_actual": passActual,
        "password_nueva": passNueva,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Error actualizar usuario");
    }
  }

  //  ADMIN
  static Future<Map<String, dynamic>> getEstadisticasAdmin() async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/estadisticas"),
      headers: headers,
    );

    return jsonDecode(res.body);
  }

  static Future<void> crearEmpleado(
    String nombre,
    String email,
    String telefono,
    String pass,
    String rol,
  ) async {
    await http.post(
      Uri.parse("$baseUrl/admin/empleados"),
      headers: headers,
      body: jsonEncode({
        "nombre": nombre,
        "email": email,
        "telefono": telefono,
        "password": pass,
        "rol": rol,
      }),
    );
  }

  static Future<Map<String, dynamic>> actualizarEmpleado(
    int id,
    String nombre,
    String email,
    String telefono,
    String rol,
    bool activo,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/admin/empleados/$id"),
      headers: headers,
      body: jsonEncode({
        "nombre_completo": nombre,
        "email": email,
        "telefono": telefono,
        "rol": rol,
        "activo": activo,
      }),
    );

    return jsonDecode(res.body);
  }

  static Future crearCliente(
    String nombre,
    String direccion,
    String telefono,
    String email,
    double latitud,
    double longitud,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/admin/clientes"),
      headers: headers,
      body: jsonEncode({
        "nombre": nombre,
        "direccion": direccion,
        "telefono": telefono,
        "email": email,
        "latitud": latitud,
        "longitud": longitud,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Error cliente");
    }
  }

  static Future importarClientes(List clientes) async {
    final res = await http.post(
      Uri.parse("$baseUrl/admin/clientes/importar"),
      headers: headers,
      body: jsonEncode({
        "clientes": clientes,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Error importando clientes: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  static Future actualizarCliente(
    int id,
    String nombre,
    String email,
    String direccion,
    String telefono,
    String latitud,
    String longitud,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/admin/clientes/$id"),
      headers: headers,
      body: jsonEncode({
        "nombre": nombre,
        "email": email,
        "direccion": direccion,
        "telefono": telefono,
        "latitud": double.tryParse(latitud) ?? 0.0,
        "longitud": double.tryParse(longitud) ?? 0.0,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Error actualizar cliente");
    }
  }

  static Future eliminarVisita(int id) async {
    await http.delete(
      Uri.parse("$baseUrl/admin/visitas/$id"),
      headers: headers,
    );
  }

  static Future<List> getEmpleados() async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/listaEmpleados"),
      headers: headers,
    );

    return jsonDecode(res.body);
  }


  //  ASIGNACIONES
  static String formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  static Future<List> getClientesPorUsuario(int userId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/clientes/$userId"),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw Exception("Error clientes");
    }

    return jsonDecode(res.body);
  }

  static Future crearAsignaciones(int usuarioId, List clientes) async {

    final res = await http.post(
      Uri.parse("$baseUrl/admin/asignaciones"),
      headers: headers,
      body: jsonEncode({
        "usuario_id": usuarioId,
        "clientes": clientes,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Error creando asignaciones: ${res.body}");
    }
  }

  static Future eliminarAsignacion(int userId, int clienteId) async {
    await http.delete(
      Uri.parse("$baseUrl/admin/asignaciones"),
      headers: headers,
      body: jsonEncode({
        "usuario_id": userId,
        "cliente_id": clienteId,
      }),
    );
  }

  static Future<List> getVisitasAdminFiltrado({
    int? usuarioId,
    int? clienteId,
    DateTime? fecha,
  }) async {
    String url = "$baseUrl/admin/visitas-filtrado?";

    if (usuarioId != null) url += "usuario_id=$usuarioId&";
    if (clienteId != null) url += "cliente_id=$clienteId&";
    if (fecha != null) {
      url += "fecha=${formatDate(fecha)}&";
    }

    final res = await http.get(Uri.parse(url), headers: headers);

    return jsonDecode(res.body);
  }

  static Future<List> getVisitasCliente(int clienteId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/visitas"),
      headers: headers,
    );

    final data = jsonDecode(res.body);
    return data.where((v) => v['cliente_id'] == clienteId).toList();
  }

}