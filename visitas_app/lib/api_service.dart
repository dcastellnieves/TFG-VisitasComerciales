// api_service.dart
// Capa de acceso a la API REST del backend.
// Centraliza todas las llamadas HTTP, la gestión del token JWT y la
// resolución de la URL base según el entorno de ejecución (web, emulador,
// dispositivo físico). Todos los métodos son estáticos.
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

  // ── CLIENTES ─────────────────────────────────────────────────────

  /// Obtiene el listado completo de clientes del sistema.
  static Future<List<dynamic>> getClientes() async {
    final res = await http.get(
      Uri.parse("$baseUrl/clientes"),
      headers: headers,
    );

    if (res.statusCode == 200) return jsonDecode(res.body);

    throw Exception("Error clientes");
  }

  // ── VISITAS ──────────────────────────────────────────────────────

  /// Obtiene el historial de visitas de un empleado por su id.
  static Future<List<dynamic>> getVisitas(int usuarioId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/visitas/$usuarioId"),
      headers: headers,
    );

    if (res.statusCode == 200) return jsonDecode(res.body);

    throw Exception("Error visitas");
  }

  /// Obtiene las visitas registradas hoy para el empleado indicado.
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

  /// Inicia una visita enviando el id de usuario, cliente y coordenadas GPS de inicio.
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

  /// Finaliza la visita activa del empleado sin coordenadas de fin.
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

  /// Finaliza la visita activa del empleado con coordenadas GPS de fin y notas.
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

  /// Comprueba si el empleado tiene alguna visita en estado 'en_curso'.
  static Future<bool> hayVisitaActiva(int usuarioId) async {
    final visitas = await getVisitas(usuarioId);
    return visitas.any((v) => v["estado"] == "en_curso");
  }

  /// Actualiza las notas de una visita identificada por su id.
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

  // ── USUARIO ──────────────────────────────────────────────────────

  /// Obtiene los datos de perfil del usuario autenticado.
  static Future<Map<String, dynamic>> getUser(int id) async {
    final res = await http.get(
      Uri.parse("$baseUrl/usuario/$id"),
      headers: headers,
    );

    if (res.statusCode == 200) return jsonDecode(res.body);

    throw Exception("Error usuario");
  }

  /// Actualiza el teléfono del usuario y, opcionalmente, su contraseña.
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

  // ── ADMIN ────────────────────────────────────────────────────────

  /// Obtiene las métricas y KPIs globales del sistema (solo admin).
  static Future<Map<String, dynamic>> getEstadisticasAdmin() async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/estadisticas"),
      headers: headers,
    );

    return jsonDecode(res.body);
  }

  /// Crea un nuevo empleado con los datos y rol indicados (solo admin).
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

  /// Actualiza los datos de un empleado existente (solo admin).
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

  /// Crea un nuevo cliente con sus datos y coordenadas geográficas (solo admin).
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

  /// Importa un listado de clientes en bloque (solo admin).
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

  /// Actualiza los datos de un cliente existente (solo admin).
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

  /// Elimina una visita por su id (solo admin).
  static Future eliminarVisita(int id) async {
    await http.delete(
      Uri.parse("$baseUrl/admin/visitas/$id"),
      headers: headers,
    );
  }

  /// Obtiene el listado completo de empleados del sistema (solo admin).
  static Future<List> getEmpleados() async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/listaEmpleados"),
      headers: headers,
    );

    return jsonDecode(res.body);
  }


  // ── ASIGNACIONES ─────────────────────────────────────────────────

  /// Formatea una fecha como cadena 'yyyy-MM-dd' para las queries de la API.
  static String formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  /// Obtiene los clientes asignados a un empleado concreto.
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

  /// Crea asignaciones entre el empleado y la lista de clientes indicada (solo admin).
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

  /// Elimina la asignación entre un empleado y un cliente (solo admin).
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

  /// Consulta visitas con filtros opcionales de empleado, cliente y fecha (solo admin).
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

  /// Obtiene las visitas asociadas a un cliente concreto filtrando en cliente.
  static Future<List> getVisitasCliente(int clienteId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/visitas"),
      headers: headers,
    );

    final data = jsonDecode(res.body);
    return data.where((v) => v['cliente_id'] == clienteId).toList();
  }

}