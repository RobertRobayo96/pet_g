class ServiceRequest {
  final String id;
  final String petName;
  final String hours;
  final String totalPayment;
  final String status;
  final String ownerName; 

  ServiceRequest({
    required this.id,
    required this.petName,
    required this.hours,
    required this.totalPayment,
    required this.status,
    required this.ownerName,
  });

  // mapeo que viene desde Firebase (fromMap o fromFirestore)
  factory ServiceRequest.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceRequest(
      id: documentId,
      petName: map['pet_name'] ?? '',
      hours: map['duration']?.toString() ?? '',
      totalPayment: map['payment']?.toString() ?? '',
      status: map['status'] ?? '',
      ownerName: map['owner_name'] ?? map['id'] ?? 'Dueño de Mascota',
    );
  }
}