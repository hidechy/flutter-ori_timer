// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import '../utility/MapStyle.dart';

class MapDisplayScreen extends StatelessWidget {
  double lat;
  double lng;
  double stationLat;
  double stationLng;

  MapDisplayScreen(
      {Key? key,
      required this.lat,
      required this.lng,
      required this.stationLat,
      required this.stationLng})
      : super(key: key);

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _MapDisplayScreen(
        lat: lat,
        lng: lng,
        stationLat: stationLat,
        stationLng: stationLng,
      ),
    );
  }
}

///
class _MapDisplayScreen extends HookWidget {
  double lat;
  double lng;
  double stationLat;
  double stationLng;

  _MapDisplayScreen(
      {required this.lat,
      required this.lng,
      required this.stationLat,
      required this.stationLng});

  final Completer<GoogleMapController> _mapController = Completer();

  double _lat = 0.0;
  double _lng = 0.0;

  ///
  @override
  Widget build(BuildContext context) {
    //-----------------------------------------------//
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

    final distance = useState("");

    _setCurrentLocation(position, markers, distance);
    _animateCamera(position);
    //-----------------------------------------------//

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _initialPosition.latitude,
                _initialPosition.longitude,
              ),
              zoom: 14.4746,
            ),
            //onMapCreated: _mapController.complete,
            onMapCreated: _onMapCreated,
            markers: markers.value.values.toSet(),
            zoomControlsEnabled: false,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue.withOpacity(0.1),
            ),
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
              ),
              child: Row(
                children: [
                  CircularCountDownTimer(
                    duration: 10,
                    width: MediaQuery.of(context).size.width / 10,
                    height: MediaQuery.of(context).size.height / 10,
                    ringColor: Colors.grey.withOpacity(0.3),
                    fillColor: Colors.indigo,
                    onComplete: () => _goMapDisplayScreen(context: context),
                    textStyle: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 30),
                  DefaultTextStyle(
                    style: const TextStyle(color: Colors.black),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_lat.toString()),
                        Text(_lng.toString()),
                        Text(distance.value),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  void _onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(MapStyle.mapStyle);
  }

  ///
  Future<void> _setCurrentLocation(
      ValueNotifier<Position> position,
      ValueNotifier<Map<String, Marker>> markers,
      ValueNotifier<String> distance) async {
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

    //>>>>>>>>>>>>>>>>>>>>>>>>>>>//
    var origin = "$_lat,$_lng";
    var destination = "$stationLat,$stationLng";
    String apiKey = 'AIzaSyD9PkTM1Pur3YzmO-v4VzS0r8ZZ0jRJTIU';
    String url2 =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=walking&language=ja&key=$apiKey';
    var response2 = await http.get(Uri.parse(url2));

    if (response2.statusCode == 200) {
      var decoded = jsonDecode(response2.body);

      if (decoded['routes'].length > 0) {
        var data = decoded['routes'][0];

        if ((data['legs'] as List).isNotEmpty) {
          final leg = data['legs'][0];
          distance.value = leg['distance']['text'];
        }
      }
    }

    //>>>>>>>>>>>>>>>>>>>>>>>>>>>//
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

  /////////////////////////////////////////////////////

  ///
  void _goMapDisplayScreen({required context}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MapDisplayScreen(
          lat: _lat,
          lng: _lng,
          stationLat: stationLat,
          stationLng: stationLng,
        ),
      ),
    );
  }
}
