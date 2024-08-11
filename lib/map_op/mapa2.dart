import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class mapasV2 extends StatefulWidget {
  const mapasV2({super.key});

  @override
  State<mapasV2> createState() => _mapasV();
}

class _mapasV extends State<mapasV2> {
  List<LatLng> userPositions = [];
  List<Marker> markers = [];
  double polygonArea = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserLocations();
  }

  void _fetchUserLocations() async {
    try {
      FirebaseFirestore.instance.collection('Posiciones').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          List<LatLng> positions = [];
          List<Marker> newMarkers = [];

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>?;

            if (data != null) {
              final nombre = data['nombre'] ?? 'Usuario desconocido';
              final lat = data['lat'] ?? 0.0;
              final long = data['log'] ?? 0.0;

              LatLng position = LatLng(lat, long);
              positions.add(position);

              Marker marker = Marker(
                point: position,
                width: 40,
                height: 40,
                child: Tooltip(
                  message: nombre,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              );
              newMarkers.add(marker);
            }
          }

          if (positions.length > 2) {
            positions.add(positions.first); // Cierra el polígono si hay suficientes puntos
            setState(() {
              userPositions = positions;
              markers = newMarkers;
              polygonArea = _calculatePolygonArea(userPositions);
            });
          } else {
            setState(() {
              userPositions = positions;
              markers = newMarkers;
              polygonArea = 0.0; // No hay área si no hay suficiente número de puntos
            });
          }
        }
      });
    } catch (e) {
      print("Error fetching user locations: $e");
    }
  }

  double _calculatePolygonArea(List<LatLng> positions) {
    if (positions.length < 3) return 0.0;

    double area = 0.0;
    double conversionFactor = 111320; // Factor de conversión de grados a metros

    for (int i = 0; i < positions.length - 1; i++) {
      double xi = positions[i].longitude * conversionFactor * cos(positions[i].latitude * pi / 180);
      double yi = positions[i].latitude * conversionFactor;
      double xj = positions[i + 1].longitude * conversionFactor * cos(positions[i + 1].latitude * pi / 180);
      double yj = positions[i + 1].latitude * conversionFactor;

      area += (xi * yj - xj * yi);
    }

    return area.abs() / 2.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Mapa de Usuarios"),
      ),
      body: Column(
        children: [
          if (polygonArea > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Área del polígono: ${polygonArea.toStringAsFixed(2)} m²',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: userPositions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: userPositions.isNotEmpty
                          ? userPositions[0]
                          : LatLng(0.0, 0.0), // Centrar en la primera ubicación o en coordenadas (0,0)
                      maxZoom: 25,
                      minZoom: 5,
                      initialZoom: 10,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: markers,
                      ),
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: userPositions,
                            color: Colors.blue.withOpacity(0.3),
                            borderStrokeWidth: 3.0,
                            borderColor: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
