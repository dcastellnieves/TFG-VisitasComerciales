//Admin: pantalla para editar datos de clientes quitar lat y lon
import 'package:flutter/material.dart';
import 'api_service.dart';

class EditarClienteScreen extends StatefulWidget {
  final Map cliente;

  EditarClienteScreen({required this.cliente});

  @override
  State<EditarClienteScreen> createState() => _EditarClienteScreenState();
}

class _EditarClienteScreenState extends State<EditarClienteScreen> {

  late TextEditingController nombre;
  late TextEditingController email;
  late TextEditingController direccion;
  late TextEditingController telefono;
  late TextEditingController latitud;
  late TextEditingController longitud;

  @override
  void initState() {
    super.initState();

    nombre = TextEditingController(text: widget.cliente['nombre'] ?? "");
    email = TextEditingController(text: widget.cliente['email'] ?? "");
    direccion = TextEditingController(text: widget.cliente['direccion'] ?? "");
    telefono = TextEditingController(text: widget.cliente['telefono'] ?? "");
    latitud = TextEditingController(
        text: widget.cliente['latitud']?.toString() ?? "");
    longitud = TextEditingController(
        text: widget.cliente['longitud']?.toString() ?? "");
  }

  Future<void> guardar() async {

    await ApiService.actualizarCliente(
      widget.cliente['id'],
      nombre.text,
      email.text,
      direccion.text,
      telefono.text,
      latitud.text,
      longitud.text,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Editar cliente")),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nombre,
              decoration: InputDecoration(labelText: "Nombre"),
            ),

            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: direccion,
              decoration: InputDecoration(labelText: "Dirección"),
            ),

            TextField(
              controller: telefono,
              decoration: InputDecoration(labelText: "Teléfono"),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: latitud,
              decoration: InputDecoration(labelText: "Latitud"),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: longitud,
              decoration: InputDecoration(labelText: "Longitud"),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: guardar,
                child: Text("Guardar cambios"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}