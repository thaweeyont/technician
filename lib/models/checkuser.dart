// To parse this JSON data, do
//
//     final checkUser = checkUserFromJson(jsonString);

import 'dart:convert';

List<CheckUser> checkUserFromJson(String str) =>
    List<CheckUser>.from(json.decode(str).map((x) => CheckUser.fromJson(x)));

String checkUserToJson(List<CheckUser> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CheckUser {
  CheckUser({
    this.id,
    this.idcard,
    this.fullname,
    this.addressUser,
    this.provincesU,
    this.amphuresU,
    this.districtsU,
    this.phoneUser,
    this.lat,
    this.lng,
    this.status,
    this.token,
    this.createdDate,
    this.updateDate,
    this.code,
    this.nameTh,
    this.nameEn,
    this.geographyId,
    this.provinceId,
    this.zipCode,
    this.amphureId,
    this.idProvinces,
    this.nameProvinces,
    this.idAmphures,
    this.nameAmphures,
    this.idDistricts,
    this.nameDistricts,
  });

  String? id;
  String? idcard;
  String? fullname;
  String? addressUser;
  String? provincesU;
  String? amphuresU;
  String? districtsU;
  String? phoneUser;
  dynamic lat;
  dynamic lng;
  String? status;
  String? token;
  DateTime? createdDate;
  dynamic updateDate;
  String? code;
  String? nameTh;
  String? nameEn;
  String? geographyId;
  String? provinceId;
  String? zipCode;
  String? amphureId;
  String? idProvinces;
  String? nameProvinces;
  String? idAmphures;
  String? nameAmphures;
  String? idDistricts;
  String? nameDistricts;

  factory CheckUser.fromJson(Map<String, dynamic> json) => CheckUser(
        id: json["id"] == null ? null : json["id"],
        idcard: json["idcard"] == null ? null : json["idcard"],
        fullname: json["fullname"] == null ? null : json["fullname"],
        addressUser: json["address_user"] == null ? null : json["address_user"],
        provincesU: json["provinces_u"] == null ? null : json["provinces_u"],
        amphuresU: json["amphures_u"] == null ? null : json["amphures_u"],
        districtsU: json["districts_u"] == null ? null : json["districts_u"],
        phoneUser: json["phone_user"] == null ? null : json["phone_user"],
        lat: json["lat"],
        lng: json["lng"],
        status: json["status"] == null ? null : json["status"],
        token: json["Token"] == null ? null : json["Token"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"],
        code: json["code"] == null ? null : json["code"],
        nameTh: json["name_th"] == null ? null : json["name_th"],
        nameEn: json["name_en"] == null ? null : json["name_en"],
        geographyId: json["geography_id"] == null ? null : json["geography_id"],
        provinceId: json["province_id"] == null ? null : json["province_id"],
        zipCode: json["zip_code"] == null ? null : json["zip_code"],
        amphureId: json["amphure_id"] == null ? null : json["amphure_id"],
        idProvinces: json["id_provinces"] == null ? null : json["id_provinces"],
        nameProvinces:
            json["name_provinces"] == null ? null : json["name_provinces"],
        idAmphures: json["id_amphures"] == null ? null : json["id_amphures"],
        nameAmphures:
            json["name_amphures"] == null ? null : json["name_amphures"],
        idDistricts: json["id_districts"] == null ? null : json["id_districts"],
        nameDistricts:
            json["name_districts"] == null ? null : json["name_districts"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "idcard": idcard == null ? null : idcard,
        "fullname": fullname == null ? null : fullname,
        "address_user": addressUser == null ? null : addressUser,
        "provinces_u": provincesU == null ? null : provincesU,
        "amphures_u": amphuresU == null ? null : amphuresU,
        "districts_u": districtsU == null ? null : districtsU,
        "phone_user": phoneUser == null ? null : phoneUser,
        "lat": lat,
        "lng": lng,
        "status": status == null ? null : status,
        "Token": token == null ? null : token,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date": updateDate,
        "code": code == null ? null : code,
        "name_th": nameTh == null ? null : nameTh,
        "name_en": nameEn == null ? null : nameEn,
        "geography_id": geographyId == null ? null : geographyId,
        "province_id": provinceId == null ? null : provinceId,
        "zip_code": zipCode == null ? null : zipCode,
        "amphure_id": amphureId == null ? null : amphureId,
        "id_provinces": idProvinces == null ? null : idProvinces,
        "name_provinces": nameProvinces == null ? null : nameProvinces,
        "id_amphures": idAmphures == null ? null : idAmphures,
        "name_amphures": nameAmphures == null ? null : nameAmphures,
        "id_districts": idDistricts == null ? null : idDistricts,
        "name_districts": nameDistricts == null ? null : nameDistricts,
      };
}
