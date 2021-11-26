import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';

import 'dart:convert';

import '../models/company.dart';

class CompanySettingScreen extends StatefulWidget {
  const CompanySettingScreen({Key? key}) : super(key: key);

  @override
  _CompanySettingScreenState createState() => _CompanySettingScreenState();
}

class _CompanySettingScreenState extends State<CompanySettingScreen> {
  List _lineList = <Line>[];

  final List<int> _selectedList = [];

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
    _lineList = company.data;

    for (var i = 0; i < _lineList.length; i++) {
      if (_lineList[i].flag == '0') {
        _selectedList.add(_lineList[i].companyId);
      }
    }

    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.close,
                color: Colors.greenAccent,
              ),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return Card(
                    color: _getSelectedBgColor(company: _lineList[index]),
                    child: ListTile(
                      title: DefaultTextStyle(
                        style: const TextStyle(fontSize: 12),
                        child: Text(_lineList[index].companyName),
                      ),
                      onTap: () => _addSelectedAry(company: _lineList[index]),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 0.2),
                itemCount: _lineList.length,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateCompanyFlag(),
              child: const Text('update'),
              style: ElevatedButton.styleFrom(
                primary: Colors.pinkAccent.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  void _addSelectedAry({company}) {
    if (_selectedList.contains(company.companyId)) {
      _selectedList.remove(company.companyId);
    } else {
      _selectedList.add(company.companyId);
    }

    setState(() {});
  }

  ///
  Color _getSelectedBgColor({company}) {
    if (_selectedList.contains(company.companyId)) {
      return Colors.black.withOpacity(0.3);
    } else {
      return Colors.yellowAccent.withOpacity(0.3);
    }
  }

  ///
  void _updateCompanyFlag() async {
    if (_selectedList.isNotEmpty) {
      String url = "http://toyohide.work/BrainLog/api/updateTrainFlag";
      Map<String, String> headers = {'content-type': 'application/json'};
      String body = json.encode({"flags": _selectedList.join(',')});
      await http.post(Uri.parse(url), headers: headers, body: body);

      Fluttertoast.showToast(
        msg: "更新が完了しました",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );

      Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
    }

    setState(() {});
  }
}
