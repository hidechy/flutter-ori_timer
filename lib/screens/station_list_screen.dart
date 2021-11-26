import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/station.dart';

import 'map_display_screen.dart';

class StationListScreen extends StatefulWidget {
  String trainName;
  String trainNumber;

  StationListScreen({required this.trainName, required this.trainNumber});

  @override
  _StationListScreenState createState() => _StationListScreenState();
}

class _StationListScreenState extends State<StationListScreen> {
  var _stationList = <Eki>[];

  /// 初期動作
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /// 初期データ作成
  void _makeDefaultDisplayData() async {
    String url = "http://toyohide.work/BrainLog/api/getTrainStation";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({"train_number": widget.trainNumber});
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    final station = stationFromJson(response.body);
    _stationList = station.data;

    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainName),

        backgroundColor: Colors.transparent,

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
            child: _makeStationList(),
          ),
        ],
      ),
    );
  }

  ///
  Widget _makeStationList() {
    return ListView.separated(
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stationList[index].stationName,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(_stationList[index].address),
                  Row(
                    children: [
                      Text(_stationList[index].lat),
                      SizedBox(
                        width: 40,
                      ),
                      Text(_stationList[index].lng),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _goMapDisplayScreen(
                  stationLat: _stationList[index].lat,
                  stationLng: _stationList[index].lng,
                ),
                child: const Icon(Icons.map),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 0.2),
      itemCount: _stationList.length,
    );
  }

  /////////////////////////////////////////////////////

  ///
  _goMapDisplayScreen(
      {required String stationLat, required String stationLng}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapDisplayScreen(
          lat: 35.658034,
          lng: 139.701636,
          stationLat: double.parse(stationLat),
          stationLng: double.parse(stationLng),
        ),
      ),
    );
  }
}
