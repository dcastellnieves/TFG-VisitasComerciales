// Mis visitar: se muestras las visitas del empleado
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';
import 'visita_detail_screen.dart';

class MisVisitasScreen extends StatefulWidget {
  final Map user;

  MisVisitasScreen({required this.user});

  @override
  _MisVisitasScreenState createState() => _MisVisitasScreenState();
}

class _MisVisitasScreenState extends State<MisVisitasScreen> {

  List visitas = [];
  List visitasFiltradas = [];

  String? filtroCliente;
  DateTime? filtroFecha;

  @override
  void initState() {
    super.initState();
    cargarVisitas();
  }

  //  CARGAR VISITAS
  void cargarVisitas() async {
    final data = await ApiService.getVisitas(widget.user['id']);

    // ordenar por fecha DESC
    data.sort((a, b) =>
        DateTime.parse(b['fecha']).compareTo(DateTime.parse(a['fecha'])));

    setState(() {
      visitas = data;
      visitasFiltradas = data;
    });
  }

  //  FORMATEAR FECHA
  String formatearFecha(String? fecha) {
    if (fecha == null) return "-";
    final f = DateTime.parse(fecha).toLocal();
    return DateFormat('yyyy/MM/dd').format(f);
  }

  //  FORMATEAR HORA
  String formatearHora(String? fechaHora) {
    if (fechaHora == null) return "-";
    final f = DateTime.parse(fechaHora).toLocal();
    return DateFormat('HH:mm').format(f);
  }

  // COMPARAR  DÍA 
  bool mismaFecha(DateTime a, DateTime b) {
    return a.year == b.year &&
           a.month == b.month &&
           a.day == b.day;
  }

  void aplicarFiltros() {

    List temp = visitas;

    // FILTRO CLIENTE
    if (filtroCliente != null && filtroCliente!.isNotEmpty) {
      temp = temp.where((v) =>
        v['cliente'].toLowerCase().contains(filtroCliente!.toLowerCase())
      ).toList();
    }

    //  FILTRO FECHA 
    if (filtroFecha != null) {
      temp = temp.where((v) {
        final fechaVisita = DateTime.parse(v['fecha']).toLocal();
        return mismaFecha(fechaVisita, filtroFecha!);
      }).toList();
    }

    setState(() {
      visitasFiltradas = temp;
    });
  }

  // FILTRO
  void abrirFiltroModal() {

    String? clienteTemp = filtroCliente;
    DateTime? fechaTemp = filtroFecha;

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: Text("Filtrar visitas"),

          content: StatefulBuilder(
            builder: (context, setStateModal) {

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // FILTRO nombre CLIENTE 
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Cliente",
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: clienteTemp),
                    onChanged: (val) {
                      clienteTemp = val;
                    },
                  ),

                  SizedBox(height: 10),

                  // FILTO FECHA
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setStateModal(() {
                          fechaTemp = picked;
                        });
                      }
                    },
                    child: Text(fechaTemp == null
                        ? "Seleccionar fecha"
                        : "${fechaTemp!.year}/${fechaTemp!.month.toString().padLeft(2, '0')}/${fechaTemp!.day.toString().padLeft(2, '0')}"),
                  ),

                ],
              );
            },
          ),

          actions: [

            //BORRAR FILTROS
            TextButton(
              onPressed: () {
                setState(() {
                  filtroCliente = null;
                  filtroFecha = null;
                  visitasFiltradas = visitas;
                });
                Navigator.pop(context);
              },
              child: Text("Borrar"),
            ),

            // APLICAR
            ElevatedButton(
              onPressed: () {
                setState(() {
                  filtroCliente = clienteTemp;
                  filtroFecha = fechaTemp;
                });

                aplicarFiltros();

                Navigator.pop(context);
              },
              child: Text("Aplicar"),
            ),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Mis visitas"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: abrirFiltroModal,
          ),
        ],
      ),

      body: visitasFiltradas.isEmpty
          ? Center(child: Text("No hay visitas"))
          : ListView.builder(
              itemCount: visitasFiltradas.length,
              itemBuilder: (context, i) {

                final v = visitasFiltradas[i];

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.location_on),

                    title: Text(v['cliente']),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📅 ${formatearFecha(v['fecha'])}"),
                        Text("🕐 ${formatearHora(v['hora_inicio'])}"),
                        Text("⏱ ${v['duracion_minutos'] ?? 0} min"),
                      ],
                    ),

                    trailing: Text(
                      v['estado'],
                      style: TextStyle(
                        color: v['estado'] == 'en_curso'
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VisitaDetailScreen(visita: v),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}