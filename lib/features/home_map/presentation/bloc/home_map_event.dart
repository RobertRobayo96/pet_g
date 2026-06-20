import 'package:equatable/equatable.dart';

abstract class HomeMapEvent extends Equatable {
  const HomeMapEvent();

  @override
  List<Object?> get props => [];
}

// Evento para solicitar los permisos de GPS y cargar la ubicación actual del dueño
class LoadCurrentLocation extends HomeMapEvent {}

// Evento cuando el usuario cambia de categoría en la barra superior (ej: de Cuidador a Guardería)
class FilterCategoryChanged extends HomeMapEvent {
  final String category;

  const FilterCategoryChanged({required this.category});

  @override
  List<Object?> get props => [category];
}