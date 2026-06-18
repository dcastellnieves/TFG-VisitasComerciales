// Admin: pantalla para asignar clientes a empleados
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'seleccionar_clientes_screen.dart';

class AsignacionesScreen extends StatefulWidget {
  @override
  State<AsignacionesScreen> createState() => _AsignacionesScreenState();
}

class _AsignacionesScreenState extends State<AsignacionesScreen> {

  List empleados = [];
  int? empleadoId;

  List clientesSeleccionados = [];
  List clientesExistentes = [];

  // estado de visitas por cliente
  Map<int, String> estadoVisitas = {};

  @override
  void initState() {
    super.initState();
    cargarEmpleados();
  }

  void cargarEmpleados() async {
    final data = await ApiService.getEmpleados();
    setState(() => empleados = data);
  }

  // CARGAR ASIGNACIONES + VISITAS
  Future<void> cargarAsignaciones() async {
    if (empleadoId == null) return;

    final data = await ApiService.getClientesPorUsuario(empleadoId!);
    final visitas = await ApiService.getVisitasHoy(empleadoId!);

    Map<int, String> estado = {};

    for (var v in visitas) {
      final clienteId = int.tryParse(v['cliente_id'].toString()) ?? 0;
      estado[clienteId] = v['estado'];
    }

    setState(() {
      clientesSeleccionados = List<Map<String, dynamic>>.from(data);
      clientesExistentes = List<Map<String, dynamic>>.from(data);
      estadoVisitas = estado;
    });
  }

  //SELECCIONAR CLIENTES

  Future<void> seleccionarClientes() async {
    final seleccion = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SeleccionarClientesScreen()),
    );

    if (seleccion != null) {
      final nuevos = List<Map<String, dynamic>>.from(seleccion);

      setState(() {
        clientesSeleccionados = [
          ...clientesSeleccionados,
          ...nuevos.where((n) =>
              !clientesSeleccionados.any((e) => e['id'] == n['id']))
        ];
      });
    }
  }

  Future<void> guardar() async {
    if (empleadoId == null) return;

    try {
      final idsNuevos = clientesSeleccionados
        .map((c) => c['id'])
        .where((id) => id != null)
        .toList();

      final idsOriginales = clientesExistentes
        .map((c) => c['id'])
        .where((id) => id != null)
        .toList();

      final nuevos = idsNuevos.where((id) => !idsOriginales.contains(id)).toList();

      final eliminados = idsOriginales.where((id) => !idsNuevos.contains(id)).toList();

      // INSERT
      if (nuevos.isNotEmpty) {
        await ApiService.crearAsignaciones(empleadoId!, nuevos);
      }

      // DELETE
      for (final id in eliminados) {
        await ApiService.eliminarAsignacion(empleadoId!, id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Asignaciones actualizadas")),
      );

      Navigator.pop(context);

    } catch (e) {
      print("ERROR GUARDAR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error guardando asignaciones")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text("Asignar clientes")),

      floatingActionButton: FloatingActionButton(
        onPressed: seleccionarClientes,
        child: Icon(Icons.add),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: guardar,
              child: Text("Guardar asignaciones"),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            // select empleado
            Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: empleadoId,
                  hint: Text("Seleccionar empleado"),
                  items: empleados.map<DropdownMenuItem<int>>((e) {
                    return DropdownMenuItem<int>(
                      value: e['id'],
                      child: Text(
                        (e['nombre_completo'] ?? 'Sin nombre').toString(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      empleadoId = v;
                    });
                    cargarAsignaciones();
                  },
                ),
              ),
            ),

            SizedBox(height: 10),

            // lista clientes
            Expanded(
              child: ListView.builder(
                itemCount: clientesSeleccionados.length,
                itemBuilder: (context, i) {

                  final c = clientesSeleccionados[i];
                  final clienteId = c['id'];

                  Color? color;

                  if (estadoVisitas[clienteId] == 'en_curso') {
                    color = Colors.orange[100];
                  } else if (estadoVisitas[clienteId] == 'finalizada') {
                    color = Colors.green[100];
                  }

                  return Card(
                    color: color,
                    child: ListTile(
                      title: Text(c['nombre'] ?? ''),
                      subtitle: Text(c['direccion'] ?? ''),

                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            clientesSeleccionados.removeAt(i);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}