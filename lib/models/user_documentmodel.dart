// To parse this JSON data, do
//
//     final userDocument = userDocumentFromJson(jsonString);

import 'dart:convert';

List<UserDocument> userDocumentFromJson(String str) => List<UserDocument>.from(
    json.decode(str).map((x) => UserDocument.fromJson(x)));

String userDocumentToJson(List<UserDocument> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserDocument {
  UserDocument({
    this.idDocument,
    this.idGenJob,
    this.idCardChecked,
    this.homeChecked,
    this.idCardGuarantorChecked,
    this.homeGuarantorChecked,
    this.incomeDocument,
    this.statusDocument,
    this.createdDate,
    this.updateDate,
  });

  String? idDocument;
  String? idGenJob;
  String? idCardChecked;
  String? homeChecked;
  String? idCardGuarantorChecked;
  String? homeGuarantorChecked;
  String? incomeDocument;
  String? statusDocument;
  DateTime? createdDate;
  DateTime? updateDate;

  factory UserDocument.fromJson(Map<String, dynamic> json) => UserDocument(
        idDocument: json["id_document"] == null ? null : json["id_document"],
        idGenJob: json["id_gen_job"] == null ? null : json["id_gen_job"],
        idCardChecked:
            json["id_card_Checked"] == null ? null : json["id_card_Checked"],
        homeChecked: json["home_Checked"] == null ? null : json["home_Checked"],
        idCardGuarantorChecked: json["id_card_guarantor_Checked"] == null
            ? null
            : json["id_card_guarantor_Checked"],
        homeGuarantorChecked: json["home_guarantor_Checked"] == null
            ? null
            : json["home_guarantor_Checked"],
        incomeDocument:
            json["income_document"] == null ? null : json["income_document"],
        statusDocument:
            json["status_document"] == null ? null : json["status_document"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"] == null
            ? null
            : DateTime.parse(json["update_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id_document": idDocument == null ? null : idDocument,
        "id_gen_job": idGenJob == null ? null : idGenJob,
        "id_card_Checked": idCardChecked == null ? null : idCardChecked,
        "home_Checked": homeChecked == null ? null : homeChecked,
        "id_card_guarantor_Checked":
            idCardGuarantorChecked == null ? null : idCardGuarantorChecked,
        "home_guarantor_Checked":
            homeGuarantorChecked == null ? null : homeGuarantorChecked,
        "income_document": incomeDocument == null ? null : incomeDocument,
        "status_document": statusDocument == null ? null : statusDocument,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date":
            updateDate == null ? null : updateDate!.toIso8601String(),
      };
}
