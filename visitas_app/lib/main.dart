// main.dart
// Punto de entrada de la aplicación Flutter.
// Configura el tema global (Material 3) y establece SplashScreen como
// pantalla inicial del árbol de widgets.
import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(MyApp());
}

/// Widget raíz de la aplicación.
/// Define el MaterialApp con el tema corporativo y la ruta inicial.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ── TEMA GLOBAL ──────────────────────────────────────────────
      // Paleta de color basada en azul con Material 3
      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: Color(0xfff5f8ff),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade300,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      home: SplashScreen(),
    );
  }
}