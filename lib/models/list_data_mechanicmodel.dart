// To parse this JSON data, do
//
//     final listDataMechanic = listDataMechanicFromJson(jsonString);

import 'dart:convert';

List<ListDataMechanic> listDataMechanicFromJson(String str) =>
    List<ListDataMechanic>.from(
        json.decode(str).map((x) => ListDataMechanic.fromJson(x)));

String listDataMechanicToJson(List<ListDataMechanic> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListDataMechanic {
  ListDataMechanic({
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
    this.statusJob,
    this.cratedDate,
    this.id,
    this.idBranch,
    this.fullnameStaff,
    this.phoneStaff,
    this.tokenStaff,
    this.statusStaff,
    this.statusShow,
    this.checkDate,
    this.dateGo,
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
  String? idJob;
  String? idJobHead;
  String? idCardUser;
  dynamic idMechanic;
  String? idSale;
  String? idCredit;
  String? addressDeliver;
  String? provinces;
  String? amphures;
  String? districts;
  dynamic dateTimeInstall;
  String? productTypeContract;
  String? latJob;
  String? lngJob;
  String? statusJob;
  DateTime? cratedDate;
  String? id;
  String? idBranch;
  String? fullnameStaff;
  String? phoneStaff;
  String? tokenStaff;
  String? statusStaff;
  String? statusShow;
  DateTime? checkDate;
  DateTime? dateGo;

  factory ListDataMechanic.fromJson(Map<String?, dynamic> json) =>
      ListDataMechanic(
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
        idJob: json["id_job"] == null ? null : json["id_job"],
        idJobHead: json["id_job_head"] == null ? null : json["id_job_head"],
        idCardUser: json["id_card_user"] == null ? null : json["id_card_user"],
        idMechanic: json["id_mechanic"],
        idSale: json["id_sale"] == null ? null : json["id_sale"],
        idCredit: json["id_credit"] == null ? null : json["id_credit"],
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
        statusJob: json["status_job"] == null ? null : json["status_job"],
        cratedDate: json["crated_date"] == null
            ? null
            : DateTime.parse(json["crated_date"]),
        id: json["id"] == null ? null : json["id"],
        idBranch: json["id_branch"] == null ? null : json["id_branch"],
        fullnameStaff:
            json["fullname_staff"] == null ? null : json["fullname_staff"],
        phoneStaff: json["phone_staff"] == null ? null : json["phone_staff"],
        tokenStaff: json["Token_staff"] == null ? null : json["Token_staff"],
        statusStaff: json["status_staff"] == null ? null : json["status_staff"],
        statusShow: json["status_show"] == null ? null : json["status_show"],
        checkDate: json["check_date"] == null
            ? null
            : DateTime.parse(json["check_date"]),
        dateGo:
            json["date_go"] == null ? null : DateTime.parse(json["date_go"]),
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
        "id_job": idJob == null ? null : idJob,
        "id_job_head": idJobHead == null ? null : idJobHead,
        "id_card_user": idCardUser == null ? null : idCardUser,
        "id_mechanic": idMechanic,
        "id_sale": idSale == null ? null : idSale,
        "id_credit": idCredit == null ? null : idCredit,
        "address_deliver": addressDeliver == null ? null : addressDeliver,
        "provinces": provinces == null ? null : provinces,
        "amphures": amphures == null ? null : amphures,
        "districts": districts == null ? null : districts,
        "date_time_install": dateTimeInstall,
        "product_type_contract":
            productTypeContract == null ? null : productTypeContract,
        "lat_job": latJob == null ? null : latJob,
        "lng_job": lngJob == null ? null : lngJob,
        "status_job": statusJob == null ? null : statusJob,
        "crated_date":
            cratedDate == null ? null : cratedDate!.toIso8601String(),
        "id": id == null ? null : id,
        "id_branch": idBranch == null ? null : idBranch,
        "fullname_staff": fullnameStaff == null ? null : fullnameStaff,
        "phone_staff": phoneStaff == null ? null : phoneStaff,
        "Token_staff": tokenStaff == null ? null : tokenStaff,
        "status_staff": statusStaff == null ? null : statusStaff,
        "status_show": statusShow == null ? null : statusShow,
        "check_date": checkDate == null ? null : checkDate!.toIso8601String(),
        "date_go": dateGo == null
            ? null
            : "${dateGo!.year.toString().padLeft(4, '0')}-${dateGo!.month.toString().padLeft(2, '0')}-${dateGo!.day.toString().padLeft(2, '0')}",
      };
}
