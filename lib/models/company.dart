// To parse this JSON data, do
//
//     final company = companyFromJson(jsonString);

import 'dart:convert';

Company companyFromJson(String str) => Company.fromJson(json.decode(str));

String companyToJson(Company data) => json.encode(data.toJson());

class Company {
  Company({
    required this.data,
  });

  List<Line> data;

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    data: List<Line>.from(json["data"].map((x) => Line.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Line {
  Line({
    required this.companyName,
    required this.train,
  });

  String companyName;
  List<Train> train;

  factory Line.fromJson(Map<String, dynamic> json) => Line(
    companyName: json["company_name"],
    train: List<Train>.from(json["train"].map((x) => Train.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "company_name": companyName,
    "train": List<dynamic>.from(train.map((x) => x.toJson())),
  };
}

class Train {
  Train({
    required this.trainNumber,
    required this.trainName,
  });

  String trainNumber;
  String trainName;

  factory Train.fromJson(Map<String, dynamic> json) => Train(
    trainNumber: json["train_number"],
    trainName: json["train_name"],
  );

  Map<String, dynamic> toJson() => {
    "train_number": trainNumber,
    "train_name": trainName,
  };
}
