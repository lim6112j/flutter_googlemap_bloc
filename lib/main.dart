import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => MyAppState();
}
Stream<T> streamDelayer<T>(Stream<T> inputStream, Duration delay) async* {
  await for (final val in inputStream) {
    yield val;
    await Future.delayed(delay);
  }
}
StreamController<LatLng> streamController = StreamController<LatLng>();
Stream stream = streamDelayer(streamController.stream, Duration(seconds: 3));


class MyAppState extends State<MyApp> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, 137.085749655962),
    zoom: 14.4746,
  );

  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: markers,
          onTap: _mapTap,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToTheLake,
          label: const Text('To the lake!'),
          icon: const Icon(Icons.directions_boat),
        ),
      ),
    );
  }

  Future<void> _mapTap(LatLng latlng) async {
    streamController.add(latlng);
    streamController.add(latlng);
    streamController.add(latlng);
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
    stream.listen((value) {
      print('1st sub: $value');
    });
    await controller.animateCamera(CameraUpdate.newCameraPosition(kLake));
  }
}

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
