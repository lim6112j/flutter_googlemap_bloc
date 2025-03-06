part of 'routes_bloc.dart';

sealed class RouteEvent extends Equatable {
  const RouteEvent();
  @override
  List<Object> get props => [];
}

final class RouteLatLngChanged extends RouteEvent {
  const RouteLatLngChanged(this.latlng);
  final LatLng latlng;
  @override
  List<Object> get props => [latlng];
}
