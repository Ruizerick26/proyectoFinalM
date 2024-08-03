import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proyecto_final/schema/ubicacion.dart';
import 'package:proyecto_final/firebase/services.dart';

class mapasV extends StatefulWidget {
  const mapasV({super.key});

  @override
  State<mapasV> createState() => _mapasV();
}

class _mapasV extends State<mapasV> {

  LatLng? myPosition;
  

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    usuario usser = new usuario(nombre: "Erick" , lat: position.latitude, log: position.longitude);
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
      subir(usser);
      print(myPosition);
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Usuario 1"),
      ),
      body: myPosition == null ?
      const CircularProgressIndicator()
      : FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(myPosition!.latitude,myPosition!.longitude),
          maxZoom: 25,
          minZoom: 5, 
          initialZoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a','b','c'],
          ),
          MarkerLayer(
            markers:[
              Marker(
                point: LatLng(myPosition!.latitude,myPosition!.longitude), 
                child: const Icon(
                  Icons.person_pin,
                  color: Colors.blueAccent,
                  size: 40,
                  )

              )
            ]
            )
        ],
      )
      ,
    );
  }
}