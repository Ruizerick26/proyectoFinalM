import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proyecto_final/schema/ubicacion.dart';
import 'package:proyecto_final/firebase/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class mapasV extends StatefulWidget {
  const mapasV({super.key});

  @override
  State<mapasV> createState() => _mapasV();
}

class _mapasV extends State<mapasV> {
  LatLng? myPosition;
  String? nombreUsuario;
  StreamSubscription? posicion;

  // Future<Position> determinePosition() async {
    
  //   return await Geolocator.getCurrentPosition();
  // }

  // void getCurrentLocation() async {
  //   Position position = await determinePosition();
  //   User? usCt = FirebaseAuth.instance.currentUser;
  //   usuario usser = usuario(nombre: nombreUsuario ?? "Desconocido", lat: position.latitude, log: position.longitude);
  //   setState(() {
  //     myPosition = LatLng(position.latitude, position.longitude);
  //     subir(usser, usCt!.uid);
  //     print('A $myPosition');
  //   });
  // }


void _posicion() async{
  LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
  User? usCt = FirebaseAuth.instance.currentUser;
  posicion = Geolocator.getPositionStream().listen(
    (Position? position){
      setState(() {
        myPosition = LatLng(position!.latitude, position.longitude);
        usuario usser = usuario(nombre: nombreUsuario ?? "Desconocido", lat: position.latitude, log: position.longitude);
        subir(usser,usCt!.uid);
        print(myPosition);
      });
    },
    onError: (e){
      print("On Error ${e.runtimeType}");
    }
  );
}

  Future<String?> obtenerNombreUsuario() async {
    User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .get();
      return userDoc['nombre'] as String?;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    obtenerNombreUsuario().then((nombre) {
      setState(() {
        nombreUsuario = nombre;
        _posicion();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FutureBuilder<String?>(
          future: obtenerNombreUsuario(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Cargando...");
            } else if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.hasData) {
              return Text("Usuario: ${snapshot.data}");
            } else {
              return const Text("Usuario desconocido");
            }
          },
        ),
      ),
      body: myPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(myPosition!.latitude, myPosition!.longitude),
                maxZoom: 25,
                minZoom: 5,
                initialZoom: 10,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(myPosition!.latitude, myPosition!.longitude),
                      child: const Icon(
                        Icons.person_pin,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
