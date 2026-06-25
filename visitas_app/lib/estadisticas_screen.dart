// estadisticas_screen.dart
// Pantalla de estadísticas y KPIs para el administrador.
// Muestra indicadores clave del sistema (visitas hoy, semana, empleados,
// clientes), el ranking de los 5 empleados con más visitas y un gráfico
// de barras con las visitas de los últimos 7 días.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'api_service.dart';

class EstadisticasScreen extends StatefulWidget {
  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  // Contadores de KPIs principales
  int visitasHoy = 0;
  int visitasSemana = 0;
  int empleadosActivos = 0;
  int clientesTotal = 0;

  // Datos del ranking de empleados y gráfico de visitas por día
  List ranking = [];
  List visitasSemanaData = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  /// Obtiene las métricas del backend y actualiza los valores de los KPIs,
  /// el ranking y los datos del gráfico de barras semanal.
  Future<void> cargar() async {
    try {
      final data = await ApiService.getEstadisticasAdmin();

      setState(() {
        visitasHoy = int.tryParse(data['visitas_hoy'].toString()) ?? 0;
        visitasSemana = int.tryParse(data['visitas_semana'].toString()) ?? 0;
        empleadosActivos = int.tryParse(data['empleados_activos'].toString()) ?? 0;
        clientesTotal = int.tryParse(data['clientes_total'].toString()) ?? 0;

        ranking = data['ranking'] ?? [];
        visitasSemanaData = data['visitas_7_dias'] ?? [];

        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 600;

    return Scaffold(
      backgroundColor: const Color(0xfff5f8ff),

      appBar: AppBar(
        title: const Text("Estadísticas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          // CONTENEDOR 
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 900 : double.infinity,
                ),

                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ================= KPIs =================
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isWeb ? 4 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isWeb ? 1.3 : 1.2,
                        children: [
                          _kpi("Hoy", visitasHoy, Icons.today, Colors.blue),
                          _kpi("Semana", visitasSemana, Icons.date_range, Colors.indigo),
                          _kpi("Empleados", empleadosActivos, Icons.people, Colors.green),
                          _kpi("Clientes", clientesTotal, Icons.business, Colors.orange),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // ================= RANKING =================
                      const Text(
                        "Top empleados",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ...ranking.map((e) {
                        final max = ranking.isNotEmpty
                            ? int.tryParse(ranking.first['total'].toString()) ?? 1
                            : 1;

                        final value = int.tryParse(e['total'].toString()) ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 6,
                                color: Colors.black12,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e['nombre'] ?? ""),
                                  Text("$value"),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: max == 0 ? 0 : value / max,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 25),

                      // ================= GRÁFICO =================
                      const Text(
                        "Visitas últimos 7 días",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Container(
                        height: 180,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: visitasSemanaData.map<Widget>((d) {
                            final max = visitasSemanaData.isNotEmpty
                                ? visitasSemanaData
                                    .map((e) => int.tryParse(e['total'].toString()) ?? 0)
                                    .reduce((a, b) => a > b ? a : b)
                                : 1;

                            final value = int.tryParse(d['total'].toString()) ?? 0;

                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: max == 0 ? 0 : (value / max) * 120,
                                    width: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    d['dia'] ?? '',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ================= KPI =================
  /// Construye una tarjeta KPI con icono, valor numérico y título.
  /// Adapta el tamaño del icono para web y móvil.
  Widget _kpi(String title, int value, IconData icon, Color color) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: isWeb ? 26 : 28),
          const SizedBox(height: 10),
          Text(
            "$value",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}