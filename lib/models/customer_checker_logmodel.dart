// To parse this JSON data, do
//
//     final customerCheckerLogModel = customerCheckerLogModelFromJson(jsonString);

import 'dart:convert';

List<CustomerCheckerLogModel> customerCheckerLogModelFromJson(String str) =>
    List<CustomerCheckerLogModel>.from(
        json.decode(str).map((x) => CustomerCheckerLogModel.fromJson(x)));

String customerCheckerLogModelToJson(List<CustomerCheckerLogModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerCheckerLogModel {
  CustomerCheckerLogModel({
    this.idUser,
    this.typeRunning,
    this.runnigId,
    this.cusPrefix,
    this.cusName,
    this.cusLastname,
    this.cusContractImg,
    this.cusPurchaseImg,
    this.cusCardIdImg,
    this.cusAddressImg,
    this.cusLicenImg,
    this.cusOfferImg,
    this.cusMapsImg,
    this.insertMapsNo1,
    this.kam1Prefix,
    this.kam1Name,
    this.kam1Lastname,
    this.kam1CardIdImg,
    this.kam1AddressImg,
    this.kam1LicenImg,
    this.kam1MapsImg,
    this.insertMapsNo2,
    this.kam2Prefix,
    this.kam2Name,
    this.kam2Lastname,
    this.kam2CardIdImg,
    this.kam2AddressImg,
    this.kam2LicenImg,
    this.kam2MapsImg,
    this.insertMapsNo3,
    this.kam3Prefix,
    this.kam3Name,
    this.kam3Lastname,
    this.kam3CardIdImg,
    this.kam3AddressImg,
    this.kam3LicenImg,
    this.kam3MapsImg,
    this.insertMapsNo4,
    this.reportEtcImg,
    this.licenEtcImg,
    this.zone,
    this.saka,
    this.status,
    this.dateInsert,
    this.timeInsert,
    this.imgLocation,
    this.nameCheckerRecord,
  });

  String? idUser;
  String? typeRunning;
  String? runnigId;
  String? cusPrefix;
  String? cusName;
  String? cusLastname;
  String? cusContractImg;
  String? cusPurchaseImg;
  String? cusCardIdImg;
  String? cusAddressImg;
  String? cusLicenImg;
  String? cusOfferImg;
  String? cusMapsImg;
  String? insertMapsNo1;
  String? kam1Prefix;
  String? kam1Name;
  String? kam1Lastname;
  String? kam1CardIdImg;
  String? kam1AddressImg;
  String? kam1LicenImg;
  String? kam1MapsImg;
  String? insertMapsNo2;
  String? kam2Prefix;
  String? kam2Name;
  String? kam2Lastname;
  String? kam2CardIdImg;
  String? kam2AddressImg;
  String? kam2LicenImg;
  String? kam2MapsImg;
  String? insertMapsNo3;
  String? kam3Prefix;
  String? kam3Name;
  String? kam3Lastname;
  String? kam3CardIdImg;
  String? kam3AddressImg;
  String? kam3LicenImg;
  String? kam3MapsImg;
  String? insertMapsNo4;
  String? reportEtcImg;
  String? licenEtcImg;
  String? zone;
  String? saka;
  String? status;
  DateTime? dateInsert;
  String? timeInsert;
  String? imgLocation;
  String? nameCheckerRecord;

  factory CustomerCheckerLogModel.fromJson(Map<String, dynamic> json) =>
      CustomerCheckerLogModel(
        idUser: json["id_user"],
        typeRunning: json["type_running"],
        runnigId: json["runnig_id"],
        cusPrefix: json["cus_prefix"],
        cusName: json["cus_name"],
        cusLastname: json["cus_lastname"],
        cusContractImg: json["cus_contract_img"],
        cusPurchaseImg: json["cus_purchase_img"],
        cusCardIdImg: json["cus_card_id_img"],
        cusAddressImg: json["cus_address_img"],
        cusLicenImg: json["cus_licen_img"],
        cusOfferImg: json["cus_offer_img"],
        cusMapsImg: json["cus_maps_img"],
        insertMapsNo1: json["insert_maps_no1"],
        kam1Prefix: json["kam1_prefix"],
        kam1Name: json["kam1_name"],
        kam1Lastname: json["kam1_lastname"],
        kam1CardIdImg: json["kam1_card_id_img"],
        kam1AddressImg: json["kam1_address_img"],
        kam1LicenImg: json["kam1_licen_img"],
        kam1MapsImg: json["kam1_maps_img"],
        insertMapsNo2: json["insert_maps_no2"],
        kam2Prefix: json["kam2_prefix"],
        kam2Name: json["kam2_name"],
        kam2Lastname: json["kam2_lastname"],
        kam2CardIdImg: json["kam2_card_id_img"],
        kam2AddressImg: json["kam2_address_img"],
        kam2LicenImg: json["kam2_licen_img"],
        kam2MapsImg: json["kam2_maps_img"],
        insertMapsNo3: json["insert_maps_no3"],
        kam3Prefix: json["kam3_prefix"],
        kam3Name: json["kam3_name"],
        kam3Lastname: json["kam3_lastname"],
        kam3CardIdImg: json["kam3_card_id_img"],
        kam3AddressImg: json["kam3_address_img"],
        kam3LicenImg: json["kam3_licen_img"],
        kam3MapsImg: json["kam3_maps_img"],
        insertMapsNo4: json["insert_maps_no4"],
        reportEtcImg: json["report_etc_img"],
        licenEtcImg: json["licen_etc_img"],
        zone: json["zone"],
        saka: json["saka"],
        status: json["status"],
        dateInsert: DateTime.parse(json["date_insert"]),
        timeInsert: json["time_insert"],
        imgLocation: json["img_location"],
        nameCheckerRecord: json["name_checker_record"],
      );

  Map<String, dynamic> toJson() => {
        "id_user": idUser,
        "type_running": typeRunning,
        "runnig_id": runnigId,
        "cus_prefix": cusPrefix,
        "cus_name": cusName,
        "cus_lastname": cusLastname,
        "cus_contract_img": cusContractImg,
        "cus_purchase_img": cusPurchaseImg,
        "cus_card_id_img": cusCardIdImg,
        "cus_address_img": cusAddressImg,
        "cus_licen_img": cusLicenImg,
        "cus_offer_img": cusOfferImg,
        "cus_maps_img": cusMapsImg,
        "insert_maps_no1": insertMapsNo1,
        "kam1_prefix": kam1Prefix,
        "kam1_name": kam1Name,
        "kam1_lastname": kam1Lastname,
        "kam1_card_id_img": kam1CardIdImg,
        "kam1_address_img": kam1AddressImg,
        "kam1_licen_img": kam1LicenImg,
        "kam1_maps_img": kam1MapsImg,
        "insert_maps_no2": insertMapsNo2,
        "kam2_prefix": kam2Prefix,
        "kam2_name": kam2Name,
        "kam2_lastname": kam2Lastname,
        "kam2_card_id_img": kam2CardIdImg,
        "kam2_address_img": kam2AddressImg,
        "kam2_licen_img": kam2LicenImg,
        "kam2_maps_img": kam2MapsImg,
        "insert_maps_no3": insertMapsNo3,
        "kam3_prefix": kam3Prefix,
        "kam3_name": kam3Name,
        "kam3_lastname": kam3Lastname,
        "kam3_card_id_img": kam3CardIdImg,
        "kam3_address_img": kam3AddressImg,
        "kam3_licen_img": kam3LicenImg,
        "kam3_maps_img": kam3MapsImg,
        "insert_maps_no4": insertMapsNo4,
        "report_etc_img": reportEtcImg,
        "licen_etc_img": licenEtcImg,
        "zone": zone,
        "saka": saka,
        "status": status,
        "date_insert":
            "${dateInsert!.year.toString().padLeft(4, '0')}-${dateInsert!.month.toString().padLeft(2, '0')}-${dateInsert!.day.toString().padLeft(2, '0')}",
        "time_insert": timeInsert,
        "img_location": imgLocation,
        "name_checker_record": nameCheckerRecord,
      };
}
