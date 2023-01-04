// To parse this JSON data, do
//
//     final productHeadDataAll = productHeadDataAllFromJson(jsonString);

import 'dart:convert';

List<ProductHeadDataAll> productHeadDataAllFromJson(String str) =>
    List<ProductHeadDataAll>.from(
        json.decode(str).map((x) => ProductHeadDataAll.fromJson(x)));

String productHeadDataAllToJson(List<ProductHeadDataAll> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductHeadDataAll {
  ProductHeadDataAll({
    this.idJob,
    this.idJobHead,
    this.idCardUser,
    this.idMechanic,
    this.idSale,
    this.idCredit,
    this.addressDeliver,
    this.provinces,
    this.amphures,
    this.districts,
    this.dateTimeInstall,
    this.productTypeContract,
    this.latJob,
    this.lngJob,
    this.dateGotoSt,
    this.dateinput,
    this.statusJob,
    this.cratedDate,
    this.updateDate,
  });

  String? idJob;
  String? idJobHead;
  String? idCardUser;
  dynamic idMechanic;
  String? idSale;
  dynamic idCredit;
  String? addressDeliver;
  String? provinces;
  String? amphures;
  String? districts;
  dynamic dateTimeInstall;
  String? productTypeContract;
  dynamic latJob;
  dynamic lngJob;
  String? dateGotoSt;
  String? dateinput;
  String? statusJob;
  DateTime? cratedDate;
  DateTime? updateDate;

  factory ProductHeadDataAll.fromJson(Map<String, dynamic> json) =>
      ProductHeadDataAll(
        idJob: json["id_job"] == null ? null : json["id_job"],
        idJobHead: json["id_job_head"] == null ? null : json["id_job_head"],
        idCardUser: json["id_card_user"] == null ? null : json["id_card_user"],
        idMechanic: json["id_mechanic"],
        idSale: json["id_sale"] == null ? null : json["id_sale"],
        idCredit: json["id_credit"],
        addressDeliver:
            json["address_deliver"] == null ? null : json["address_deliver"],
        provinces: json["provinces"] == null ? null : json["provinces"],
        amphures: json["amphures"] == null ? null : json["amphures"],
        districts: json["districts"] == null ? null : json["districts"],
        dateTimeInstall: json["date_time_install"],
        productTypeContract: json["product_type_contract"] == null
            ? null
            : json["product_type_contract"],
        latJob: json["lat_job"],
        lngJob: json["lng_job"],
        dateGotoSt: json["date_goto_st"] == null ? null : json["date_goto_st"],
        dateinput: json["dateinput"] == null ? null : json["dateinput"],
        statusJob: json["status_job"] == null ? null : json["status_job"],
        cratedDate: json["crated_date"] == null
            ? null
            : DateTime.parse(json["crated_date"]),
        updateDate: json["update_date"] == null
            ? null
            : DateTime.parse(json["update_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id_job": idJob == null ? null : idJob,
        "id_job_head": idJobHead == null ? null : idJobHead,
        "id_card_user": idCardUser == null ? null : idCardUser,
        "id_mechanic": idMechanic,
        "id_sale": idSale == null ? null : idSale,
        "id_credit": idCredit,
        "address_deliver": addressDeliver == null ? null : addressDeliver,
        "provinces": provinces == null ? null : provinces,
        "amphures": amphures == null ? null : amphures,
        "districts": districts == null ? null : districts,
        "date_time_install": dateTimeInstall,
        "product_type_contract":
            productTypeContract == null ? null : productTypeContract,
        "lat_job": latJob,
        "lng_job": lngJob,
        "date_goto_st": dateGotoSt == null ? null : dateGotoSt,
        "dateinput": dateinput == null ? null : dateinput,
        "status_job": statusJob == null ? null : statusJob,
        "crated_date":
            cratedDate == null ? null : cratedDate!.toIso8601String(),
        "update_date":
            updateDate == null ? null : updateDate!.toIso8601String(),
      };
}
