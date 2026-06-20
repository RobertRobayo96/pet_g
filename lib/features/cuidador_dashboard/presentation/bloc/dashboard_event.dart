import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

// Evento para cargar las estadísticas iniciales del cuidador
class LoadDashboardData extends DashboardEvent {}

// Evento para cambiar el estado de disponibilidad (Online / Offline)
class ToggleAvailability extends DashboardEvent {
  final bool isOnline;
  const ToggleAvailability({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}

// Evento para aceptar una solicitud de cuidado entrante
class AcceptServiceRequested extends DashboardEvent {
  final String serviceId;
  const AcceptServiceRequested({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}