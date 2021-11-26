// ignore_for_file: use_key_in_widget_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

import 'dart:convert';

import '../models/station.dart';

class TrainRouteScreen extends StatefulWidget {
  final List<String> trainNumberList;

  const TrainRouteScreen({required this.trainNumberList});

  @override
  _TrainRouteScreenState createState() => _TrainRouteScreenState();
}

class _TrainRouteScreenState extends State<TrainRouteScreen> {
  late LatLng _latLng;

  Map<String, String> headers = {'content-type': 'application/json'};

  final Set<Marker> _markerSets = {};

  final List<Eki> _ekiList = [];

  /// 初期動作
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /// 初期データ作成
  void _makeDefaultDisplayData() async {
    ///////////////////////////////////
    for (var i = 0; i < widget.trainNumberList.length; i++) {
      String url = "http://toyohide.work/BrainLog/api/getTrainStation";
      String body = json.encode({"train_number": widget.trainNumberList[i]});
      Response response =
          await post(Uri.parse(url), headers: headers, body: body);
      final station = stationFromJson(response.body);
      for (var j = 0; j < station.data.length; j++) {
        station.data[j].lineNumber = i;
        _ekiList.add(station.data[j]);
      }
    }
    ///////////////////////////////////
    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    _latLng = const LatLng(35.7102009, 139.9490672);

    CameraPosition _initialCameraPosition =
        CameraPosition(target: _latLng, zoom: 11);

    for (var i = 0; i < _ekiList.length; i++) {
      _markerSets.add(
        Marker(
          markerId: MarkerId('id-$i'),
          position: LatLng(
            double.parse(_ekiList[i].lat),
            double.parse(_ekiList[i].lng),
          ),
          infoWindow: InfoWindow(
            title: _ekiList[i].stationName,
            snippet: _ekiList[i].address,
          ),
          icon: _getMapIcon(line_number: _ekiList[i].lineNumber),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'train route',
          style: TextStyle(fontSize: 12),
        ),

        centerTitle: true,

        //-------------------------//これを消すと「←」が出てくる（消さない）
        leading: const Icon(
          Icons.check_box_outline_blank,
          color: Color(0xFF2e2e2e),
        ),
        //-------------------------//これを消すと「←」が出てくる（消さない）

        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: Colors.greenAccent,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              markers: _markerSets,
            ),
          ),
        ],
      ),
    );
  }

  ///
  BitmapDescriptor _getMapIcon({required int line_number}) {
    switch (line_number) {
      case 0:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

      case 1:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

      case 2:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

      case 3:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);

      case 4:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet);

      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }
}
