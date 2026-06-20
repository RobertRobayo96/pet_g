import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petg/core/models/service_request.dart';
import 'package:petg/features/cuidador_dashboard/data/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import 'package:petg/core/data/datasources/request_remote_data_source.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final RequestRemoteDataSource _dataSource = RequestRemoteDataSource();
  final DashboardRepository _repository = DashboardRepository();
  StreamSubscription? _requestSubscription;
  
  // variable local para retener el estado real del switch
  bool _currentIsOnline = true;

  DashboardBloc() : super(DashboardLoading()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<AcceptServiceRequested>(_onAcceptServiceRequested);
    
    
    on<ToggleAvailability>((event, emit) {
      _currentIsOnline = event.isOnline; // Guardamos el nuevo valor
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        emit(DashboardLoaded(
          earnings: currentState.earnings,
          activeServices: currentState.activeServices,
          rating: currentState.rating,
          isOnline: _currentIsOnline, 
          pendingRequests: currentState.pendingRequests,
        ));
      }
    });
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    await emit.forEach<List<ServiceRequest>>(
      _repository.getServiceRequests(),
      onData: (requests) => DashboardLoaded(
        earnings: 150000.0,    
        activeServices: requests.length, 
        rating: 4.8,           
        isOnline: _currentIsOnline, // <-- Usa la variable local dinámica
        pendingRequests: requests, 
      ),
      onError: (error, stackTrace) => DashboardError(message: error.toString()),
    );
  }

  Future<void> _onAcceptServiceRequested(AcceptServiceRequested event, Emitter<DashboardState> emit) async {
    await _dataSource.aceptarSolicitud();
  }

  @override
  Future<void> close() {
    _requestSubscription?.cancel();
    return super.close();
  }
}