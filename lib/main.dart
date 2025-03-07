import 'dart:async';
import 'package:cielai_googlemap/routes/bloc/routes_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => RoutesBloc(), child: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, 137.085749655962),
    zoom: 14.4746,
  );

  late Set<Marker> markers;
  late Polyline polyline;
  late List<LatLng> latlngs;
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    markers = {};
    latlngs = [];
    polyline = Polyline(polylineId: PolylineId("poly"), points: latlngs);
    _scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('markers : $markers');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Column(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocConsumer<RoutesBloc, RouteState>(
                  listener: (context, state) async {
                    CameraPosition pos = CameraPosition(
                      bearing: 192.8334901395799,
                      target: state.latlng,
                      tilt: 59.440717697143555,
                      zoom: 19.151926040649414,
                    );
                    final GoogleMapController controller =
                        await _controller.future;
                    await controller.animateCamera(
                      CameraUpdate.newCameraPosition(pos),
                    );
                  },
                  builder: (context, state) {
                    Marker marker = Marker(
                      markerId: MarkerId("random"),
                      position: state.latlng,
                    );
                    for (var item in markers) {
                      latlngs.add(item.position);
                    }
                    latlngs.add(state.latlng);
                    polyline = Polyline(
                      polylineId: PolylineId("poly"),
                      points: latlngs,
                    );
                    print('current latlngs : $latlngs');
                    markers.clear();
                    markers.add(marker);
                    return GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      polylines: {polyline},
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      markers: markers,
                      onTap: (latlng) {
                        _mapTap(context.read<RoutesBloc>(), latlng);
                      },
                    );
                  },
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: BlocBuilder<RoutesBloc, RouteState>(
                builder: (context, state) {
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: polyline.points.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 50,
                        color: Colors.amber[600],
                        child: Center(child: Text('${polyline.points[index]}')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToTheLake,
          label: const Text('To the lake!'),
          icon: const Icon(Icons.directions_boat),
        ),
      ),
    );
  }

  Future<void> addEvents(RoutesBloc bloc, LatLng latlng) async {
    bloc.add(RouteLatLngChanged(latlng));
    await Future.delayed(Duration(seconds: 2));
    bloc.add(
      RouteLatLngChanged(
        LatLng(latlng.latitude + 0.0001, latlng.longitude + 0.0001),
      ),
    );
    await Future.delayed(Duration(seconds: 2));
    bloc.add(
      RouteLatLngChanged(
        LatLng(latlng.latitude + 0.0002, latlng.longitude + 0.0002),
      ),
    );
    await Future.delayed(Duration(seconds: 2));
    bloc.add(
      RouteLatLngChanged(
        LatLng(latlng.latitude + 0.0003, latlng.longitude + 0.0003),
      ),
    );
    await Future.delayed(Duration(seconds: 2));
    bloc.add(
      RouteLatLngChanged(
        LatLng(latlng.latitude + 0.0004, latlng.longitude + 0.0004),
      ),
    );
    await Future.delayed(Duration(seconds: 2));
    bloc.add(
      RouteLatLngChanged(
        LatLng(latlng.latitude + 0.0005, latlng.longitude + 0.0005),
      ),
    );
  }

  Future<void> _mapTap(RoutesBloc bloc, LatLng latlng) async {
    addEvents(bloc, latlng);
    CameraPosition pos = CameraPosition(
      bearing: 192.8334901395799,
      target: latlng,
      tilt: 59.440717697143555,
      zoom: 19.151926040649414,
    );

    setState(() {
      markers.clear();
      markers.add(Marker(markerId: MarkerId("random"), position: latlng));
    });
    print('current markers : $markers');
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(pos));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    Position userLocation = await _determinePosition();
    double lat = userLocation.latitude;
    double lon = userLocation.longitude;
    CameraPosition kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(lat, lon),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(kLake));
  }
}

class _scrollController extends ScrollController {}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
