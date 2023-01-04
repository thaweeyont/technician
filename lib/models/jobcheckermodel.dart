// To parse this JSON data, do
//
//     final jobChecker = jobCheckerFromJson(jsonString);

import 'dart:convert';

List<JobChecker> jobCheckerFromJson(String str) =>
    List<JobChecker>.from(json.decode(str).map((x) => JobChecker.fromJson(x)));

String jobCheckerToJson(List<JobChecker> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class JobChecker {
  JobChecker({
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
    this.updateDate,
    this.id,
    this.idcard,
    this.fullname,
    this.addressUser,
    this.phoneUser,
    this.lat,
    this.lng,
    this.status,
    this.createdDate,
    this.idStaff,
    this.idBranch,
    this.fullnameStaff,
    this.phoneStaff,
    this.statusStaff,
    this.initialsBranch,
    this.nameBranch,
    this.zone,
    this.statusBranch,
    this.date,
  });

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
  dynamic updateDate;
  String? id;
  String? idcard;
  String? fullname;
  String? addressUser;
  String? phoneUser;
  String? lat;
  String? lng;
  String? status;
  DateTime? createdDate;
  String? idStaff;
  String? idBranch;
  String? fullnameStaff;
  dynamic phoneStaff;
  String? statusStaff;
  String? initialsBranch;
  String? nameBranch;
  String? zone;
  String? statusBranch;
  String? date;

  factory JobChecker.fromJson(Map<String, dynamic> json) => JobChecker(
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
        updateDate: json["update_date"],
        id: json["id"] == null ? null : json["id"],
        idcard: json["idcard"] == null ? null : json["idcard"],
        fullname: json["fullname"] == null ? null : json["fullname"],
        addressUser: json["address_user"] == null ? null : json["address_user"],
        phoneUser: json["phone_user"] == null ? null : json["phone_user"],
        lat: json["lat"] == null ? null : json["lat"],
        lng: json["lng"] == null ? null : json["lng"],
        status: json["status"] == null ? null : json["status"],
        createdDate: json["created_date"] == null
            ? null
            : DateTime.parse(json["created_date"]),
        idStaff: json["id_staff"] == null ? null : json["id_staff"],
        idBranch: json["id_branch"] == null ? null : json["id_branch"],
        fullnameStaff:
            json["fullname_staff"] == null ? null : json["fullname_staff"],
        phoneStaff: json["phone_staff"],
        statusStaff: json["status_staff"] == null ? null : json["status_staff"],
        initialsBranch:
            json["initials_branch"] == null ? null : json["initials_branch"],
        nameBranch: json["name_branch"] == null ? null : json["name_branch"],
        zone: json["zone"] == null ? null : json["zone"],
        statusBranch:
            json["status_branch"] == null ? null : json["status_branch"],
        date: json["date"] == null ? null : json["date"],
      );

  Map<String, dynamic> toJson() => {
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
        "update_date": updateDate,
        "id": id == null ? null : id,
        "idcard": idcard == null ? null : idcard,
        "fullname": fullname == null ? null : fullname,
        "address_user": addressUser == null ? null : addressUser,
        "phone_user": phoneUser == null ? null : phoneUser,
        "lat": lat == null ? null : lat,
        "lng": lng == null ? null : lng,
        "status": status == null ? null : status,
        "created_date":
            createdDate == null ? null : createdDate!.toIso8601String(),
        "id_staff": idStaff == null ? null : idStaff,
        "id_branch": idBranch == null ? null : idBranch,
        "fullname_staff": fullnameStaff == null ? null : fullnameStaff,
        "phone_staff": phoneStaff,
        "status_staff": statusStaff == null ? null : statusStaff,
        "initials_branch": initialsBranch == null ? null : initialsBranch,
        "name_branch": nameBranch == null ? null : nameBranch,
        "zone": zone == null ? null : zone,
        "status_branch": statusBranch == null ? null : statusBranch,
        "date": date == null ? null : date,
      };
}
