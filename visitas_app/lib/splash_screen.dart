// splash_screen.dart
// Pantalla de bienvenida de la aplicación.
// Muestra el logotipo y nombre de la app con un fondo degradado,
// y ofrece el botón de acceso que navega hacia LoginScreen.
import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Pantalla estática de bienvenida. No mantiene estado.
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(Icons.location_on, size: 100, color: Colors.white),

            SizedBox(height: 20),

            Text(
              "Visitas Comerciales",
              style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text("Iniciar"),
            ),

          ],
        ),
      ),
    );
  }
}