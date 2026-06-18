// Admin: pantalla para crear nuevo cliente cambiar direccion
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'map_select_screen.dart';

class CrearClienteScreen extends StatefulWidget {
  @override
  State<CrearClienteScreen> createState() => _CrearClienteScreenState();
}

class _CrearClienteScreenState extends State<CrearClienteScreen> {

  final nombreCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  String? msg;

  double? latitud;
  double? longitud;

  Future<String> obtenerDireccion(double lat, double lon) async {

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json"
      "?latlng=$lat,$lon&key=AIzaSyBwQtvSmC6mfFKdsSerP4ERz4DY1rBMsHY"
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return "Dirección no disponible";
    }

    final data = jsonDecode(response.body);

    if (data["results"] == null || data["results"].isEmpty) {
      return "Dirección no encontrada";
    }

    return data["results"][0]["formatted_address"];
  }

  Future<void> seleccionarEnMapa() async {
    final pos = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapSelectScreen()),
    );

    if (pos == null) return;

    final direccion = await obtenerDireccion(
      pos.latitude,
      pos.longitude,
    );

    setState(() {
      direccionCtrl.text = direccion;

      //  GUARDAMOS COORDENADAS
      latitud = pos.latitude;
      longitud = pos.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nuevo cliente")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            _input("Nombre", nombreCtrl, Icons.person),
            SizedBox(height: 10),

            //  DIRECCIÓN
            _input("Dirección", direccionCtrl, Icons.location_on),

            SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: seleccionarEnMapa,
                icon: Icon(Icons.map),
                label: Text("Seleccionar en mapa"),
              ),
            ),

            SizedBox(height: 10),

            _input("Teléfono", telefonoCtrl, Icons.phone),
            SizedBox(height: 10),

            _input("Email", emailCtrl, Icons.email),

            SizedBox(height: 20),

            if (msg != null)
              Text(msg!, style: TextStyle(color: Colors.red)),

            SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {

                    if (latitud == null || longitud == null) {
                      setState(() {
                        msg = "Debes seleccionar una ubicación en el mapa";
                      });
                      return;
                    }

                    await ApiService.crearCliente(
                      nombreCtrl.text,
                      direccionCtrl.text,
                      telefonoCtrl.text,
                      emailCtrl.text,
                      latitud!,     
                      longitud!,    
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Cliente creado")),
                    );

                    Navigator.pop(context, true);

                  } catch (e) {
                    setState(() => msg = "Error al crear cliente");
                  }
                },
                child: Text("Guardar cliente"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            icon: Icon(icon),
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}