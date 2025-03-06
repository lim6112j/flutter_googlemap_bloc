import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'routes_event.dart';
part 'routes_state.dart';

class RoutesBloc extends Bloc<RouteEvent, RouteState> {
  RoutesBloc() : super(const RouteState()) {
    on<RouteLatLngChanged>(_onLatLngChanged);
  }

  FutureOr<void> _onLatLngChanged(
    RouteLatLngChanged event,
    Emitter<RouteState> emit,
  ) {
    final latlng = event.latlng;
    emit(state.copyWith(latlng: latlng));
  }
}
