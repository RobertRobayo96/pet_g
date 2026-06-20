import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapaCuidadorScreen extends StatefulWidget {
  final String petName;

  const MapaCuidadorScreen({super.key, required this.petName});

  @override
  State<MapaCuidadorScreen> createState() => _MapaCuidadorScreenState();
}

class _MapaCuidadorScreenState extends State<MapaCuidadorScreen> {
  late GoogleMapController mapController;

  // Ubicación inicial de prueba (Bogotá Centro)
  static const LatLng _center = LatLng(4.5981, -74.0760);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        title: Text(
          'Recogiendo a ${widget.petName}', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 16.0,
        ),
        // Marcador dinámico en Bogotá
        markers: {
          Marker(
            markerId: const MarkerId('pickup_location'),
            position: _center,
            infoWindow: InfoWindow(
              title: 'Punto de Recogida',
              snippet: 'Aquí espera ${widget.petName}',
            ),
          ),
        },
      ),
      
      // 🔘 BOTÓN INFERIOR: Envía la señal al dueño cambiando el estado a LLEGÓ
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A), // Azul corporativo
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle, size: 24),
            label: const Text(
              '¡Ya llegué a la ubicación!', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            onPressed: () async {
              try {
                // Actualizamos el estado de la solicitud en Firebase en tiempo real
                await FirebaseFirestore.instance
                    .collection('solicitudes')
                    .doc('active_service') // Apunta al documento de prueba que vimos en consola
                    .update({'status': 'LLEGÓ'});

                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Notificación enviada al dueño. ¡Avisaste que llegaste por ${widget.petName}!'), 
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al notificar: $e'), 
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}