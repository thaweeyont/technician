// To parse this JSON data, do
//
//     final listAddjobMechanicmodal = listAddjobMechanicmodalFromJson(jsonString);

import 'dart:convert';

List<ListAddjobMechanicmodal> listAddjobMechanicmodalFromJson(String str) =>
    List<ListAddjobMechanicmodal>.from(
        json.decode(str).map((x) => ListAddjobMechanicmodal.fromJson(x)));

String listAddjobMechanicmodalToJson(List<ListAddjobMechanicmodal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListAddjobMechanicmodal {
  ListAddjobMechanicmodal({
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
    this.idProduct,
    this.productType,
    this.productBrand,
    this.productDetail,
    this.productCount,
    this.productPrice,
    this.productStatus,
    this.createdDate,
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
    this.idStaff,
    this.idBranch,
    this.fullnameStaff,
    this.phoneStaff,
    this.tokenStaff,
    this.statusStaff,
    this.statusShow,
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
  String? latJob;
  String? lngJob;
  String? dateGotoSt;
  String? dateinput;
  String? statusJob;
  DateTime? cratedDate;
  dynamic updateDate;
  String? idProduct;
  String? productType;
  String? productBrand;
  String? productDetail;
  String? productCount;
  String? productPrice;
  String? productStatus;
  DateTime? createdDate;
  String? id;
  String? idcard;
  String? fullname;
  String? addressUser;
  String? provincesU;
  String? amphuresU;
  String? districtsU;
  String? phoneUser;
  String? lat;
  String? lng;
  String? status;
  String? token;
  String? idStaff;
  String? idBranch;
  String? fullnameStaff;
  String? phoneStaff;
  String? tokenStaff;
  String? statusStaff;
  String? statusShow;

  factory ListAddjobMechanicmodal.fromJson(Map<String, dynamic> json) =>
      ListAddjobMechanicmodal(
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
        latJob: json["lat_job"] == null ? null : json["lat_job"],
        lngJob: json["lng_job"] == null ? null : json["lng_job"],
        dateGotoSt: json["date_goto_st"] == null ? null : json["date_goto_st"],
        dateinput: json["dateinput"] == null ? null : json["dateinput"],
        statusJob: json["status_job"] == null ? null : json["status_job"],
        cratedDate: json["crated_date"] == null
            ? null
            : DateTime.parse(json["crated_date"]),
        updateDate: json["update_date"],
        idProduct: json["id_product"] == null ? null : json["id_product"],
        productType: json["product_type"] == null ? null : json["product_type"],
        productBrand:
            json["product_brand"] == null ? null : json["product_brand"],
        productDetail:
            json["product_detail"] == null ? null : json["product_detail"],
        productCount:
            json["product_count"] == null ? null : json["product_count"],
        productPrice:
            json["product_price"] == null ? null : json["product_price"],
        productStatus:
            json["product_status"] == null ? null : json["product_status"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        id: json["id"] == null ? null : json["id"],
        idcard: json["idcard"] == null ? null : json["idcard"],
        fullname: json["fullname"] == null ? null : json["fullname"],
        addressUser: json["address_user"] == null ? null : json["address_user"],
        provincesU: json["provinces_u"] == null ? null : json["provinces_u"],
        amphuresU: json["amphures_u"] == null ? null : json["amphures_u"],
        districtsU: json["districts_u"] == null ? null : json["districts_u"],
        phoneUser: json["phone_user"] == null ? null : json["phone_user"],
        lat: json["lat"] == null ? null : json["lat"],
        lng: json["lng"] == null ? null : json["lng"],
        status: json["status"] == null ? null : json["status"],
        token: json["Token"] == null ? null : json["Token"],
        idStaff: json["id_staff"] == null ? null : json["id_staff"],
        idBranch: json["id_branch"] == null ? null : json["id_branch"],
        fullnameStaff:
            json["fullname_staff"] == null ? null : json["fullname_staff"],
        phoneStaff: json["phone_staff"] == null ? null : json["phone_staff"],
        tokenStaff: json["Token_staff"] == null ? null : json["Token_staff"],
        statusStaff: json["status_staff"] == null ? null : json["status_staff"],
        statusShow: json["status_show"] == null ? null : json["status_show"],
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
        "lat_job": latJob == null ? null : latJob,
        "lng_job": lngJob == null ? null : lngJob,
        "date_goto_st": dateGotoSt == null ? null : dateGotoSt,
        "dateinput": dateinput == null ? null : dateinput,
        "status_job": statusJob == null ? null : statusJob,
        "crated_date":
            cratedDate == null ? null : cratedDate!.toIso8601String(),
        "update_date": updateDate,
        "id_product": idProduct == null ? null : idProduct,
        "product_type": productType == null ? null : productType,
        "product_brand": productBrand == null ? null : productBrand,
        "product_detail": productDetail == null ? null : productDetail,
        "product_count": productCount == null ? null : productCount,
        "product_price": productPrice == null ? null : productPrice,
        "product_status": productStatus == null ? null : productStatus,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "id": id == null ? null : id,
        "idcard": idcard == null ? null : idcard,
        "fullname": fullname == null ? null : fullname,
        "address_user": addressUser == null ? null : addressUser,
        "provinces_u": provincesU == null ? null : provincesU,
        "amphures_u": amphuresU == null ? null : amphuresU,
        "districts_u": districtsU == null ? null : districtsU,
        "phone_user": phoneUser == null ? null : phoneUser,
        "lat": lat == null ? null : lat,
        "lng": lng == null ? null : lng,
        "status": status == null ? null : status,
        "Token": token == null ? null : token,
        "id_staff": idStaff == null ? null : idStaff,
        "id_branch": idBranch == null ? null : idBranch,
        "fullname_staff": fullnameStaff == null ? null : fullnameStaff,
        "phone_staff": phoneStaff == null ? null : phoneStaff,
        "Token_staff": tokenStaff == null ? null : tokenStaff,
        "status_staff": statusStaff == null ? null : statusStaff,
        "status_show": statusShow == null ? null : statusShow,
      };
}
