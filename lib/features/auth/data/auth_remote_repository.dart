import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petg/features/auth/data/models/user_model.dart'; 

class AuthRemoteRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 
  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role, // 'DUEÑO' o 'CUIDADOR'
  }) async {
    try {

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? firebaseUser = result.user;

      if (firebaseUser == null) {
        throw Exception("No se pudo crear el usuario en el servidor.");
      }

      // Guardar los datos del perfil y rol en Firestore
      await _firestore.collection('usuarios').doc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Retornamos usando los parámetros correctos de tu UserModel
      return UserModel(
        id: firebaseUser.uid,
        name: name,
        email: email,
        role: role,
        token: firebaseUser.uid, 
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('El correo electrónico ya se encuentra registrado.');
      } else if (e.code == 'weak-password') {
        throw Exception('La contraseña ingresada es demasiado débil.');
      } else if (e.code == 'invalid-email') {
        throw Exception('El formato del correo electrónico no es válido.');
      }
      throw Exception(e.message ?? 'Error durante el proceso de registro.');
    } catch (e) {
      throw Exception('Error inesperado en el registro: $e');
    }
  }

  // LOGIN CON LA API DE FIREBASE
  Future<UserModel> loginWithEmailAndPassword(String email, String password) async {
    try {
      // Autenticar credenciales con la API de Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      User? firebaseUser = result.user;
      if (firebaseUser == null) {
        throw Exception("Error de servidor: Usuario no devuelto.");
      }

      // Busca el documento del usuario en Firestore para leer su rol real
      DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(firebaseUser.uid).get();
      
      if (!userDoc.exists) {
        throw Exception("El perfil del usuario no existe en la base de datos.");
      }

      final data = userDoc.data() as Map<String, dynamic>;

      return UserModel.fromFirestore(data, firebaseUser.uid);
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('El correo electrónico o la contraseña son incorrectos.');
      } else if (e.code == 'invalid-email') {
        throw Exception('El formato del correo electrónico es inválido.');
      } else if (e.code == 'user-disabled') {
        throw Exception('Esta cuenta de usuario ha sido deshabilitada.');
      }
      throw Exception(e.message ?? 'Error al iniciar sesión.');
    } catch (e) {
      throw Exception('Error de autenticación: $e');
    }
  }
}