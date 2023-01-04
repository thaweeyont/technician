// To parse this JSON data, do
//
//     final job = jobFromJson(jsonString);

import 'dart:convert';

List<Job> jobFromJson(String str) =>
    List<Job>.from(json.decode(str).map((x) => Job.fromJson(x)));

String jobToJson(List<Job> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Job {
  Job({
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
    this.dateTimeInstall,
    this.productTypeContract,
    this.latJob,
    this.lngJob,
    this.statusJob,
    this.cratedDate,
    this.id,
    this.idcard,
    this.fullname,
    this.addressUser,
    this.phoneUser,
    this.lat,
    this.lng,
    this.status,
    this.token,
    this.date,
    this.datest,
    this.countGen,
    this.dateGo,
  });

  String? idData;
  String? idGenJob;
  String? idStaff;
  String? idProduct;
  String? latData;
  String? lngData;
  dynamic waring;
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
  dynamic idCredit;
  String? addressDeliver;
  dynamic dateTimeInstall;
  String? productTypeContract;
  String? latJob;
  String? lngJob;
  String? statusJob;
  DateTime? cratedDate;
  String? id;
  String? idcard;
  String? fullname;
  String? addressUser;
  String? phoneUser;
  String? lat;
  String? lng;
  String? status;
  String? token;
  dynamic date;
  String? datest;
  String? countGen;
  DateTime? dateGo;

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        idData: json["id_data"] == null ? null : json["id_data"],
        idGenJob: json["id_gen_job"] == null ? null : json["id_gen_job"],
        idStaff: json["id_staff"] == null ? null : json["id_staff"],
        idProduct: json["id_product"] == null ? null : json["id_product"],
        latData: json["lat_data"] == null ? null : json["lat_data"],
        lngData: json["lng_data"] == null ? null : json["lng_data"],
        waring: json["waring"],
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
        idCredit: json["id_credit"],
        addressDeliver:
            json["address_deliver"] == null ? null : json["address_deliver"],
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
        idcard: json["idcard"] == null ? null : json["idcard"],
        fullname: json["fullname"] == null ? null : json["fullname"],
        addressUser: json["address_user"] == null ? null : json["address_user"],
        phoneUser: json["phone_user"] == null ? null : json["phone_user"],
        lat: json["lat"] == null ? null : json["lat"],
        lng: json["lng"] == null ? null : json["lng"],
        status: json["status"] == null ? null : json["status"],
        token: json["Token"] == null ? null : json["Token"],
        date: json["date"],
        datest: json["datest"] == null ? null : json["datest"],
        countGen: json["count_gen"] == null ? null : json["count_gen"],
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
        "waring": waring,
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
        "id_credit": idCredit,
        "address_deliver": addressDeliver == null ? null : addressDeliver,
        "date_time_install": dateTimeInstall,
        "product_type_contract":
            productTypeContract == null ? null : productTypeContract,
        "lat_job": latJob == null ? null : latJob,
        "lng_job": lngJob == null ? null : lngJob,
        "status_job": statusJob == null ? null : statusJob,
        "crated_date":
            cratedDate == null ? null : cratedDate!.toIso8601String(),
        "id": id == null ? null : id,
        "idcard": idcard == null ? null : idcard,
        "fullname": fullname == null ? null : fullname,
        "address_user": addressUser == null ? null : addressUser,
        "phone_user": phoneUser == null ? null : phoneUser,
        "lat": lat == null ? null : lat,
        "lng": lng == null ? null : lng,
        "status": status == null ? null : status,
        "Token": token == null ? null : token,
        "date": date,
        "datest": datest == null ? null : datest,
        "count_gen": countGen == null ? null : countGen,
        "date_go": dateGo == null ? null : dateGo!.toIso8601String(),
      };
}
