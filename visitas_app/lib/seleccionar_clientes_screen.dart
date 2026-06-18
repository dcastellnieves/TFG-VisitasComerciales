//Admin: pantalla para seleccionar clientes al crear asignacion
import 'package:flutter/material.dart';
import 'api_service.dart';

class SeleccionarClientesScreen extends StatefulWidget {
  @override
  State<SeleccionarClientesScreen> createState() => _SeleccionarClientesScreenState();
}

class _SeleccionarClientesScreenState extends State<SeleccionarClientesScreen> {

  List clientes = [];
  Set<int> seleccionados = {};

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  void cargarClientes() async {
    final data = await ApiService.getClientes();
    setState(() => clientes = data);
  }

  void toggle(int id) {
    setState(() {
      if (seleccionados.contains(id)) {
        seleccionados.remove(id);
      } else {
        seleccionados.add(id);
      }
    });
  }

  void confirmar() {
    final seleccion = clientes
        .where((c) => seleccionados.contains(c['id']))
        .toList();

    Navigator.pop(context, seleccion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Seleccionar clientes"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: confirmar,
          )
        ],
      ),

      body: ListView.builder(
        itemCount: clientes.length,
        itemBuilder: (context, i) {

          final c = clientes[i];
          final id = c['id'];

          final seleccionado = seleccionados.contains(id);

          return Card(
            color: seleccionado ? Colors.blue[50] : null,
            child: ListTile(
              leading: Icon(Icons.business),
              title: Text(c['nombre']),
              subtitle: Text(c['direccion'] ?? ''),

              trailing: seleccionado
                  ? Icon(Icons.check_circle, color: Colors.blue)
                  : Icon(Icons.radio_button_unchecked),

              onTap: () => toggle(id),
            ),
          );
        },
      ),
    );
  }
}