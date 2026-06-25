// clientes_screen.dart
// Pantalla de gestión de clientes para el administrador.
// Lista todos los clientes del sistema y permite crear nuevos, editar los
// existentes e importar un listado en bloque desde un archivo CSV.
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'crear_cliente_screen.dart';
import 'editar_clientes_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';

class ClientesScreen extends StatefulWidget {
  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {

  // Lista de clientes cargada desde el backend
  List clientes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  /// Carga el listado de clientes desde la API y actualiza el estado.
  Future<void> cargar() async {
    final data = await ApiService.getClientes();
    setState(() {
      clientes = data;
      loading = false;
    });
  }

  /// Abre el selector de archivos, parsea el CSV seleccionado y envía
  /// los clientes al backend para su importación masiva.
  Future<void> importarCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null) return;

      final bytes = result.files.single.bytes;
      if (bytes == null) return;

      // normalizar texto
      final text = utf8
          .decode(bytes)
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n');

      // dividir en líneas reales
      final lines = text
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();

      List<Map<String, dynamic>> clientes = [];

      for (final line in lines) {
        // parsea csv  con comillas
        List<String> fields = [];
        StringBuffer current = StringBuffer();
        bool inQuotes = false;

        for (int i = 0; i < line.length; i++) {
          final char = line[i];

          if (char == '"') {
            inQuotes = !inQuotes;
          } else if (char == ',' && !inQuotes) {
            fields.add(current.toString().trim());
            current.clear();
          } else {
            current.write(char);
          }
        }

        fields.add(current.toString().trim());

        if (fields.length < 3) continue;

        clientes.add({
          "nombre": fields[0],
          "email": fields[1],
          "telefono": fields[2],
          "direccion": fields.length > 3 ? fields[3] : null,
        });
      }

      final res = await ApiService.importarClientes(clientes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Importados ${res['insertados']} clientes"),
        ),
      );

      await cargar();

    } catch (e) {
      print("Error CSV: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error importando CSV")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xfff5f8ff),

      appBar: AppBar(
        title: const Text("Clientes"),
        backgroundColor: Colors.transparent,
        elevation: 0,

        actions: [
          IconButton(
            icon: Icon(Icons.upload_file, color: Colors.blue.shade300),
            onPressed: importarCSV,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : clientes.isEmpty
              ? const Center(child: Text("No hay clientes"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: clientes.length,
                  itemBuilder: (context, i) {

                    final c = clientes[i];

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),

                      onTap: () async {
                        final res = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditarClienteScreen(cliente: c),
                          ),
                        );

                        if (res == true) {
                          cargar(); // refresh
                        }
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black12,
                            )
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // NOMBRE
                            Text(
                              c['nombre'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            //  DIRECCIÓN
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 18,
                                    color: Colors.blue),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    c['direccion'] ?? '',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            //  TELÉFONO
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    size: 18,
                                    color: Colors.blue),
                                const SizedBox(width: 6),
                                Text(c['telefono'] ?? ''),
                              ],
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ),

      //  BOTÓN FLOTANTE de mas
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade300,
        onPressed: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CrearClienteScreen()),
          );

          if (res == true) {
            cargar(); //  refresc
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}