// pantalla de mi perfil
import 'package:flutter/material.dart';
import 'api_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  ProfileScreen({required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final telefonoCtrl = TextEditingController();
  final passActualCtrl = TextEditingController();
  final passNuevaCtrl = TextEditingController();
  final passConfirmCtrl = TextEditingController();

  String? msg;

  @override
  void initState() {
    super.initState();
    telefonoCtrl.text = widget.user['telefono'] ?? '';
  }

  @override
  Widget build(BuildContext context) {

    final activo = widget.user['activo'] == true || widget.user['activo'] == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text("Mi perfil"),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () async {

                if (passNuevaCtrl.text != passConfirmCtrl.text) {
                  setState(() => msg = "Las contraseñas no coinciden");
                  return;
                }

                try {
                  await ApiService.updateUser(
                    widget.user['id'],
                    telefonoCtrl.text,
                    passActualCtrl.text.isEmpty ? null : passActualCtrl.text,
                    passNuevaCtrl.text.isEmpty ? null : passNuevaCtrl.text,
                  );

                  setState(() => msg = "Perfil actualizado correctamente");

                } catch (e) {
                  setState(() => msg = e.toString());
                }
              },
              child: Text("Guardar cambios"),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            children: [

              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [

                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blue.shade200,
                        child: Text(
                          widget.user['nombre'] != null
                              ? widget.user['nombre'][0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        widget.user['nombre'] ?? "",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        widget.user['email'] ?? "",
                        style: TextStyle(color: Colors.grey),
                      ),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            activo ? Icons.check_circle : Icons.cancel,
                            color: activo ? Colors.blue : Colors.grey,
                          ),
                          SizedBox(width: 5),
                          Text(
                            activo ? "Activo" : "Inactivo",
                            style: TextStyle(
                              color: activo ? Colors.blue : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              _input("Teléfono", telefonoCtrl, Icons.phone),

              SizedBox(height: 10),

              _input("Contraseña actual", passActualCtrl, Icons.lock_outline, obscure: true),

              SizedBox(height: 10),

              _input("Nueva contraseña", passNuevaCtrl, Icons.lock, obscure: true),

              SizedBox(height: 10),

              _input("Confirmar contraseña", passConfirmCtrl, Icons.lock_reset, obscure: true),

              SizedBox(height: 20),

              if (msg != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: msg!.contains("correctamente")
                        ? Colors.blue.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(msg!),
                ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.blueAccent),
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}