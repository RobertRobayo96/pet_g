import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthLocalRepository {
  final _secureStorage = const FlutterSecureStorage();

  // Guarda el token JWT de forma cifrada
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  // Lee el token JWT cifrado
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  // Guarda el rol del usuario (Dueño o Cuidador) en Hive para saber qué Home abrir
  Future<void> saveUserRole(String role) async {
    var box = Hive.box('app_preferences');
    await box.put('user_role', role);
  }

  // Obtiene el rol guardado
  String? getUserRole() {
    var box = Hive.box('app_preferences');
    return box.get('user_role');
  }

  // Borra todo al cerrar sesión
  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'jwt_token');
    var box = Hive.box('app_preferences');
    await box.delete('user_role');
  }
}