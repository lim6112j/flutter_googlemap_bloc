part of 'routes_bloc.dart';

final class RouteState extends Equatable {
  const RouteState({this.latlng = const LatLng(37.2, 127.5)});
  final LatLng latlng;
  RouteState copyWith({LatLng? latlng}) {
    return RouteState(latlng: this.latlng);
  }

  @override
  List<Object?> get props => throw UnimplementedError();
}
