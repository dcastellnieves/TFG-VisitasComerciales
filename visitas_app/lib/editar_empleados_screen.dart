//ADMIN: pantalla para editar datos de empleados
import 'package:flutter/material.dart';
import 'api_service.dart';

class EditarEmpleadoScreen extends StatefulWidget {
  final Map empleado;

  EditarEmpleadoScreen({required this.empleado});

  @override
  State<EditarEmpleadoScreen> createState() => _EditarEmpleadoScreenState();
}

class _EditarEmpleadoScreenState extends State<EditarEmpleadoScreen> {

  late TextEditingController nombre;
  late TextEditingController email;
  late TextEditingController telefono;

  String rol = "comercial";
  bool activo = true;

  @override
  void initState() {
    super.initState();

    nombre = TextEditingController(text: widget.empleado['nombre_completo']);
    email = TextEditingController(text: widget.empleado['email']);
    telefono = TextEditingController(text: widget.empleado['telefono']);

    rol = widget.empleado['rol'] ?? "comercial";
    activo = widget.empleado['activo'] == true;
  }

  Future<void> guardar() async {
    await ApiService.actualizarEmpleado(
      widget.empleado['id'],
      nombre.text,
      email.text,
      telefono.text,
      rol,
      activo,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar empleado")),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nombre,
              decoration: InputDecoration(labelText: "Nombre completo"),
            ),

            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: telefono,
              decoration: InputDecoration(labelText: "Teléfono"),
            ),

            SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: rol,
              items: [
                DropdownMenuItem(value: "comercial", child: Text("Comercial")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (v) => setState(() => rol = v!),
              decoration: InputDecoration(labelText: "Rol"),
            ),

            SwitchListTile(
              title: Text("Activo"),
              value: activo,
              onChanged: (v) => setState(() => activo = v),
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