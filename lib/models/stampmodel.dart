// To parse this JSON data, do
//
//     final stamp = stampFromJson(jsonString);

import 'dart:convert';

List<Stamp> stampFromJson(String str) =>
    List<Stamp>.from(json.decode(str).map((x) => Stamp.fromJson(x)));

String stampToJson(List<Stamp> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Stamp {
  Stamp({
    this.idStamp,
    this.idStaff,
    this.dateStamp,
    this.lat,
    this.lng,
    this.statusStamp,
    this.createdDate,
    this.updateDate,
  });

  String? idStamp;
  String? idStaff;
  DateTime? dateStamp;
  String? lat;
  String? lng;
  String? statusStamp;
  DateTime? createdDate;
  DateTime? updateDate;

  factory Stamp.fromJson(Map<String, dynamic> json) => Stamp(
        idStamp: json["id_stamp"] == null ? null : json["id_stamp"],
        idStaff: json["id_staff"] == null ? null : json["id_staff"],
        dateStamp: json["date_stamp"] == null
            ? null
            : DateTime.parse(json["date_stamp"]),
        lat: json["lat"] == null ? null : json["lat"],
        lng: json["lng"] == null ? null : json["lng"],
        statusStamp: json["status_stamp"] == null ? null : json["status_stamp"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"] == null
            ? null
            : DateTime.parse(json["update_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id_stamp": idStamp == null ? null : idStamp,
        "id_staff": idStaff == null ? null : idStaff,
        "date_stamp": dateStamp == null
            ? null
            : "${dateStamp!.year.toString().padLeft(4, '0')}-${dateStamp!.month.toString().padLeft(2, '0')}-${dateStamp!.day.toString().padLeft(2, '0')}",
        "lat": lat == null ? null : lat,
        "lng": lng == null ? null : lng,
        "status_stamp": statusStamp == null ? null : statusStamp,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date":
            updateDate == null ? null : updateDate!.toIso8601String(),
      };
}
