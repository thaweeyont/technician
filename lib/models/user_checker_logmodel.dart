// To parse this JSON data, do
//
//     final userCheckerLogModel = userCheckerLogModelFromJson(jsonString);

import 'dart:convert';

List<UserCheckerLogModel> userCheckerLogModelFromJson(String str) =>
    List<UserCheckerLogModel>.from(
        json.decode(str).map((x) => UserCheckerLogModel.fromJson(x)));

String userCheckerLogModelToJson(List<UserCheckerLogModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserCheckerLogModel {
  UserCheckerLogModel({
    this.idUser,
    this.uname,
    this.pws,
    this.levelStatus,
    this.zone,
    this.saka,
    this.nameUser,
  });

  String? idUser;
  String? uname;
  String? pws;
  String? levelStatus;
  String? zone;
  String? saka;
  String? nameUser;

  factory UserCheckerLogModel.fromJson(Map<String, dynamic> json) =>
      UserCheckerLogModel(
        idUser: json["id_user"] == null ? null : json["id_user"],
        uname: json["uname"] == null ? null : json["uname"],
        pws: json["pws"] == null ? null : json["pws"],
        levelStatus: json["level_status"] == null ? null : json["level_status"],
        zone: json["zone"] == null ? null : json["zone"],
        saka: json["saka"] == null ? null : json["saka"],
        nameUser: json["name_user"] == null ? null : json["name_user"],
      );

  Map<String, dynamic> toJson() => {
        "id_user": idUser == null ? null : idUser,
        "uname": uname == null ? null : uname,
        "pws": pws == null ? null : pws,
        "level_status": levelStatus == null ? null : levelStatus,
        "zone": zone == null ? null : zone,
        "saka": saka == null ? null : saka,
        "name_user": nameUser == null ? null : nameUser,
      };
}
