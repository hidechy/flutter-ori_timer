// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'dart:async';

class MapDisplayScreen extends StatelessWidget {
  double lat;
  double lng;

  MapDisplayScreen({Key? key, required this.lat, required this.lng})
      : super(key: key);

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps View'),
      ),
      body: _MapDisplayScreen(
        lat: lat,
        lng: lng,
      ),
    );
  }
}

///
class _MapDisplayScreen extends HookWidget {
  double lat;
  double lng;

  _MapDisplayScreen({required this.lat, required this.lng});

  final Completer<GoogleMapController> _mapController = Completer();

  double _lat = 0.0;
  double _lng = 0.0;

  ///
  @override
  Widget build(BuildContext context) {
    Position _initialPosition = Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      altitude: 0,
      accuracy: 0,
      heading: 0,
      floor: null,
      speed: 0,
      speedAccuracy: 0,
    );

    final initialMarkers = {
      _initialPosition.timestamp.toString(): Marker(
        markerId: MarkerId(_initialPosition.timestamp.toString()),
        position: LatLng(_initialPosition.latitude, _initialPosition.longitude),
      ),
    };

    final position = useState<Position>(_initialPosition);

    final markers = useState<Map<String, Marker>>(initialMarkers);

    _setCurrentLocation(position, markers);
    _animateCamera(position);

    return Scaffold(
      body: SizedBox(
        height: 600,
        child: Column(
          children: [
            Row(
              children: [
                CircularCountDownTimer(
                  duration: 10,
                  width: MediaQuery.of(context).size.width / 10,
                  height: MediaQuery.of(context).size.height / 10,
                  ringColor: Colors.white,
                  fillColor: Colors.indigo,
                  onComplete: () => _goMapDisplayScreen(context: context),
                  textStyle: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_lat.toString()),
                    Text(_lng.toString()),
                  ],
                ),
              ],
            ),
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _initialPosition.latitude,
                    _initialPosition.longitude,
                  ),
                  zoom: 14.4746,
                ),
                onMapCreated: _mapController.complete,
                markers: markers.value.values.toSet(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  Future<void> _setCurrentLocation(ValueNotifier<Position> position,
      ValueNotifier<Map<String, Marker>> markers) async {
    final currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final marker = Marker(
      markerId: MarkerId(
        currentPosition.timestamp.toString(),
      ),
      position: LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
    );

    markers.value.clear();

    markers.value[currentPosition.timestamp.toString()] = marker;

    position.value = currentPosition;

    _lat = currentPosition.latitude;
    _lng = currentPosition.longitude;
  }

  ///
  Future<void> _animateCamera(ValueNotifier<Position> position) async {
    final mapController = await _mapController.future;

    await mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(
          position.value.latitude,
          position.value.longitude,
        ),
      ),
    );
  }

  ///
  void _goMapDisplayScreen({required context}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MapDisplayScreen(
          lat: _lat,
          lng: _lng,
        ),
      ),
    );
  }
}
