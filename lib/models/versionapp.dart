// To parse this JSON data, do
//
//     final version = versionFromJson(jsonString);

import 'dart:convert';

List<Version> versionFromJson(String str) =>
    List<Version>.from(json.decode(str).map((x) => Version.fromJson(x)));

String versionToJson(List<Version> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Version {
  Version({
    this.idVersion,
    this.version,
    this.urlVersion,
    this.statusVersion,
    this.createdDate,
    this.updateDate,
  });

  String? idVersion;
  String? version;
  String? urlVersion;
  String? statusVersion;
  DateTime? createdDate;
  DateTime? updateDate;

  factory Version.fromJson(Map<String, dynamic> json) => Version(
        idVersion: json["id_version"] == null ? null : json["id_version"],
        version: json["version"] == null ? null : json["version"],
        urlVersion: json["url_version"] == null ? null : json["url_version"],
        statusVersion:
            json["status_version"] == null ? null : json["status_version"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"] == null
            ? null
            : DateTime.parse(json["update_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id_version": idVersion == null ? null : idVersion,
        "version": version == null ? null : version,
        "url_version": urlVersion == null ? null : urlVersion,
        "status_version": statusVersion == null ? null : statusVersion,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date":
            updateDate == null ? null : updateDate!.toIso8601String(),
      };
}
