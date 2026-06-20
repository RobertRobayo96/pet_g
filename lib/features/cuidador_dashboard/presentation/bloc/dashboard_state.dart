import 'package:equatable/equatable.dart';
import '../../../../core/models/service_request.dart'; // Importamos el modelo real

abstract class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object?> get props => [];
}


class DashboardInitial extends DashboardState {}

// 2. Estado de Carga
class DashboardLoading extends DashboardState {}

// 3. Estado de Éxito Ajustado
class DashboardLoaded extends DashboardState {
  final double earnings;
  final int activeServices;
  final double rating;
  final bool isOnline;
  
  final List<ServiceRequest> pendingRequests; 

  const DashboardLoaded({
    required this.earnings,
    required this.activeServices,
    required this.rating,
    required this.isOnline,
    required this.pendingRequests, 
  });

  @override
  List<Object?> get props => [earnings, activeServices, rating, isOnline, pendingRequests];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}