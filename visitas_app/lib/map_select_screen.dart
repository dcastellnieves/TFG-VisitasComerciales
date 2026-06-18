// Mapa para seleccionar y buscar ubicación de cleinte quitar
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSelectScreen extends StatefulWidget {
  @override
  State<MapSelectScreen> createState() => _MapSelectScreenState();
}

class _MapSelectScreenState extends State<MapSelectScreen> {

  LatLng position = LatLng(28.4636, -16.2518);
  GoogleMapController? mapController;

  TextEditingController searchCtrl = TextEditingController();


  Future<void> buscarDireccion(String value) async {
    if (value.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Conecta Google Places API para búsqueda real"),
      ),
    );
  }

  //TAP EN MAPA
  void onTapMap(LatLng pos) {
    setState(() {
      position = pos;
    });
  }

  // CONFIRMAR 
  void confirmar() {
    Navigator.pop(context, position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar ubicación"),
      ),

      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position,
              zoom: 14,
            ),
            onMapCreated: (c) => mapController = c,
            onTap: onTapMap,
            markers: {
              Marker(
                markerId: MarkerId("selected"),
                position: position,
              )
            },
          ),

          //  SEARCH BAR 
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  )
                ],
              ),
              child: TextField(
                controller: searchCtrl,
                onSubmitted: buscarDireccion,
                decoration: InputDecoration(
                  hintText: "Buscar dirección (Google Places)",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          //  BOTÓN CONFIRMAR
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: confirmar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
              ),
              child: Text("Usar esta ubicación"),
            ),
          ),

        ],
      ),
    );
  }
}