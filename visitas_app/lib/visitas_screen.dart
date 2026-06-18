// Admin: administrar visitas
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'visita_detail_admin_screen.dart';

class VisitasScreen extends StatefulWidget {
  @override
  State<VisitasScreen> createState() => _VisitasScreenState();
}

class _VisitasScreenState extends State<VisitasScreen> {

  List visitas = [];
  List empleados = [];
  List clientes = [];
  DateTime? fecha;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {

    final emp = await ApiService.getEmpleados();
    final cli = await ApiService.getClientes();
    final data = await ApiService.getVisitasAdminFiltrado(
      fecha: fecha,
    );
    setState(() {
      empleados = emp;
      clientes = cli;
    });
    setState(() => visitas = data);
  }

  Future<void> seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => fecha = picked);
      cargar();
    }
  }

    // FORMATEAR FECHA
  String formatearFecha(String? fecha) {
    if (fecha == null) return "-";
    final f = DateTime.parse(fecha).toLocal();
    return DateFormat('yyyy/MM/dd').format(f);
  }

  // FORMATEAR HORA
  String formatearHora(String? fechaHora) {
    if (fechaHora == null) return "-";
    final f = DateTime.parse(fechaHora).toLocal();
    return DateFormat('HH:mm').format(f);
  }

  // FILTRO
  void abrirFiltro() async {
    DateTime? fecha;
    int? usuarioId;
    int? clienteId;

    final result = await showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setStateModal) {

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: Text("Filtrar visitas"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // 👤 EMPLEADO
                    DropdownButtonFormField<int>(
                      value: usuarioId,
                      isExpanded: true,
                      hint: Text("Empleado"),
                      items: empleados.map<DropdownMenuItem<int>>((e) {
                        return DropdownMenuItem<int>(
                          value: e['id'],
                          child: Text(e['nombre_completo'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setStateModal(() => usuarioId = v),
                    ),

                    SizedBox(height: 12),

                    // 👤 CLIENTE
                    DropdownButtonFormField<int>(
                      value: clienteId,
                      isExpanded: true,
                      hint: Text("Cliente"),
                      items: clientes.map<DropdownMenuItem<int>>((c) {
                        return DropdownMenuItem<int>(
                          value: c['id'],
                          child: Text(c['nombre'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setStateModal(() => clienteId = v),
                    ),

                    SizedBox(height: 12),

                    // 📅 FECHA
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        fecha == null
                            ? "Seleccionar fecha"
                            : "${fecha!.day}/${fecha!.month}/${fecha!.year}",
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                        );

                        if (picked != null) {
                          setStateModal(() => fecha = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      "usuario": usuarioId,
                      "cliente": clienteId,
                      "fecha": fecha,
                    });
                  },
                  child: Text("Aplicar"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final data = await ApiService.getVisitasAdminFiltrado(
        usuarioId: result["usuario"],
        clienteId: result["cliente"],
        fecha: result["fecha"],
      );

      setState(() {
        visitas = data;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Visitas Admin")),

      body: Column(
        children: [

          ListTile(
            leading: Icon(Icons.filter_alt),
            title: Text("Filtro"),
            onTap: abrirFiltro,
          ),

          Expanded(
            child: ListView.builder(
              itemCount: visitas.length,
              itemBuilder: (context, i) {

                final v = visitas[i];

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.location_on),

                    title: Text(v['cliente']),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("👤 ${v['usuario']}"),
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
                          builder: (_) => VisitaDetailAdminScreen(visita: v),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}