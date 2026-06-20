import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Evento de Login...
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

// 🚀 VERIFICA QUE ESTA CLASE ESTÉ EXACTAMENTE ASÍ:
class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [name, email, password, role];
}