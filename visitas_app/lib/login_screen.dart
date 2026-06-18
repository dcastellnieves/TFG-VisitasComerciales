// login_screen
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_screen.dart';
import 'admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar sesión")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: "Correo electrónico"),
            ),

            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: "Contraseña"),
            ),

            SizedBox(height: 20),

            if (error != null)
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.red[100],
                child: Text(error!, style: TextStyle(color: Colors.red)),
              ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                try {
                  final user = await ApiService.login(
                    emailCtrl.text,
                    passCtrl.text,
                  );

                  if (user['rol'] == 'admin') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminHomeScreen(user: user),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(user: user),
                      ),
                    );
                  }

                } catch (e) {
                  setState(() {
                    error = e.toString().replaceAll("Exception:", "");
                  });
                }
              },
              child: Text("Entrar"),
            ),

          ],
        ),
      ),
    );
  }
}