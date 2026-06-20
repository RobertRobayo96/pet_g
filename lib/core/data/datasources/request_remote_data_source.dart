import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petg/core/models/service_request.dart';

class RequestRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Escucha las solicitudes en tiempo real desde la colección de Firebase
  Stream<List<ServiceRequest>> getServiceRequestsStream() {
    return _firestore.collection('solicitudes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceRequest.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // El Dueño crea la solicitud en la colección de Firestore
  Future<void> crearSolicitud({
    required String petName,
    required int hours,
    required String totalPayment,
  }) async {
    await _firestore.collection('solicitudes').doc('active_service').set({
      'id': 'req_${DateTime.now().millisecondsSinceEpoch}',
      'owner_name': 'Robert Robayo (Dueño)',
      'pet_name': '$petName (${petName == 'Max' ? 'Golden Retriever' : 'Criollo Consentido'})',
      'duration': '$hours horas',
      'payment': totalPayment,
      'status': 'PENDIENTE',
    });
  }

  // El Cuidador escucha los cambios reactivos en tiempo real (Stream)
  Stream<DocumentSnapshot> escucharSolicitudActiva() {
    return _firestore.collection('solicitudes').doc('active_service').snapshots();
  }

  // El Cuidador actualiza el estado a aceptado al presionar el botón
  Future<void> aceptarSolicitud() async {
    await _firestore.collection('solicitudes').doc('active_service').update({
      'status': 'ACEPTADO',
    });
  }
}