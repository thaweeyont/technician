// To parse this JSON data, do
//
//     final staff = staffFromJson(jsonString);

import 'dart:convert';

List<Staff> staffFromJson(String str) =>
    List<Staff>.from(json.decode(str).map((x) => Staff.fromJson(x)));

String staffToJson(List<Staff> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Staff {
  Staff({
    this.id,
    this.idStaff,
    this.idBranch,
    this.fullnameStaff,
    this.phoneStaff,
    this.statusStaff,
    this.createdDate,
    this.updateDate,
    this.statusShow,
    this.initialsBranch,
    this.nameBranch,
    this.zone,
    this.latBranch,
    this.lngBranch,
    this.statusBranch,
  });

  String? id;
  String? idStaff;
  String? idBranch;
  String? fullnameStaff;
  String? phoneStaff;
  String? statusStaff;
  DateTime? createdDate;
  dynamic updateDate;
  String? statusShow;
  String? initialsBranch;
  String? nameBranch;
  String? zone;
  String? latBranch;
  String? lngBranch;
  String? statusBranch;

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json["id"] == null ? null : json["id"],
        idStaff: json["id_staff"] == null ? null : json["id_staff"],
        idBranch: json["id_branch"] == null ? null : json["id_branch"],
        fullnameStaff:
            json["fullname_staff"] == null ? null : json["fullname_staff"],
        phoneStaff: json["phone_staff"] == null ? null : json["phone_staff"],
        statusStaff: json["status_staff"] == null ? null : json["status_staff"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"],
        statusShow: json["status_show"] == null ? null : json["status_show"],
        initialsBranch:
            json["initials_branch"] == null ? null : json["initials_branch"],
        nameBranch: json["name_branch"] == null ? null : json["name_branch"],
        zone: json["zone"] == null ? null : json["zone"],
        latBranch: json["lat_branch"] == null ? null : json["lat_branch"],
        lngBranch: json["lng_branch"] == null ? null : json["lng_branch"],
        statusBranch:
            json["status_branch"] == null ? null : json["status_branch"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "id_staff": idStaff == null ? null : idStaff,
        "id_branch": idBranch == null ? null : idBranch,
        "fullname_staff": fullnameStaff == null ? null : fullnameStaff,
        "phone_staff": phoneStaff == null ? null : phoneStaff,
        "status_staff": statusStaff == null ? null : statusStaff,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date": updateDate,
        "status_show": statusShow == null ? null : statusShow,
        "initials_branch": initialsBranch == null ? null : initialsBranch,
        "name_branch": nameBranch == null ? null : nameBranch,
        "zone": zone == null ? null : zone,
        "lat_branch": latBranch == null ? null : latBranch,
        "lng_branch": lngBranch == null ? null : lngBranch,
        "status_branch": statusBranch == null ? null : statusBranch,
      };
}
