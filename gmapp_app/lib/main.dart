import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Wiggle Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _initialPosition = LatLng(13.0827, 80.2707); // Chennai, TN
  late GoogleMapController _mapController;
  double _currentZoom = 12.0;

  void _onMarkerTapped() async {
    // Zoom in for wiggle effect
    await _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _initialPosition, zoom: _currentZoom + 2),
    ));

    await Future.delayed(Duration(milliseconds: 400));

    // Zoom out to original
    await _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _initialPosition, zoom: _currentZoom),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Maps Wiggle - Tamil Nadu')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: _currentZoom,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: {
          Marker(
            markerId: MarkerId('wiggle_marker'),
            position: _initialPosition,
            onTap: _onMarkerTapped,
            infoWindow: InfoWindow(title: 'Vanakkam! Tap Me to Wiggle 🌀'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          ),
        },
      ),
    );
  }
}
