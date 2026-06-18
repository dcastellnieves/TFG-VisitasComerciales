import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class VisitaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> visita;

  const VisitaDetailScreen({required this.visita});

  @override
  State<VisitaDetailScreen> createState() => _VisitaDetailScreenState();
}

class _VisitaDetailScreenState extends State<VisitaDetailScreen> {

  late String notas;
  bool editandoNotas = false;
  late TextEditingController notasCtrl;

  @override
  void initState() {
    super.initState();
    notas = widget.visita['notas'] ?? "";
    notasCtrl = TextEditingController(text: notas);
  }

  String formatearFecha(String? fecha) {
    if (fecha == null) return "-";
    final f = DateTime.parse(fecha).toLocal();
    return DateFormat('dd/MM/yyyy').format(f);
  }

  String formatearHora(String? fechaHora) {
    if (fechaHora == null) return "-";
    final f = DateTime.parse(fechaHora).toLocal();
    return DateFormat('HH:mm').format(f);
  }

  void guardarNotas() async {
    try {
      await ApiService.actualizarNotas(
        widget.visita['id'],
        notasCtrl.text,
      );

      setState(() {
        notas = notasCtrl.text;
        editandoNotas = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Notas guardadas")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar")),
      );
    }
  }

  void cancelarEdicion() {
    setState(() {
      notasCtrl.text = notas;
      editandoNotas = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final visita = widget.visita;

    final latInicio = visita['lat_inicio'];
    final lonInicio = visita['lon_inicio'];
    final latFin = visita['lat_fin'];
    final lonFin = visita['lon_fin'];

    LatLng? inicio;
    LatLng? fin;

    if (latInicio != null && lonInicio != null) {
      inicio = LatLng(
        double.parse(latInicio.toString()),
        double.parse(lonInicio.toString()),
      );
    }

    if (latFin != null && lonFin != null) {
      fin = LatLng(
        double.parse(latFin.toString()),
        double.parse(lonFin.toString()),
      );
    }

    Set<Marker> markers = {};

    if (inicio != null) {
      markers.add(
        Marker(
          markerId: MarkerId("inicio"),
          position: inicio,
          infoWindow: InfoWindow(title: "Inicio"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    if (fin != null) {
      markers.add(
        Marker(
          markerId: MarkerId("fin"),
          position: fin,
          infoWindow: InfoWindow(title: "Fin"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de visita"),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // MAPA
            if (inicio != null)
              SizedBox(
                height: 250,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: inicio,
                    zoom: 14,
                  ),
                  markers: markers,
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [

                  // CLIENTE
                  Text(
                    visita['cliente'] ?? '',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20),

                  // INFO CARD
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _row("Fecha", formatearFecha(visita['fecha'])),
                          _row("Hora", formatearHora(visita['hora_inicio'])),
                          _row("Estado", visita['estado'] ?? ''),
                          _row("Duración", "${visita['duracion_minutos'] ?? 0} min"),

                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // NOTAS EDITABLES
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Notas",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              if (!editandoNotas)
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      editandoNotas = true;
                                    });
                                  },
                                ),
                            ],
                          ),

                          SizedBox(height: 10),

                          if (editandoNotas) ...[

                            TextField(
                              controller: notasCtrl,
                              maxLines: 4,
                            ),

                            SizedBox(height: 10),

                            Row(
                              children: [

                                Expanded(
                                  child: TextButton(
                                    onPressed: cancelarEdicion,
                                    child: Text("Cancelar"),
                                  ),
                                ),

                                SizedBox(width: 10),

                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: guardarNotas,
                                    child: Text("Guardar"),
                                  ),
                                ),

                              ],
                            ),

                          ] else
                            Text(
                              notas.isEmpty ? "Sin comentarios" : notas,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FILA LIMPIA
  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}