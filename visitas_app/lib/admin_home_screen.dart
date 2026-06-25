// admin_home_screen.dart
// Pantalla principal del administrador.
// Muestra un panel de acceso rápido con tarjetas de navegación hacia
// los módulos de administración: estadísticas, empleados, clientes,
// asignaciones y visitas. Incluye drawer lateral con perfil y cierre de sesión.
import 'package:flutter/material.dart';
import '../estadisticas_screen.dart';
import 'empleados_screen.dart';
import 'clientes_screen.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';
import 'asignaciones_screen.dart';
import 'visitas_screen.dart';

/// Widget raíz del panel de administración. Sin estado propio.
class AdminHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminHomeScreen({required this.user});

  /// Cierra la sesión del admin y vuelve a SplashScreen,
  /// eliminando todo el historial de navegación.
  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 600;

    return Scaffold(
      backgroundColor: const Color(0xfff5f8ff),

      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Hola",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              user['nombre'] ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 25, color: Colors.black),
            ),
          ],
        ),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              color: Colors.blue.shade400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    user['nombre'] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Administrador",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Mi perfil"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: user),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWeb ? 900 : double.infinity,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Panel de administración",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 15),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: isWeb ? 3 : 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: isWeb ? 1.15 : 1.05,

                    children: [
                      _tile(
                        context,
                        icon: Icons.bar_chart,
                        title: "Estadísticas",
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EstadisticasScreen(),
                            ),
                          );
                        },
                      ),

                      _tile(
                        context,
                        icon: Icons.people,
                        title: "Empleados",
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmpleadosScreen(),
                            ),
                          );
                        },
                      ),

                      _tile(
                        context,
                        icon: Icons.business,
                        title: "Clientes",
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClientesScreen(),
                            ),
                          );
                        },
                      ),

                      _tile(
                        context,
                        icon: Icons.assignment,
                        title: "Asignaciones",
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AsignacionesScreen(),
                            ),
                          );
                        },
                      ),

                      _tile(
                        context,
                        icon: Icons.location_on,
                        title: "Visitas",
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VisitasScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye una tarjeta de acceso rápido con icono, título y acción de navegación.
  /// Adapta el tamaño del padding e icono para web y móvil.
  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isWeb ? 16 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: isWeb ? 26 : 30,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}