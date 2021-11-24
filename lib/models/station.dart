// To parse this JSON data, do
//
//     final station = stationFromJson(jsonString);

import 'dart:convert';

Station stationFromJson(String str) => Station.fromJson(json.decode(str));

String stationToJson(Station data) => json.encode(data.toJson());

class Station {
  Station({
    required this.data,
  });

  List<Eki> data;

  factory Station.fromJson(Map<String, dynamic> json) => Station(
    data: List<Eki>.from(json["data"].map((x) => Eki.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Eki {
  Eki({
    required this.stationName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.lineNumber,
  });

  String stationName;
  String address;
  String lat;
  String lng;
  int lineNumber;

  factory Eki.fromJson(Map<String, dynamic> json) => Eki(
    stationName: json["station_name"],
    address: json["address"],
    lat: json["lat"],
    lng: json["lng"],
    lineNumber: json["line_number"],
  );

  Map<String, dynamic> toJson() => {
    "station_name": stationName,
    "address": address,
    "lat": lat,
    "lng": lng,
    "line_number": lineNumber,
  };
}