import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../models/company.dart';

import '../utility/utility.dart';

import 'station_list_screen.dart';
import 'company_setting_screen.dart';
import 'train_route_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({Key? key}) : super(key: key);

  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class Rail {
  bool isExpanded;
  int id;
  String name;
  List data;

  Rail(
      {required this.isExpanded,
      required this.id,
      required this.name,
      required this.data});
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final _railList = <Rail>[];

  final Utility _utility = Utility();

  final List<String> _selectedList = [];

  final List<String> _selectedList2 = [];

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
      if (company.data[i].flag == '0') {
        continue;
      }

      _railList.add(
        Rail(
          isExpanded: false,
          id: company.data[i].companyId,
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          _utility.getBackGround(context: context),
          Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _goCompanyListScreen(),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => _goCompanySettingScreen(),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goTrainRouteScreen(),
                  child: const Text('display train route'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.pinkAccent.withOpacity(0.8),
                  ),
                ),
              ),
            ],
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
            child: Text(
              //'${rail.id}${rail.name}',
              rail.name,
              style: const TextStyle(fontSize: 12),
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
      if (data[i].pickup == '1') {
        _selectedList2.add(data[i].trainNumber);
      }

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
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color:
                        _getSelectedBgColor2(trainNumber: data[i].trainNumber),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(data[i].trainName),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () =>
                        _addSelectedAry(trainNumber: data[i].trainNumber),
                    child: Icon(
                      Icons.vignette_rounded,
                      color:
                          _getSelectedBgColor(trainNumber: data[i].trainNumber),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => _goStationListScreen(
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
  void _addSelectedAry({trainNumber}) {
    if (_selectedList.contains(trainNumber)) {
      _selectedList.remove(trainNumber);
    } else {
      _selectedList.add(trainNumber);
    }

    setState(() {});
  }

  ///
  Color _getSelectedBgColor({trainNumber}) {
    if (_selectedList.contains(trainNumber)) {
      return Colors.yellowAccent;
    } else {
      return Colors.white.withOpacity(0.3);
    }
  }

  ///
  void _addSelectedAry2({trainNumber}) {
    if (_selectedList2.contains(trainNumber)) {
      _selectedList2.remove(trainNumber);
    } else {
      _selectedList2.add(trainNumber);
    }

    setState(() {});
  }

  ///
  Color _getSelectedBgColor2({trainNumber}) {
    if (_selectedList2.contains(trainNumber)) {
      return Colors.orangeAccent;
    } else {
      return Colors.white.withOpacity(0.3);
    }
  }

  /////////////////////////////////////////////////////////

  ///
  void _goCompanyListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CompanyListScreen(),
      ),
    );
  }

  ///
  void _goStationListScreen(
      {required String trainName, required String trainNumber}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationListScreen(
          trainName: trainName,
          trainNumber: trainNumber,
        ),
      ),
    );
  }

  ///
  void _goCompanySettingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompanySettingScreen(),
      ),
    );
  }

  ///
  void _goTrainRouteScreen() {
    if (_selectedList.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainRouteScreen(
            trainNumberList: _selectedList,
          ),
        ),
      );
    }
  }
}
