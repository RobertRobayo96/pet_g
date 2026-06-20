import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_map_event.dart';
import 'home_map_state.dart';
import 'package:geolocator/geolocator.dart';

class HomeMapBloc extends Bloc<HomeMapEvent, HomeMapState> {
  HomeMapBloc() : super(MapLoading()) {
    on<LoadCurrentLocation>(_onLoadCurrentLocation);
    on<FilterCategoryChanged>(_onFilterCategoryChanged);
  }

  Future<void> _onLoadCurrentLocation(LoadCurrentLocation event, Emitter<HomeMapState> emit) async {
    emit(MapLoading());
    try {
      // 1. Verificar y solicitar permisos de GPS nativos mediante Geolocator
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const MapError(errorMessage: 'Permiso de ubicación denegado.'));
          return;
        }
      }

      // 2. Obtener la posición actual (Si falla o estás en emulador sin GPS configurado, forzamos Bogotá por defecto)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      ).timeout(const Duration(seconds: 4), onTimeout: () {
        return Position(
          latitude: 4.6097, longitude: -74.0817, // Coordenadas de Bogotá
          timestamp: DateTime.now(), accuracy: 0, altitude: 0,
          heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0
        );
      });

      emit(MapLoaded(
        latitude: position.latitude,
        longitude: position.longitude,
        selectedCategory: 'Cuidadores',
      ));
    } catch (e) {
      // Coordenadas de contingencia (Bogotá Centro) por si el emulador no responde
      emit(const MapLoaded(latitude: 4.6097, longitude: -74.0817, selectedCategory: 'Cuidadores'));
    }
  }

  void _onFilterCategoryChanged(FilterCategoryChanged event, Emitter<HomeMapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(MapLoaded(
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        selectedCategory: event.category,
      ));
    }
  }
}