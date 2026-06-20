import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../auth_remote_repository.dart';
import '../../auth_local_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteRepository remoteRepository;
  final AuthLocalRepository localRepository;

  AuthBloc({
    required this.remoteRepository,
    required this.localRepository,
  }) : super(AuthInitial()) {
    
    // 🔑 1. Manejador de Login
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await remoteRepository.loginWithEmailAndPassword(event.email, event.password);
        await localRepository.saveToken(user.token ?? user.id);
        await localRepository.saveUserRole(user.role);
        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
      }
    });

    // 🚀 2. ¡ASEGÚRATE DE QUE ESTO ESTÉ ESCRITO Y GUARDADO AQUÍ!
    on<RegisterSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await remoteRepository.registerWithEmailAndPassword(
          name: event.name,
          email: event.email,
          password: event.password,
          role: event.role,
        );

        await localRepository.saveToken(user.token ?? user.id);
        await localRepository.saveUserRole(user.role);

        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}