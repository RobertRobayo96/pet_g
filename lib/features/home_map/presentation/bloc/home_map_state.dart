import 'package:equatable/equatable.dart';

abstract class HomeMapState extends Equatable {
  const HomeMapState();
  
  @override
  List<Object?> get props => [];
}


class MapLoading extends HomeMapState {}

class MapLoaded extends HomeMapState {
  final double latitude;
  final double longitude;
  final String selectedCategory;

  const MapLoaded({
    required this.latitude,
    required this.longitude,
    required this.selectedCategory,
  });

  @override
  List<Object?> get props => [latitude, longitude, selectedCategory];
}

class MapError extends HomeMapState {
  final String errorMessage;
  const MapError({required this.errorMessage});
}