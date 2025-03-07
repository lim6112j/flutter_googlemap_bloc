part of 'routes_bloc.dart';

final class RouteState extends Equatable {
  const RouteState({this.latlng = const LatLng(37.2, 127.5)});
  final LatLng latlng;
  RouteState copyWith({LatLng latlng = const LatLng(37.2, 127.5)}) {
    return RouteState(latlng: latlng);
  }

  @override
  List<Object?> get props => [latlng];
}
