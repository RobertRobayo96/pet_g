import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

// Estado Inicial: El formulario está vacío y en espera
class AuthInitial extends AuthState {}

// Estado de Carga: Estamos validando las credenciales en la API REST (Muestra el spinner)
class AuthLoading extends AuthState {}

// Estado de Éxito: El usuario se autenticó correctamente
class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

// Estado de Error: Algo falló (Credenciales incorrectas, sin internet, etc.)
class AuthFailure extends AuthState {
  final String errorMessage;
  const AuthFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}