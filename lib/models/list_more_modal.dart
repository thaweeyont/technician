// To parse this JSON data, do
//
//     final listMoreModal = listMoreModalFromJson(jsonString);

import 'dart:convert';

List<ListMoreModal> listMoreModalFromJson(String str) =>
    List<ListMoreModal>.from(
        json.decode(str).map((x) => ListMoreModal.fromJson(x)));

String listMoreModalToJson(List<ListMoreModal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListMoreModal {
  ListMoreModal({
    this.idOther,
    this.idRuning,
    this.typeRuning,
    this.nameImg,
    this.createdDate,
    this.updateDate,
  });

  String? idOther;
  String? idRuning;
  String? typeRuning;
  String? nameImg;
  DateTime? createdDate;
  dynamic updateDate;

  factory ListMoreModal.fromJson(Map<String, dynamic> json) => ListMoreModal(
        idOther: json["id_other"] == null ? null : json["id_other"],
        idRuning: json["id_runing"] == null ? null : json["id_runing"],
        typeRuning: json["type_runing"] == null ? null : json["type_runing"],
        nameImg: json["name_img"] == null ? null : json["name_img"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        updateDate: json["update_date"],
      );

  Map<String, dynamic> toJson() => {
        "id_other": idOther == null ? null : idOther,
        "id_runing": idRuning == null ? null : idRuning,
        "type_runing": typeRuning == null ? null : typeRuning,
        "name_img": nameImg == null ? null : nameImg,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "update_date": updateDate,
      };
}
