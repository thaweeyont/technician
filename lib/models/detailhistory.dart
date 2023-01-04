// To parse this JSON data, do
//
//     final detailHistory = detailHistoryFromJson(jsonString);

import 'dart:convert';

List<DetailHistory> detailHistoryFromJson(String str) =>
    List<DetailHistory>.from(
        json.decode(str).map((x) => DetailHistory.fromJson(x)));

String detailHistoryToJson(List<DetailHistory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DetailHistory {
  DetailHistory({
    this.idJob,
    this.idCardUser,
    this.idMechanic,
    this.idProductJoblog,
    this.addressGoProduct,
    this.dateGo,
    this.status,
    this.statusM,
    this.carateDate,
    this.updateDate,
    this.id,
    this.idcard,
    this.fullname,
    this.addressUser,
    this.phoneUser,
    this.createdDate,
    this.imgNamePath,
    this.date,
  });

  String? idJob;
  String? idCardUser;
  String? idMechanic;
  String? idProductJoblog;
  String? addressGoProduct;
  DateTime? dateGo;
  String? status;
  String? statusM;
  DateTime? carateDate;
  dynamic updateDate;
  String? id;
  String? idcard;
  String? fullname;
  String? addressUser;
  String? phoneUser;
  DateTime? createdDate;
  String? imgNamePath;
  String? date;

  factory DetailHistory.fromJson(Map<String, dynamic> json) => DetailHistory(
        idJob: json["id_job"] == null ? null : json["id_job"],
        idCardUser: json["id_card_user"] == null ? null : json["id_card_user"],
        idMechanic: json["id_mechanic"] == null ? null : json["id_mechanic"],
        idProductJoblog: json["id_product_joblog"] == null
            ? null
            : json["id_product_joblog"],
        addressGoProduct: json["address_go_product"] == null
            ? null
            : json["address_go_product"],
        dateGo:
            json["date_go"] == null ? null : DateTime.parse(json["date_go"]),
        status: json["status"] == null ? null : json["status"],
        statusM: json["status_m"] == null ? null : json["status_m"],
        carateDate: json["carate_date"] == null
            ? null
            : DateTime.parse(json["carate_date"]),
        updateDate: json["update_date"],
        id: json["id"] == null ? null : json["id"],
        idcard: json["idcard"] == null ? null : json["idcard"],
        fullname: json["fullname"] == null ? null : json["fullname"],
        addressUser: json["address_user"] == null ? null : json["address_user"],
        phoneUser: json["phone_user"] == null ? null : json["phone_user"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        imgNamePath:
            json["img_name_path"] == null ? null : json["img_name_path"],
        date: json["date"] == null ? null : json["date"],
      );

  Map<String, dynamic> toJson() => {
        "id_job": idJob == null ? null : idJob,
        "id_card_user": idCardUser == null ? null : idCardUser,
        "id_mechanic": idMechanic == null ? null : idMechanic,
        "id_product_joblog": idProductJoblog == null ? null : idProductJoblog,
        "address_go_product":
            addressGoProduct == null ? null : addressGoProduct,
        "date_go": dateGo == null
            ? null
            : "${dateGo!.year.toString().padLeft(4, '0')}-${dateGo!.month.toString().padLeft(2, '0')}-${dateGo!.day.toString().padLeft(2, '0')}",
        "status": status == null ? null : status,
        "status_m": statusM == null ? null : statusM,
        "carate_date":
            carateDate == null ? null : carateDate!.toIso8601String(),
        "update_date": updateDate,
        "id": id == null ? null : id,
        "idcard": idcard == null ? null : idcard,
        "fullname": fullname == null ? null : fullname,
        "address_user": addressUser == null ? null : addressUser,
        "phone_user": phoneUser == null ? null : phoneUser,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "img_name_path": imgNamePath == null ? null : imgNamePath,
        "date": date == null ? null : date,
      };
}
