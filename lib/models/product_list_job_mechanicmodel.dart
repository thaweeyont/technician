// To parse this JSON data, do
//
//     final productListJobMechanic = productListJobMechanicFromJson(jsonString);

import 'dart:convert';

List<ProductListJobMechanic> productListJobMechanicFromJson(String str) =>
    List<ProductListJobMechanic>.from(
        json.decode(str).map((x) => ProductListJobMechanic.fromJson(x)));

String productListJobMechanicToJson(List<ProductListJobMechanic> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductListJobMechanic {
  ProductListJobMechanic({
    this.idProduct,
    this.idJobHead,
    this.productType,
    this.productBrand,
    this.productDetail,
    this.productCount,
    this.productPrice,
    this.productTypeContract,
    this.productStatus,
    this.createdDate,
    this.updateDate,
    this.idJob,
    this.idCardUser,
    this.idMechanic,
    this.idSale,
    this.idCredit,
    this.addressDeliver,
    this.provinces,
    this.amphures,
    this.districts,
    this.dateTimeInstall,
    this.latJob,
    this.lngJob,
    this.statusJob,
    this.cratedDate,
  });

  String? idProduct;
  String? idJobHead;
  String? productType;
  String? productBrand;
  String? productDetail;
  String? productCount;
  String? productPrice;
  String? productTypeContract;
  String? productStatus;
  DateTime? createdDate;
  DateTime? updateDate;
  String? idJob;
  String? idCardUser;
  dynamic idMechanic;
  String? idSale;
  dynamic idCredit;
  String? addressDeliver;
  String? provinces;
  String? amphures;
  String? districts;
  dynamic dateTimeInstall;
  String? latJob;
  String? lngJob;
  String? statusJob;
  DateTime? cratedDate;

  factory ProductListJobMechanic.fromJson(Map<String, dynamic> json) =>
      ProductListJobMechanic(
        idProduct: json["id_product"] == null ? null : json["id_product"],
        idJobHead: json["id_job_head"] == null ? null : json["id_job_head"],
        productType: json["product_type"] == null ? null : json["product_type"],
        productBrand:
            json["product_brand"] == null ? null : json["product_brand"],
        productDetail:
            json["product_detail"] == null ? null : json["product_detail"],
        productCount:
            json["product_count"] == null ? null : json["product_count"],
        productPrice:
            json["product_price"] == null ? null : json["product_price"],
        productTypeContract: json["product_type_contract"] == null
            ? null
            : json["product_type_contract"],
        productStatus:
            json["product_status"] == null ? null : json["product_status"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"] == null
            ? null
            : DateTime.parse(json["update_date"]),
        idJob: json["id_job"] == null ? null : json["id_job"],
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
        latJob: json["lat_job"] == null ? null : json["lat_job"],
        lngJob: json["lng_job"] == null ? null : json["lng_job"],
        statusJob: json["status_job"] == null ? null : json["status_job"],
        cratedDate: json["crated_date"] == null
            ? null
            : DateTime.parse(json["crated_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id_product": idProduct == null ? null : idProduct,
        "id_job_head": idJobHead == null ? null : idJobHead,
        "product_type": productType == null ? null : productType,
        "product_brand": productBrand == null ? null : productBrand,
        "product_detail": productDetail == null ? null : productDetail,
        "product_count": productCount == null ? null : productCount,
        "product_price": productPrice == null ? null : productPrice,
        "product_type_contract":
            productTypeContract == null ? null : productTypeContract,
        "product_status": productStatus == null ? null : productStatus,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date":
            updateDate == null ? null : updateDate!.toIso8601String(),
        "id_job": idJob == null ? null : idJob,
        "id_card_user": idCardUser == null ? null : idCardUser,
        "id_mechanic": idMechanic,
        "id_sale": idSale == null ? null : idSale,
        "id_credit": idCredit,
        "address_deliver": addressDeliver == null ? null : addressDeliver,
        "provinces": provinces == null ? null : provinces,
        "amphures": amphures == null ? null : amphures,
        "districts": districts == null ? null : districts,
        "date_time_install": dateTimeInstall,
        "lat_job": latJob == null ? null : latJob,
        "lng_job": lngJob == null ? null : lngJob,
        "status_job": statusJob == null ? null : statusJob,
        "crated_date":
            cratedDate == null ? null : cratedDate!.toIso8601String(),
      };
}
