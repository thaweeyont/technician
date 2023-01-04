// To parse this JSON data, do
//
//     final addressUser = addressUserFromJson(jsonString);

import 'dart:convert';

List<AddressUser> addressUserFromJson(String str) => List<AddressUser>.from(
    json.decode(str).map((x) => AddressUser.fromJson(x)));

String addressUserToJson(List<AddressUser> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddressUser {
  AddressUser({
    this.idUserAddress,
    this.idCardUser,
    this.nameUserAddress,
    this.lat,
    this.lng,
    this.provinces,
    this.amphures,
    this.districts,
    this.addressUser,
    this.createdDate,
    this.updateDate,
    this.id,
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

  String? idUserAddress;
  String? idCardUser;
  String? nameUserAddress;
  String? lat;
  String? lng;
  String? provinces;
  String? amphures;
  String? districts;
  String? addressUser;
  DateTime? createdDate;
  dynamic updateDate;
  String? id;
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

  factory AddressUser.fromJson(Map<String, dynamic> json) => AddressUser(
        idUserAddress:
            json["id_user_address"] == null ? null : json["id_user_address"],
        idCardUser: json["id_card_user"] == null ? null : json["id_card_user"],
        nameUserAddress: json["name_user_address"] == null
            ? null
            : json["name_user_address"],
        lat: json["lat"] == null ? null : json["lat"],
        lng: json["lng"] == null ? null : json["lng"],
        provinces: json["provinces"] == null ? null : json["provinces"],
        amphures: json["amphures"] == null ? null : json["amphures"],
        districts: json["districts"] == null ? null : json["districts"],
        addressUser: json["address_user"] == null ? null : json["address_user"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"],
        id: json["id"] == null ? null : json["id"],
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
        "id_user_address": idUserAddress == null ? null : idUserAddress,
        "id_card_user": idCardUser == null ? null : idCardUser,
        "name_user_address": nameUserAddress == null ? null : nameUserAddress,
        "lat": lat == null ? null : lat,
        "lng": lng == null ? null : lng,
        "provinces": provinces == null ? null : provinces,
        "amphures": amphures == null ? null : amphures,
        "districts": districts == null ? null : districts,
        "address_user": addressUser == null ? null : addressUser,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date": updateDate,
        "id": id == null ? null : id,
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
