// Admin: pantalla de gestión de empleados
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'crear_empleado_screen.dart';
import 'editar_empleados_screen.dart';

class EmpleadosScreen extends StatefulWidget {
  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {

  List empleados = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    try {
      final data = await ApiService.getEmpleados();

      setState(() {
        empleados = data;
        loading = false;
      });

    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xfff5f8ff),

      appBar: AppBar(
        title: Text("Empleados"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade300,
        child: Icon(Icons.add),
        onPressed: () async {

          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CrearEmpleadoScreen()),
          );

          if (refresh == true) cargar();
        },
      ),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : empleados.isEmpty
              ? Center(child: Text("No hay empleados"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: empleados.length,
                  itemBuilder: (context, i) {

                    final e = empleados[i];
                    final activo = e['activo'] == true || e['activo'] == 1;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),

                      onTap: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditarEmpleadoScreen(
                              empleado: e,
                            ),
                          ),
                        );

                        if (res == true) {
                          cargar();
                        }
                      },

                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black12,
                            )
                          ],
                        ),

                        child: Row(
                          children: [

                            CircleAvatar(
                              backgroundColor: Colors.blue.shade200,
                              child: Text(
                                e['nombre_completo'] != null
                                    ? e['nombre_completo'][0].toUpperCase()
                                    : "?",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    e['nombre_completo'] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    e['email'] ?? "",
                                    style: TextStyle(color: Colors.grey),
                                  ),

                                  SizedBox(height: 5),

                                  Row(
                                    children: [
                                      Icon(
                                        activo
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 16,
                                        color: activo
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        activo ? "Activo" : "Inactivo",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                e['rol'] ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}