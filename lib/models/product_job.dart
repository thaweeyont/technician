// To parse this JSON data, do
//
//     final productJob = productJobFromJson(jsonString);

import 'dart:convert';

List<ProductJob> productJobFromJson(String str) =>
    List<ProductJob>.from(json.decode(str).map((x) => ProductJob.fromJson(x)));

String productJobToJson(List<ProductJob> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductJob {
  ProductJob({
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
  dynamic updateDate;

  factory ProductJob.fromJson(Map<String, dynamic> json) => ProductJob(
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
        updateDate: json["update_date"],
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
        "update_date": updateDate,
      };
}
