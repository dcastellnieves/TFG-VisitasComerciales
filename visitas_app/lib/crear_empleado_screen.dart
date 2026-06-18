// Admin: Pantalla para crear un empleado 

import 'package:flutter/material.dart';
import 'api_service.dart';

class CrearEmpleadoScreen extends StatefulWidget {
  @override
  State<CrearEmpleadoScreen> createState() => _CrearEmpleadoScreenState();
}

class _CrearEmpleadoScreenState extends State<CrearEmpleadoScreen> {

  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String rolSeleccionado = "comercial";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f8ff),

      appBar: AppBar(
        title: const Text("Nuevo empleado"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            _inputCard("Nombre", nombreCtrl, Icons.person),
            const SizedBox(height: 10),

            _inputCard("Email", emailCtrl, Icons.email),
            const SizedBox(height: 10),

            _inputCard("Teléfono", telefonoCtrl, Icons.phone),
            const SizedBox(height: 10),

            _inputCard("Contraseña", passCtrl, Icons.lock, obscure: true),
            const SizedBox(height: 10),

            //  ROL desplegable
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  )
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: rolSeleccionado,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.badge, color: Colors.blueAccent),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "admin",
                    child: Text("Admin"),
                  ),
                  DropdownMenuItem(
                    value: "comercial",
                    child: Text("Comercial"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    rolSeleccionado = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            // GUARDAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {

                  if (nombreCtrl.text.isEmpty ||
                      emailCtrl.text.isEmpty ||
                      passCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Completa todos los campos"),
                      ),
                    );
                    return;
                  }

                  await ApiService.crearEmpleado(
                    nombreCtrl.text,
                    emailCtrl.text,
                    telefonoCtrl.text,
                    passCtrl.text,
                    rolSeleccionado,
                  );

                  Navigator.pop(context);
                },
                child: const Text("Crear empleado"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputCard(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}