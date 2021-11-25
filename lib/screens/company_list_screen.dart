import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/company.dart';
import '../models/station.dart';

import 'map_display_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({Key? key}) : super(key: key);

  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class Rail {
  bool isExpanded;
  String name;
  List data;

  Rail({required this.isExpanded, required this.name, required this.data});
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final _railList = <Rail>[];
  var _stationList = <Eki>[];

  /// 初期動作
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /// 初期データ作成
  void _makeDefaultDisplayData() async {
    var url = "http://toyohide.work/BrainLog/api/getTrainCompany";
    Map<String, String> headers = {'content-type': 'application/json'};
    var response = await http.post(Uri.parse(url), headers: headers);

    final company = companyFromJson(response.body);

    for (var i = 0; i < company.data.length; i++) {
      _railList.add(
        Rail(
          isExpanded: false,
          name: company.data[i].companyName,
          data: company.data[i].train,
        ),
      );
    }

    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: ListView(
                children: <Widget>[
                  Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: Colors.black.withOpacity(0.1),
                    ),
                    child: ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) {
                        _railList[index].isExpanded =
                            !_railList[index].isExpanded;
                        setState(() {});
                      },
                      children: _railList.map(_createPanel).toList(),
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
  ExpansionPanel _createPanel(Rail rail) {
    return ExpansionPanel(
      canTapOnHeader: true,
      //
      headerBuilder: (BuildContext context, bool isExpanded) {
        return Container(
          color: Colors.black.withOpacity(0.3),
          padding: const EdgeInsets.all(8.0),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  rail.name,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },

      //
      body: Container(
        width: double.infinity,
        color: Colors.white.withOpacity(0.1),
        padding: const EdgeInsets.all(10),
        child: _getTrainDataColumn(data: rail.data),
      ),

      //
      isExpanded: rail.isExpanded,
    );
  }

  ///
  Widget _getTrainDataColumn({data}) {
    List<Widget> _list = [];
    for (var i = 0; i < data.length; i++) {
      _list.add(
        Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data[i].trainName),
              GestureDetector(
                onTap: () => _showUnderMenu(
                  trainName: data[i].trainName,
                  trainNumber: data[i].trainNumber,
                ),
                child: const Icon(
                  Icons.train,
                  color: Colors.greenAccent,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTextStyle(
      style: const TextStyle(fontSize: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _list,
      ),
    );
  }

  ///
  Future<dynamic> _showUnderMenu({trainName, trainNumber}) {
    _getStation(trainNumber: trainNumber);

    return showModalBottomSheet(
      backgroundColor: Colors.black.withOpacity(0.1),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              border: Border(
                top: BorderSide(
                  color: Colors.yellowAccent.withOpacity(0.3),
                  width: 10,
                ),
              ),
            ),
            child: _getStationList(),
          ),
        );
      },
    );
  }

  ///
  void _getStation({trainNumber}) async {
    String url = "http://toyohide.work/BrainLog/api/getTrainStation";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({"train_number": trainNumber});
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    final station = stationFromJson(response.body);
    _stationList = station.data;
  }

  ///
  Widget _getStationList() {
    List<Widget> _list = [];
    for (var i = 0; i < _stationList.length; i++) {
      _list.add(
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: ListTile(
            title: DefaultTextStyle(
              style: const TextStyle(fontSize: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stationList[i].stationName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(_stationList[i].address),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_stationList[i].lat),
                      Text(_stationList[i].lng),
                    ],
                  ),
                ],
              ),
            ),
            trailing: GestureDetector(
                onTap: () => _goMapDisplayScreen(
                      stationLat: _stationList[i].lat,
                      stationLng: _stationList[i].lng,
                    ),
                child: const Icon(Icons.map)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 150),
      child: Column(
        children: _list,
      ),
    );
  }

  /////////////////////////////////////////////////////////

  ///
  void _goMapDisplayScreen(
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
