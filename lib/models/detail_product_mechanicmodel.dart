// To parse this JSON data, do
//
//     final detailProductMechanicmodel = detailProductMechanicmodelFromJson(jsonString);

import 'dart:convert';

List<DetailProductMechanicmodel> detailProductMechanicmodelFromJson(
        String str) =>
    List<DetailProductMechanicmodel>.from(
        json.decode(str).map((x) => DetailProductMechanicmodel.fromJson(x)));

String detailProductMechanicmodelToJson(
        List<DetailProductMechanicmodel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DetailProductMechanicmodel {
  DetailProductMechanicmodel({
    this.idData,
    this.idGenJob,
    this.idStaff,
    this.idProduct,
    this.latData,
    this.lngData,
    this.waring,
    this.timeStart,
    this.timeEnd,
    this.machineCode,
    this.checkMachineCode,
    this.statusData,
    this.createdDate,
    this.updateDate,
    this.idJobHead,
    this.productType,
    this.productBrand,
    this.productDetail,
    this.productCount,
    this.productPrice,
    this.productTypeContract,
    this.productStatus,
  });

  String? idData;
  String? idGenJob;
  String? idStaff;
  String? idProduct;
  String? latData;
  String? lngData;
  String? waring;
  String? timeStart;
  String? timeEnd;
  String? machineCode;
  String? checkMachineCode;
  String? statusData;
  DateTime? createdDate;
  dynamic updateDate;
  String? idJobHead;
  String? productType;
  String? productBrand;
  String? productDetail;
  String? productCount;
  String? productPrice;
  String? productTypeContract;
  String? productStatus;

  factory DetailProductMechanicmodel.fromJson(Map<String, dynamic> json) =>
      DetailProductMechanicmodel(
        idData: json["id_data"] == null ? null : json["id_data"],
        idGenJob: json["id_gen_job"] == null ? null : json["id_gen_job"],
        idStaff: json["id_staff"] == null ? null : json["id_staff"],
        idProduct: json["id_product"] == null ? null : json["id_product"],
        latData: json["lat_data"] == null ? null : json["lat_data"],
        lngData: json["lng_data"] == null ? null : json["lng_data"],
        waring: json["waring"] == null ? null : json["waring"],
        timeStart: json["time_start"] == null ? null : json["time_start"],
        timeEnd: json["time_end"] == null ? null : json["time_end"],
        machineCode: json["machine_code"] == null ? null : json["machine_code"],
        checkMachineCode: json["check_machine_code"] == null
            ? null
            : json["check_machine_code"],
        statusData: json["status_data"] == null ? null : json["status_data"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"],
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
      );

  Map<String, dynamic> toJson() => {
        "id_data": idData == null ? null : idData,
        "id_gen_job": idGenJob == null ? null : idGenJob,
        "id_staff": idStaff == null ? null : idStaff,
        "id_product": idProduct == null ? null : idProduct,
        "lat_data": latData == null ? null : latData,
        "lng_data": lngData == null ? null : lngData,
        "waring": waring == null ? null : waring,
        "time_start": timeStart == null ? null : timeStart,
        "time_end": timeEnd == null ? null : timeEnd,
        "machine_code": machineCode == null ? null : machineCode,
        "check_machine_code":
            checkMachineCode == null ? null : checkMachineCode,
        "status_data": statusData == null ? null : statusData,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date": updateDate,
        "id_job_head": idJobHead == null ? null : idJobHead,
        "product_type": productType == null ? null : productType,
        "product_brand": productBrand == null ? null : productBrand,
        "product_detail": productDetail == null ? null : productDetail,
        "product_count": productCount == null ? null : productCount,
        "product_price": productPrice == null ? null : productPrice,
        "product_type_contract":
            productTypeContract == null ? null : productTypeContract,
        "product_status": productStatus == null ? null : productStatus,
      };
}
