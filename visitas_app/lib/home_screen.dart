// home_screen.dart
// Pantalla principal del empleado comercial.
// Muestra la lista de clientes asignados para el día con indicadores
// de estado (pendiente, en curso, visitado) y permite navegar al detalle
// de cada cliente para iniciar o finalizar visitas.
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'client_detail_screen.dart';
import 'mis_visitas_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Lista de clientes asignados al empleado para hoy
  List clientes = [];

  // Id del cliente con visita actualmente en curso (null si no hay ninguna)
  int? clienteEnCurso;
  // Conjunto de ids de clientes cuya visita ya fue finalizada hoy
  Set<int> clientesVisitados = {};

  @override
  void initState() {
    super.initState();
    cargarDatosHome(); 
  }

 /// Carga los clientes asignados y el estado de las visitas del día.
 /// Determina qué cliente está en curso y cuáles han sido visitados.
 Future<void> cargarDatosHome() async {
  final userId = widget.user['id'];

  final data = await ApiService.getClientesPorUsuario(userId);
  final visitas = await ApiService.getVisitasHoy(userId);

  Set<int> visitados = {};
  int? enCursoId;

  for (var v in visitas) {
    final clienteId = int.tryParse(v['cliente_id'].toString()) ?? 0;

    if (v['estado'] == 'en_curso') {
      enCursoId = clienteId;
    }

    if (v['estado'] == 'finalizada') {
      visitados.add(clienteId);
    }
  }

  setState(() {
    clientes = data;
    clienteEnCurso = enCursoId;
    clientesVisitados = visitados;
  });
}

  /// Cierra la sesión del empleado y vuelve a la pantalla de login,
  /// eliminando todo el historial de navegación.
  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f8ff),

      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),

            Text(
              "Hola",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 8),

            Text(
              widget.user['nombre'] ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),

      drawer: Drawer(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    widget.user['nombre'] ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Comercial",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text("Mi perfil"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: widget.user),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.list),
              title: Text("Mis visitas"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MisVisitasScreen(user: widget.user),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Cerrar sesión"),
              onTap: logout,
            ),
          ],
        ),
      ),

      body: Column(
        children: [

          Container(
            padding: EdgeInsets.all(10),
            child: Wrap(
              spacing: 15,
              children: [
                _legendItem(Colors.orange[200]!, "En curso"),
                _legendItem(Colors.green[200]!, "Visitado"),
                _legendItem(Colors.white, "Pendiente"),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (context, i) {

                final c = clientes[i];
                final clienteId = int.tryParse(c['id'].toString()) ?? 0;

                Color? color;

                if (clienteEnCurso == clienteId) {
                  color = Colors.orange[200];
                } else if (clientesVisitados.contains(clienteId)) {
                  color = Colors.green[200];
                }

                return Card(
                  color: color,
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.business, color: Colors.blue),
                    ),
                    title: Text(c['nombre']),
                    subtitle: Text(c['direccion'] ?? ''),

                    trailing: clienteEnCurso == clienteId
                        ? Icon(Icons.play_arrow, color: Colors.orange)
                        : clientesVisitados.contains(clienteId)
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.arrow_forward),

                    onTap: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClienteDetailScreen(
                            cliente: c,
                            user: widget.user,
                          ),
                        ),
                      );

                      if (resultado == true) {
                        await cargarDatosHome(); 
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un ítem de leyenda con un color y etiqueta para la lista de estados.
  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black12),
          ),
        ),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}