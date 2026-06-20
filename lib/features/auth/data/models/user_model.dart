class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'DUEÑO' o 'CUIDADOR'
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });

  // Fábrica para crear un Usuario a partir del JSON que responda tu API REST
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['id'] ?? json['user']['_id'] ?? '',
      name: json['user']['name'] ?? '',
      email: json['user']['email'] ?? '',
      role: json['user']['role'] ?? 'DUEÑO',
      token: json['token'],
    );
  }

  // 🔥 NUEVA: Fábrica para mapear documentos reales directamente desde Firebase Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'DUEÑO',
      token: documentId, // Usamos el ID del documento como token local inicial
    );
  }

  // Método para convertir el objeto a JSON si necesitas enviar datos al servidor
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}