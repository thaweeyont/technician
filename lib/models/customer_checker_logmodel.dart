// To parse this JSON data, do
//
//     final customerCheckerLogModelFromJson = customerCheckerLogModelFromJsonFromJson(jsonString);

import 'dart:convert';

List<CustomerCheckerLogModelFromJson> customerCheckerLogModelFromJson(
        String str) =>
    List<CustomerCheckerLogModelFromJson>.from(json
        .decode(str)
        .map((x) => CustomerCheckerLogModelFromJson.fromJson(x)));

String customerCheckerLogModel(List<CustomerCheckerLogModelFromJson> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerCheckerLogModelFromJson {
  String? idUser;
  String? idCod;
  String? isDelete;
  String? typeRunning;
  String? runningId;
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
  String? dateReceive;
  String? nameReceive;
  String? etcReceive;
  String? numberContract;
  String? nameEdit;
  DateTime? dateEdit;
  String? imgLocation;
  String? nameCheckerRecord;
  String? statusOffer;
  String? nameOffer;
  String? tapNum;
  String? linkQuiz;
  dynamic g1Id;
  dynamic g1Rid;
  dynamic g1Prefix;
  dynamic g1Fname;
  dynamic g1Lname;
  dynamic g1IdcardImg;
  dynamic g1MapImg;
  dynamic g1HouseImg;
  dynamic g1PactImg;
  dynamic g1Googlemap;
  dynamic createAt;
  dynamic updateAt;
  dynamic g2Id;
  dynamic g2Rid;
  dynamic g2Prefix;
  dynamic g2Fname;
  dynamic g2Lname;
  dynamic g2IdcardImg;
  dynamic g2MapImg;
  dynamic g2HouseImg;
  dynamic g2PactImg;
  dynamic g2Googlemap;
  dynamic g3Id;
  dynamic g3Rid;
  dynamic g3Prefix;
  dynamic g3Fname;
  dynamic g3Lname;
  dynamic g3IdcardImg;
  dynamic g3MapImg;
  dynamic g3HouseImg;
  dynamic g3PactImg;
  dynamic g3Googlemap;
  dynamic creatAt;

  CustomerCheckerLogModelFromJson({
    this.idUser,
    this.idCod,
    this.isDelete,
    this.typeRunning,
    this.runningId,
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
    this.dateReceive,
    this.nameReceive,
    this.etcReceive,
    this.numberContract,
    this.nameEdit,
    this.dateEdit,
    this.imgLocation,
    this.nameCheckerRecord,
    this.statusOffer,
    this.nameOffer,
    this.tapNum,
    this.linkQuiz,
    this.g1Id,
    this.g1Rid,
    this.g1Prefix,
    this.g1Fname,
    this.g1Lname,
    this.g1IdcardImg,
    this.g1MapImg,
    this.g1HouseImg,
    this.g1PactImg,
    this.g1Googlemap,
    this.createAt,
    this.updateAt,
    this.g2Id,
    this.g2Rid,
    this.g2Prefix,
    this.g2Fname,
    this.g2Lname,
    this.g2IdcardImg,
    this.g2MapImg,
    this.g2HouseImg,
    this.g2PactImg,
    this.g2Googlemap,
    this.g3Id,
    this.g3Rid,
    this.g3Prefix,
    this.g3Fname,
    this.g3Lname,
    this.g3IdcardImg,
    this.g3MapImg,
    this.g3HouseImg,
    this.g3PactImg,
    this.g3Googlemap,
    this.creatAt,
  });

  factory CustomerCheckerLogModelFromJson.fromJson(Map<String, dynamic> json) =>
      CustomerCheckerLogModelFromJson(
        idUser: json["id_user"],
        idCod: json["id_cod"],
        isDelete: json["is_delete"],
        typeRunning: json["type_running"],
        runningId: json["running_id"],
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
        dateInsert: json["date_insert"] == null
            ? null
            : DateTime.parse(json["date_insert"]),
        timeInsert: json["time_insert"],
        dateReceive: json["date_receive"],
        nameReceive: json["name_receive"],
        etcReceive: json["etc_receive"],
        numberContract: json["number_contract"],
        nameEdit: json["name_edit"],
        dateEdit: json["date_edit"] == null
            ? null
            : DateTime.parse(json["date_edit"]),
        imgLocation: json["img_location"],
        nameCheckerRecord: json["name_checker_record"],
        statusOffer: json["status_offer"],
        nameOffer: json["name_offer"],
        tapNum: json["tap_num"],
        linkQuiz: json["link_quiz"],
        g1Id: json["G1_ID"],
        g1Rid: json["G1_RID"],
        g1Prefix: json["G1_Prefix"],
        g1Fname: json["G1_Fname"],
        g1Lname: json["G1_Lname"],
        g1IdcardImg: json["G1_IdcardImg"],
        g1MapImg: json["G1_MapImg"],
        g1HouseImg: json["G1_HouseImg"],
        g1PactImg: json["G1_PactImg"],
        g1Googlemap: json["G1_Googlemap"],
        createAt: json["create_at"],
        updateAt: json["update_at"],
        g2Id: json["G2_ID"],
        g2Rid: json["G2_RID"],
        g2Prefix: json["G2_Prefix"],
        g2Fname: json["G2_Fname"],
        g2Lname: json["G2_Lname"],
        g2IdcardImg: json["G2_IdcardImg"],
        g2MapImg: json["G2_MapImg"],
        g2HouseImg: json["G2_HouseImg"],
        g2PactImg: json["G2_PactImg"],
        g2Googlemap: json["G2_Googlemap"],
        g3Id: json["G3_ID"],
        g3Rid: json["G3_RID"],
        g3Prefix: json["G3_Prefix"],
        g3Fname: json["G3_Fname"],
        g3Lname: json["G3_Lname"],
        g3IdcardImg: json["G3_IdcardImg"],
        g3MapImg: json["G3_MapImg"],
        g3HouseImg: json["G3_HouseImg"],
        g3PactImg: json["G3_PactImg"],
        g3Googlemap: json["G3_Googlemap"],
        creatAt: json["creat_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_user": idUser,
        "id_cod": idCod,
        "is_delete": isDelete,
        "type_running": typeRunning,
        "running_id": runningId,
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
        "date_receive": dateReceive,
        "name_receive": nameReceive,
        "etc_receive": etcReceive,
        "number_contract": numberContract,
        "name_edit": nameEdit,
        "date_edit":
            "${dateEdit!.year.toString().padLeft(4, '0')}-${dateEdit!.month.toString().padLeft(2, '0')}-${dateEdit!.day.toString().padLeft(2, '0')}",
        "img_location": imgLocation,
        "name_checker_record": nameCheckerRecord,
        "status_offer": statusOffer,
        "name_offer": nameOffer,
        "tap_num": tapNum,
        "link_quiz": linkQuiz,
        "G1_ID": g1Id,
        "G1_RID": g1Rid,
        "G1_Prefix": g1Prefix,
        "G1_Fname": g1Fname,
        "G1_Lname": g1Lname,
        "G1_IdcardImg": g1IdcardImg,
        "G1_MapImg": g1MapImg,
        "G1_HouseImg": g1HouseImg,
        "G1_PactImg": g1PactImg,
        "G1_Googlemap": g1Googlemap,
        "create_at": createAt,
        "update_at": updateAt,
        "G2_ID": g2Id,
        "G2_RID": g2Rid,
        "G2_Prefix": g2Prefix,
        "G2_Fname": g2Fname,
        "G2_Lname": g2Lname,
        "G2_IdcardImg": g2IdcardImg,
        "G2_MapImg": g2MapImg,
        "G2_HouseImg": g2HouseImg,
        "G2_PactImg": g2PactImg,
        "G2_Googlemap": g2Googlemap,
        "G3_ID": g3Id,
        "G3_RID": g3Rid,
        "G3_Prefix": g3Prefix,
        "G3_Fname": g3Fname,
        "G3_Lname": g3Lname,
        "G3_IdcardImg": g3IdcardImg,
        "G3_MapImg": g3MapImg,
        "G3_HouseImg": g3HouseImg,
        "G3_PactImg": g3PactImg,
        "G3_Googlemap": g3Googlemap,
        "creat_at": creatAt,
      };
}
