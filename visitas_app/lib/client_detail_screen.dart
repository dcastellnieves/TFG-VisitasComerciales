
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'map_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ClienteDetailScreen extends StatefulWidget {
  final Map cliente;
  final Map user;

  ClienteDetailScreen({required this.cliente, required this.user});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {

  bool visitaEnCurso = false;
  bool hayVisitaGlobal = false;

  @override
  void initState() {
    super.initState();
    comprobar();
  }

  Future<void> comprobar() async {
    final visitas = await ApiService.getVisitas(widget.user['id']);

    setState(() {
      visitaEnCurso = visitas.any((v) =>
          v['estado'] == 'en_curso' &&
          v['cliente_id'].toString() == widget.cliente['id'].toString());

      hayVisitaGlobal = visitas.any((v) => v['estado'] == 'en_curso');
    });
  }

  Future<void> abrirMaps() async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${widget.cliente['direccion']}"
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> llamar() async {
    final url = Uri.parse("tel:${widget.cliente['telefono']}");
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Cliente"),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            //  NOMBRE
            Text(
              widget.cliente['nombre'] ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            // INFO CARD 
            Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [

                    Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.cliente['direccion'] ?? "No disponible",
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.phone),
                        SizedBox(width: 10),
                        Text(
                          widget.cliente['telefono'] ?? "No disponible",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),

            Row(
              children: [

                Expanded(
                  child: _tileButton(
                    icon: Icons.map,
                    label: "Cómo llegar",
                    onTap: abrirMaps,
                  ),
                ),

                SizedBox(width: 15),

                Expanded(
                  child: _tileButton(
                    icon: Icons.call,
                    label: "Llamar",
                    onTap: llamar,
                  ),
                ),

              ],
            ),

            SizedBox(height: 30),

            //  INICIAR VISITA 
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: hayVisitaGlobal
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Ya hay una visita en curso"),
                          ),
                        );
                      }
                    : () async {

                        final pos = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MapScreen()),
                        );

                        if (pos == null) return;
                        
                        print("=== FLUTTER INICIAR VISITA ===");
                        print("usuario_id: ${widget.user['id']}");
                        print("cliente_id: ${widget.cliente['id']}");

                        await ApiService.iniciarVisitaConUbicacion(
                          widget.user['id'],
                          widget.cliente['id'],
                          pos.latitude,
                          pos.longitude,
                        );

                        Navigator.pop(context, true);
                      },
                child: Text("Iniciar visita"),
              ),
            ),

            SizedBox(height: 10),

            //  FINALIZAR VISITA 
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: visitaEnCurso
                    ? () async {

                        final pos = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MapScreen()),
                        );

                        if (pos == null) return;

                        String comentario = "";

                        await showDialog(
                          context: context,
                          builder: (context) {

                            TextEditingController c = TextEditingController();

                            return AlertDialog(
                              title: Text("Comentario"),
                              content: TextField(
                                controller: c,
                                maxLines: 3,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    comentario = "";
                                    Navigator.pop(context);
                                  },
                                  child: Text("Saltar"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    comentario = c.text;
                                    Navigator.pop(context);
                                  },
                                  child: Text("Guardar"),
                                ),
                              ],
                            );
                          },
                        );
                        await ApiService.finalizarVisitaConUbicacion(
                          widget.user['id'],
                          widget.cliente['id'],
                          pos.latitude,
                          pos.longitude,
                          comentario,
                        );

                        Navigator.pop(context, true);
                      }
                    : null,
                child: Text("Finalizar visita"),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _tileButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          height: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}