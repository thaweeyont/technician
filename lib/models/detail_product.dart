// To parse this JSON data, do
//
//     final detailProduct = detailProductFromJson(jsonString);

import 'dart:convert';

List<DetailProduct> detailProductFromJson(String str) =>
    List<DetailProduct>.from(
        json.decode(str).map((x) => DetailProduct.fromJson(x)));

String detailProductToJson(List<DetailProduct> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DetailProduct {
  DetailProduct({
    this.id,
    this.idProductJoblog,
    this.productType,
    this.detailProduct,
    this.countProduct,
    this.priceProduct,
    this.status,
    this.createdDate,
    this.updateDate,
  });

  String? id;
  String? idProductJoblog;
  String? productType;
  String? detailProduct;
  String? countProduct;
  String? priceProduct;
  String? status;
  DateTime? createdDate;
  dynamic updateDate;

  factory DetailProduct.fromJson(Map<String, dynamic> json) => DetailProduct(
        id: json["id"] == null ? null : json["id"],
        idProductJoblog: json["id_product_joblog"] == null
            ? null
            : json["id_product_joblog"],
        productType: json["product_type"] == null ? null : json["product_type"],
        detailProduct:
            json["detail_product"] == null ? null : json["detail_product"],
        countProduct:
            json["count_product"] == null ? null : json["count_product"],
        priceProduct:
            json["price_product"] == null ? null : json["price_product"],
        status: json["status"] == null ? null : json["status"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "id_product_joblog": idProductJoblog == null ? null : idProductJoblog,
        "product_type": productType == null ? null : productType,
        "detail_product": detailProduct == null ? null : detailProduct,
        "count_product": countProduct == null ? null : countProduct,
        "price_product": priceProduct == null ? null : priceProduct,
        "status": status == null ? null : status,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date": updateDate,
      };
}
