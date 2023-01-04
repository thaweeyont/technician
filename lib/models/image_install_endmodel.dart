// To parse this JSON data, do
//
//     final imageInstallEnd = imageInstallEndFromJson(jsonString);

import 'dart:convert';

List<ImageInstallEnd> imageInstallEndFromJson(String str) =>
    List<ImageInstallEnd>.from(
        json.decode(str).map((x) => ImageInstallEnd.fromJson(x)));

String imageInstallEndToJson(List<ImageInstallEnd> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ImageInstallEnd {
  ImageInstallEnd({
    this.idEnd,
    this.idGenJob,
    this.idStaff,
    this.imageInstall1,
    this.imageInstall2,
    this.imageInstall3,
    this.imageInstall4,
    this.imageReceipt1,
    this.imageReceipt2,
    this.warningEnd,
    this.createdDateEnd,
    this.updateDateEnd,
    this.statusEnd,
  });

  String? idEnd;
  String? idGenJob;
  String? idStaff;
  String? imageInstall1;
  String? imageInstall2;
  String? imageInstall3;
  String? imageInstall4;
  String? imageReceipt1;
  String? imageReceipt2;
  String? warningEnd;
  DateTime? createdDateEnd;
  DateTime? updateDateEnd;
  String? statusEnd;

  factory ImageInstallEnd.fromJson(Map<String, dynamic> json) =>
      ImageInstallEnd(
        idEnd: json["id_end"] == null ? null : json["id_end"],
        idGenJob: json["id_gen_job"] == null ? null : json["id_gen_job"],
        idStaff: json["id_staff"] == null ? null : json["id_staff"],
        imageInstall1:
            json["image_install_1"] == null ? null : json["image_install_1"],
        imageInstall2:
            json["image_install_2"] == null ? null : json["image_install_2"],
        imageInstall3:
            json["image_install_3"] == null ? null : json["image_install_3"],
        imageInstall4:
            json["image_install_4"] == null ? null : json["image_install_4"],
        imageReceipt1:
            json["image_receipt_1"] == null ? null : json["image_receipt_1"],
        imageReceipt2:
            json["image_receipt_2"] == null ? null : json["image_receipt_2"],
        warningEnd: json["warning_end"] == null ? null : json["warning_end"],
        createdDateEnd: json["created_date_end"] == null
            ? null
            : DateTime.parse(json["created_date_end"]),
        updateDateEnd: json["update_date_end"] == null
            ? null
            : DateTime.parse(json["update_date_end"]),
        statusEnd: json["status_end"] == null ? null : json["status_end"],
      );

  Map<String, dynamic> toJson() => {
        "id_end": idEnd == null ? null : idEnd,
        "id_gen_job": idGenJob == null ? null : idGenJob,
        "id_staff": idStaff == null ? null : idStaff,
        "image_install_1": imageInstall1 == null ? null : imageInstall1,
        "image_install_2": imageInstall2 == null ? null : imageInstall2,
        "image_install_3": imageInstall3 == null ? null : imageInstall3,
        "image_install_4": imageInstall4 == null ? null : imageInstall4,
        "image_receipt_1": imageReceipt1 == null ? null : imageReceipt1,
        "image_receipt_2": imageReceipt2 == null ? null : imageReceipt2,
        "warning_end": warningEnd == null ? null : warningEnd,
        "created_date_end":
            createdDateEnd == null ? null : createdDateEnd!.toIso8601String(),
        "update_date_end":
            updateDateEnd == null ? null : updateDateEnd!.toIso8601String(),
        "status_end": statusEnd == null ? null : statusEnd,
      };
}
