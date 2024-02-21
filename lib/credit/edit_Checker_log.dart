import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/ipconfig_checkerlog.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;
import 'package:technician/widgets/show_progress.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class EditCheckerLog extends StatefulWidget {
  final String? id_user,
      saka,
      zone,
      name_user,
      ip_conn,
      running_id,
      type_running,
      level;
  EditCheckerLog(this.id_user, this.saka, this.zone, this.name_user,
      this.ip_conn, this.running_id, this.type_running, this.level);

  @override
  _EditCheckerLogState createState() => _EditCheckerLogState();
}

class _EditCheckerLogState extends State<EditCheckerLog> {
  TextEditingController id_running_text = TextEditingController();
  TextEditingController name_customer_text = TextEditingController();
  TextEditingController lastname_customer_text = TextEditingController();
  TextEditingController name_kam1_text = TextEditingController();
  TextEditingController lastname_kam1_text = TextEditingController();
  TextEditingController name_kam2_text = TextEditingController();
  TextEditingController lastname_kam2_text = TextEditingController();
  TextEditingController name_kam3_text = TextEditingController();
  TextEditingController lastname_kam3_text = TextEditingController();
  double? lat, lng, latitude, longitude;
  String? selectedValue;
  List<File?> files = [];
  File? file;
  File? file_more;
  List data_customer = [];
  Completer<GoogleMapController> _controller = Completer();
  bool show_kam1 = false;
  bool show_kam2 = false;
  bool show_kam3 = false;
  bool show_other = false;
  bool show_more = false;
  List list_zone = [];
  List list_saka = [];
  List list_more = [];
  String? val_zone;
  String? val_saka, lat2, lng2;
  bool show_edit_zonesaka = false;
  String? prefixname_customer_text;
  String? prefixname_kam1_text;
  String? prefixname_kam2_text;
  String? prefixname_kam3_text;
  @override
  void initState() {
    super.initState();
    CheckPermission();
    _list_zone();
    _list_saka(widget.zone);
    _list_more();
    st_set_val();
    initialFile_customer();
    // data_checker_log(widget.id_user);
    set_value_st();
  }

  //CheckPermission
  Future<void> CheckPermission() async {
    bool locationService;
    LocationPermission locationPermission;

    locationService = await Geolocator.isLocationServiceEnabled();
    if (locationService) {
      print('Service Location Open');
      locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.deniedForever) {
          alertLocationService(
              context, 'ไม่อนุญาติแชร์ Location', 'โปรดแชร์ location');
        } else {
          // Find LatLong
          findLatLng();
        }
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          alertLocationService(
              context, 'ไม่อนุญาติแชร์ Location', 'โปรดแชร์ location');
        } else {
          // Find LatLong
          findLatLng();
        }
      }
    } else {
      print('Service Location Close');
      alertLocationService(
          context, 'Location ปิดอยู่?', 'กรุณาเปิด Location ด้วยคะ');
    }
  }

  Future<Null> findLatLng() async {
    Position? position = await findPosition();
    setState(() {
      lat = position!.latitude;
      lng = position.longitude;
      print('lat_mec = $lat, lng_mec = $lng');
    });
  }

  Future<Position?> findPosition() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return position;
    } catch (e) {
      return null;
    }
  }

  //set_st_value
  Future<Null> st_set_val() async {
    setState(() {
      val_zone = widget.zone;
      val_saka = widget.saka;
    });
    print("zone=>$val_zone saka=>$val_saka");
  }

  //list_zone
  Future<Null> _list_zone() async {
    try {
      var respose = await http
          .get(Uri.http(ipconfig_checker, '/CheckerData2/api/Zone.php'));
      if (respose.statusCode == 200) {
        var jsonData = jsonDecode(respose.body);
        setState(() {
          list_zone = jsonData;
        });
      }
    } catch (e) {
      var respose = await http
          .get(Uri.http(ipconfig_checker_office, '/CheckerData2/api/Zone.php'));
      if (respose.statusCode == 200) {
        var jsonData = jsonDecode(respose.body);
        setState(() {
          list_zone = jsonData;
        });
      }
    }
  }

  //list_saka
  Future<Null> _list_saka(zone) async {
    list_saka = [];
    val_saka = null;
    try {
      var respose = await http.get(Uri.http(ipconfig_checker,
          '/CheckerData2/api/Branch.php', {"zone": zone.toString()}));
      if (respose.statusCode == 200) {
        var jsonData = jsonDecode(respose.body);
        setState(() {
          list_saka = jsonData;
        });
      }
    } catch (e) {
      var respose = await http.get(Uri.http(ipconfig_checker_office,
          '/CheckerData2/api/Branch.php', {"zone": zone.toString()}));
      if (respose.statusCode == 200) {
        var jsonData = jsonDecode(respose.body);
        setState(() {
          list_saka = jsonData;
        });
      }
    }
  }

  //list_more
  Future<Null> _list_more() async {
    try {
      var respose = await http.post(Uri.http(
          ipconfig_checker, '/CheckerData2/api/DataShowEditImgMore.php', {
        "id_runing": widget.running_id.toString(),
        "type_runing": widget.type_running.toString(),
      }));
      if (respose.statusCode == 200) {
        var data = json.decode(respose.body);
        if (data['status'] == 200) {
          show_more = true;
          setState(() {
            list_more = data['data'];
          });
        }
      }
    } catch (e) {
      var respose = await http.post(Uri.http(ipconfig_checker_office,
          '/CheckerData2/api/DataShowEditImgMore.php', {
        "id_runing": widget.running_id.toString(),
        "type_runing": widget.type_running.toString(),
      }));
      if (respose.statusCode == 200) {
        var data = json.decode(respose.body);
        if (data['status'] == 200) {
          show_more = true;
          setState(() {
            list_more = data['data'];
          });
        }
      }
    }
  }

  Future<Null> set_value_st() async {
    setState(() {
      id_running_text.text = widget.running_id.toString();
      selectedValue = widget.type_running.toString();
    });
  }

  //ไฟล์ภาพ เซ็ทค่าตั้งต้น
  void initialFile_customer() {
    if (widget.level == "checker_runnig") {
      for (var i = 0; i < 21; i++) {
        files.add(null);
      }
      data_checker_log(widget.id_user);
    } else {
      for (var i = 0; i < 16; i++) {
        files.add(null);
      }
      data_checker_log(widget.id_user);
    }
  }

  //เรียกใช้ api แสดงข้อมูล
  Future<Null> data_checker_log(id_user) async {
    data_customer = [];
    try {
      var respose = await http.get(
          // Uri.http(widget.ip_conn, '/checker_data/filter_runing_mobile.php', {
          Uri.http("$ipconfig_checker", '/CheckerData2/api/DataShowEdit.php', {
        "id_user": id_user,
      }));
      if (respose.statusCode == 200) {
        setState(() {
          data_customer = json.decode(respose.body);
          String url = data_customer[0]['insert_maps_no1'];
          String numbersPart = url.split('=')[1];
          List<String> numbers = numbersPart.split(',');
          latitude = double.parse(numbers[0]);
          longitude = double.parse(numbers[1]);
          print('Latitude: $latitude, Longitude: $longitude');

          name_customer_text.text = data_customer[0]['cus_name'].toString();
          if (data_customer[0]['cus_prefix'] != "") {
            prefixname_customer_text =
                data_customer[0]['cus_prefix'].toString();
          }
          lastname_customer_text.text =
              data_customer[0]['cus_lastname'].toString();

          if (data_customer[0]['G1_Fname'] != null) {
            show_kam1 = true;
            data_customer[0]['G1_Fname'] == null
                ? name_kam1_text.text = ''
                : name_kam1_text.text = data_customer[0]['G1_Fname'].toString();
            data_customer[0]['G1_Lname'] == null
                ? lastname_kam1_text.text = ''
                : lastname_kam1_text.text =
                    data_customer[0]['G1_Lname'].toString();
            if (data_customer[0]['G1_Prefix'] != "") {
              prefixname_kam1_text = data_customer[0]['G1_Prefix'];
            }
          }
          if (data_customer[0]['G2_Fname'] != null) {
            show_kam2 = true;
            data_customer[0]['G2_Fname'] == null
                ? name_kam2_text.text = ''
                : name_kam2_text.text = data_customer[0]['G2_Fname'].toString();
            data_customer[0]['G2_Lname'] == null
                ? lastname_kam2_text.text = ''
                : lastname_kam2_text.text =
                    data_customer[0]['G2_Lname'].toString();
            if (data_customer[0]['G2_Prefix'] != "") {
              prefixname_kam2_text = data_customer[0]['G2_Prefix'];
            }
          }
          if (data_customer[0]['G3_Fname'] != null) {
            show_kam3 = true;
            data_customer[0]['G3_Fname'] == null
                ? name_kam3_text.text = ''
                : name_kam3_text.text = data_customer[0]['G3_Fname'].toString();
            data_customer[0]['G3_Lname'] == null
                ? lastname_kam3_text.text = ''
                : lastname_kam3_text.text =
                    data_customer[0]['G3_Lname'].toString();
            if (data_customer[0]['G3_Prefix'] != "") {
              prefixname_kam3_text = data_customer[0]['G3_Prefix'];
            }
          }
          if (data_customer[0]['report_etc_img'] != "") {
            show_other = true;
          }
        });
      }
    } catch (e) {
      var respose = await http.get(Uri.http(
          "$ipconfig_checker_office", '/CheckerData2/api/DataShowEdit.php', {
        "id_user": id_user,
      }));
      if (respose.statusCode == 200) {
        setState(() {
          data_customer = json.decode(respose.body);
          String url = data_customer[0]['insert_maps_no1'];
          String numbersPart = url.split('=')[1];
          List<String> numbers = numbersPart.split(',');
          latitude = double.parse(numbers[0]);
          longitude = double.parse(numbers[1]);
          print('Latitude: $latitude, Longitude: $longitude');

          name_customer_text.text = data_customer[0]['cus_name'].toString();
          if (data_customer[0]['cus_prefix'] != "") {
            prefixname_customer_text =
                data_customer[0]['cus_prefix'].toString();
          }
          lastname_customer_text.text =
              data_customer[0]['cus_lastname'].toString();

          if (data_customer[0]['G1_Fname'] != null) {
            show_kam1 = true;
            data_customer[0]['G1_Fname'] == null
                ? name_kam1_text.text = ''
                : name_kam1_text.text = data_customer[0]['G1_Fname'].toString();
            data_customer[0]['G1_Lname'] == null
                ? lastname_kam1_text.text = ''
                : lastname_kam1_text.text =
                    data_customer[0]['G1_Lname'].toString();
            if (data_customer[0]['G1_Prefix'] != "") {
              prefixname_kam1_text = data_customer[0]['G1_Prefix'];
            }
          }
          if (data_customer[0]['G2_Fname'] != null) {
            show_kam2 = true;
            data_customer[0]['G2_Fname'] == null
                ? name_kam2_text.text = ''
                : name_kam2_text.text = data_customer[0]['G2_Fname'].toString();
            data_customer[0]['G2_Lname'] == null
                ? lastname_kam2_text.text = ''
                : lastname_kam2_text.text =
                    data_customer[0]['G2_Lname'].toString();
            if (data_customer[0]['G2_Prefix'] != "") {
              prefixname_kam2_text = data_customer[0]['G2_Prefix'];
            }
          }
          if (data_customer[0]['G3_Fname'] != null) {
            show_kam3 = true;
            data_customer[0]['G3_Fname'] == null
                ? name_kam3_text.text = ''
                : name_kam3_text.text = data_customer[0]['G3_Fname'].toString();
            data_customer[0]['G3_Lname'] == null
                ? lastname_kam3_text.text = ''
                : lastname_kam3_text.text =
                    data_customer[0]['G3_Lname'].toString();
            if (data_customer[0]['G3_Prefix'] != "") {
              prefixname_kam3_text = data_customer[0]['G3_Prefix'];
            }
          }
          if (data_customer[0]['report_etc_img'] != "") {
            show_other = true;
          }
        });
      }
    }
  }

  //Api แก้ไขชื่อ
  Future change_name_api(prefix, name, lastname, type) async {
    try {
      var uri = Uri.parse(
          "http://$ipconfig_checker/CheckerData2/api/UpdateNameCustomer.php");
      var request = new http.MultipartRequest("POST", uri);
      request.fields['name'] = name;
      request.fields['lastname'] = lastname;
      request.fields['prefix'] = prefix;
      request.fields['type'] = type.toString();
      request.fields['id_user'] = widget.id_user!;
      request.fields['running_id'] = widget.running_id!;
      var response = await request.send();
      if (response.statusCode == 200) {
        print("แก้ไขชื่อสำเร็จ");
        successDialog(context, "สำเร็จ", "แก้ไขข้อมูลเสร็จสิ้น");
      } else {
        print("แก้ไขชื่อไม่สำเร็จ");
        normalDialog(context, "เตือน", "เกิดข้อผิดพลาด");
      }
    } catch (e) {
      var uri = Uri.parse(
          "http://$ipconfig_checker_office/CheckerData2/api/UpdateNameCustomer.php");
      var request = new http.MultipartRequest("POST", uri);
      request.fields['name'] = name;
      request.fields['lastname'] = lastname;
      request.fields['prefix'] = prefix;
      request.fields['type'] = type.toString();
      request.fields['id_user'] = widget.id_user!;
      request.fields['running_id'] = widget.running_id!;
      var response = await request.send();
      if (response.statusCode == 200) {
        print("แก้ไขชื่อสำเร็จ");
        successDialog(context, "สำเร็จ", "แก้ไขข้อมูลเสร็จสิ้น");
      } else {
        print("แก้ไขชื่อไม่สำเร็จ");
        normalDialog(context, "เตือน", "เกิดข้อผิดพลาด");
      }
    }
  }

//------------------------------------------------------- บันทึก / จัดการภาพผู้ซื้อ --------------------------------------------------------------------------
  Future<Null> img_customer(name, index) async {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        title: ListTile(
          leading: Icon(
            Icons.image,
            size: 55,
          ),
          title: Text(
            '$name',
            style: MyConstant().h3Style(),
          ),
          subtitle: Text(
            'โปรดเลือกภาพเพื่อแก้ไข',
            style: MyConstant().h3Style(),
          ),
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  process_img_customer(ImageSource.gallery, index);
                },
                child: Text(
                  "คลังภาพ",
                  style: MyConstant().h3Style(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  process_img_customer(ImageSource.camera, index);
                },
                child: Text(
                  "เปิดกล้อง",
                  style: MyConstant().h3Style(),
                ),
              ),
            ],
          )
        ],
      ),
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 0),
    );
  }

  Future<Null> process_img_customer(ImageSource source, int index) async {
    try {
      var result = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (widget.level == "checker_runnig") {
        if ((index >= 0 && index <= 3) || (index >= 16 && index <= 18)) {
          if (name_customer_text.text == "") {
            normalDialog(context, "เตือน", "กรุณาเพิ่มชื่อผู้ซื้อ");
          } else {
            //แสดงภาพที่แก้ไข
            setState(() {
              file = File(result!.path);
              files[index] = file;
            });
            print('test1');
            showProgressLoading(context);
            upload_file(index, name_customer_text.text);
          }
        }
      } else {
        if (index >= 0 && index <= 3) {
          if (name_customer_text.text == "") {
            normalDialog(context, "เตือน", "กรุณาเพิ่มชื่อผู้ซื้อ");
          } else {
            //แสดงภาพที่แก้ไข
            setState(() {
              file = File(result!.path);
              files[index] = file;
            });
            print('test2');
            showProgressLoading(context);
            upload_file(index, name_customer_text.text);
          }
        }
      }
      if (index >= 4 && index <= 7) {
        if (name_kam1_text.text == "") {
          normalDialog(context, "เตือน", "กรุณาเพิ่มชื่อผู้ค้ำ 1 ");
        } else {
          //แสดงภาพที่แก้ไข
          setState(() {
            file = File(result!.path);
            files[index] = file;
          });
          showProgressLoading(context);
          upload_file(index, name_kam1_text.text);
        }
      }
      if (index >= 8 && index <= 11) {
        if (name_kam2_text.text == "") {
          normalDialog(context, "เตือน", "กรุณาเพิ่มชื่อผู้ค้ำ 2 ");
        } else {
          //แสดงภาพที่แก้ไข
          setState(() {
            file = File(result!.path);
            files[index] = file;
          });
          showProgressLoading(context);
          upload_file(index, name_kam2_text.text);
        }
      }
      if (index >= 12 && index <= 15) {
        if (name_kam3_text.text == "") {
          normalDialog(context, "เตือน", "กรุณาเพิ่มชื่อผู้ค้ำ 3 ");
        } else {
          //แสดงภาพที่แก้ไข
          setState(() {
            file = File(result!.path);
            files[index] = file;
          });
          showProgressLoading(context);
          upload_file(index, name_kam3_text.text);
        }
      }
      if (index >= 19 && index <= 20) {
        setState(() {
          file = File(result!.path);
          files[index] = file;
        });
        showProgressLoading(context);
        upload_file(index, name_customer_text.text);
      }
    } catch (e) {
      print("error => $e");
    }
  }

  //อัปโหลดไฟล์ ผู้ซื้อ / ผู้ค้ำ
  Future<Null> upload_file(index, name) async {
    try {
      int i = Random().nextInt(10000000);
      String nameFile = 'edit_checker$i.jpg';
      String api_upload_img_customer =
          'http://$ipconfig_checker/CheckerData2/api/UpdateImgCusGuran.php?zone=${widget.zone}&saka=${widget.saka}&type_running=${widget.type_running}&running_id=${widget.running_id}&name=$name&id_user=${widget.id_user}&index=$index';
      Map<String, dynamic> map_customer = {};
      map_customer['file'] =
          await MultipartFile.fromFile(files[index]!.path, filename: nameFile);
      FormData data_customer = FormData.fromMap(map_customer);
      await Dio()
          .post(api_upload_img_customer, data: data_customer)
          .then((value) {
        Navigator.pop(context);
        successDialog(context, "สำเร็จ", "แก้ไขภาพเสร็จสิ้น");
      });
    } catch (e) {
      int i = Random().nextInt(10000000);
      String nameFile = 'edit_checker$i.jpg';
      String api_upload_img_customer =
          'http://$ipconfig_checker_office/CheckerData2/api/UpdateImgCusGuran.php?zone=${widget.zone}&saka=${widget.saka}&type_running=${widget.type_running}&running_id=${widget.running_id}&name=$name&id_user=${widget.id_user}&index=$index';
      Map<String, dynamic> map_customer = {};
      map_customer['file'] =
          await MultipartFile.fromFile(files[index]!.path, filename: nameFile);
      FormData data_customer = FormData.fromMap(map_customer);
      await Dio()
          .post(api_upload_img_customer, data: data_customer)
          .then((value) {
        Navigator.pop(context);
        successDialog(context, "สำเร็จ", "แก้ไขภาพเสร็จสิ้น");
      });
    }
  }
// -------------------------------------------------------------------------------------------------------------------------------------------------------

  //แก้ไข โซน/สาขา
  Future<Null> change_zonesaka(zone, saka) async {
    try {
      var uri = Uri.parse(
          "http://$ipconfig_checker/CheckerData2/api/UpdateZoneCountry.php");
      var request = new http.MultipartRequest("POST", uri);
      request.fields['zone'] = zone;
      request.fields['saka'] = saka;
      request.fields['id_user'] = widget.id_user!;
      var response = await request.send();
      if (response.statusCode == 200) {
        print("แก้ไขชื่อสำเร็จ");
        successDialog(context, "สำเร็จ", "แก้ไขเสร็จสิ้น");
        setState(() {
          show_edit_zonesaka = false;
        });
      } else {
        print("แก้ไขชื่อไม่สำเร็จ");
        normalDialog(context, "เตือน", "เกิดข้อผิดพลาด");
      }
    } catch (e) {
      var uri = Uri.parse(
          "http://$ipconfig_checker_office/CheckerData2/api/UpdateZoneCountry.php");
      var request = new http.MultipartRequest("POST", uri);
      request.fields['zone'] = zone;
      request.fields['saka'] = saka;
      request.fields['id_user'] = widget.id_user!;
      var response = await request.send();
      if (response.statusCode == 200) {
        print("แก้ไขชื่อสำเร็จ");
        successDialog(context, "สำเร็จ", "แก้ไขเสร็จสิ้น");
        setState(() {
          show_edit_zonesaka = false;
        });
      } else {
        print("แก้ไขชื่อไม่สำเร็จ");
        normalDialog(context, "เตือน", "เกิดข้อผิดพลาด");
      }
    }
  }

  // แก้ไขชื่อ
  Future<Null> change_name(prefix, name, lastname, type) async {
// type : 0 => ผู้ซื้อ, 1 => ค้ำ1, 2 => ค้ำ2, 3 => ค้ำ3,
    if (type == 0) {
      if (name == "" || name == null) {
        normalDialog(context, "เตือน", "กรุณาระบุชื่อผู้ซื้อ");
      } else {
        change_name_api(prefix, name, lastname, type);
      }
    }
    if (type == 1) {
      if (name == "" || name == null) {
        normalDialog(context, "เตือน", "กรุณาระบุชื่อผู้ค้ำ 1");
      } else {
        change_name_api(prefix, name, lastname, type);
      }
    }
    if (type == 2) {
      if (name == "" || name == null) {
        normalDialog(context, "เตือน", "กรุณาระบุชื่อผู้ค้ำ 2");
      } else {
        change_name_api(prefix, name, lastname, type);
      }
    }
    if (type == 3) {
      if (name == "" || name == null) {
        normalDialog(context, "เตือน", "กรุณาระบุชื่อผู้ค้ำ 3");
      } else {
        change_name_api(prefix, name, lastname, type);
      }
    }
  }

  //แสดงผล ฟอร์ม
  Future<Null> switch_form(type) async {
    //type ค้ำ 1 = 1 ,
    if (type == 1) {
      if (show_kam1 == false) {
        setState(() {
          show_kam1 = true;
        });
      } else {
        setState(() {
          show_kam1 = false;
        });
      }
    }
    if (type == 2) {
      if (show_kam2 == false) {
        setState(() {
          show_kam2 = true;
        });
      } else {
        setState(() {
          show_kam2 = false;
        });
      }
    }
    if (type == 3) {
      if (show_kam3 == false) {
        setState(() {
          show_kam3 = true;
        });
      } else {
        setState(() {
          show_kam3 = false;
        });
      }
    }
    if (type == 4) {
      if (show_other == false) {
        setState(() {
          show_other = true;
        });
      } else {
        setState(() {
          show_other = false;
        });
      }
    }
    if (type == 5) {
      if (show_more == false) {
        setState(() {
          show_more = true;
        });
      } else {
        setState(() {
          show_more = false;
        });
      }
    }
  }

  Future<void> openMap() async {
    print('mapEdit>> ${latitude}_${longitude}');
    Uri googleMapUrl = Uri.parse(
      'https://www.google.co.th/maps/search/?api=1&query=${latitude},${longitude}',
    );
    if (!await launcher.launchUrl(
      googleMapUrl,
      mode: launcher.LaunchMode.externalApplication,
    )) {
      throw Exception('Could not open the map $googleMapUrl');
    }
  }

  //แสดงแผนที่
  Future<Null> showmap() async {
    double size = MediaQuery.of(context).size.width;
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(5),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: size * 1.2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: lat == null
                  ? ShowProgress()
                  : GoogleMap(
                      myLocationEnabled: true,
                      // mapType: MapType.hybrid,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat!, lng!),
                        zoom: 16,
                      ),
                      onMapCreated: (controller) {},
                      markers: <Marker>[
                        Marker(
                          markerId: MarkerId('id'),
                          position: LatLng(lat!, lng!),
                          infoWindow: InfoWindow(
                              title: 'สถานที่ติดตั้ง',
                              snippet: 'Lat = $lat , lng = $lng'),
                        ),
                      ].toSet(),
                      onTap: (argument) {
                        if (data_customer[0].status !=
                            "ตรวจสอบสัญญาเรียบร้อย") {
                          setState(() {
                            lat = argument.latitude;
                            lng = argument.longitude;
                          });
                          Navigator.pop(context);
                          change_map_api(lat, lng);
                        }
                      },
                    ),
            )
          ],
        ),
      ),
      animationType: DialogTransitionType.slideFromBottomFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  //Api แก้ที่อยู่
  Future change_map_api(lat, lng) async {
    try {
      var uri = Uri.parse(
          "http://$ipconfig_checker/CheckerData2/api/UpdateGoogleMap.php");
      var request = new http.MultipartRequest("POST", uri);
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();
      request.fields['id_user'] = widget.id_user!;
      var response = await request.send();
      if (response.statusCode == 200) {
        // print("แก้ไขชื่อสำเร็จ");
        successDialog(context, "สำเร็จ", "แก้ไขที่อยู่สำเร็จ");
      } else {
        print("แก้ไขชื่อไม่สำเร็จ");
        normalDialog(context, "เตือน", "เกิดข้อผิดพลาด");
      }
    } catch (e) {
      var uri = Uri.parse(
          "http://$ipconfig_checker_office/CheckerData2/api/UpdateGoogleMap.php");
      var request = new http.MultipartRequest("POST", uri);
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();
      request.fields['id_user'] = widget.id_user!;
      var response = await request.send();
      if (response.statusCode == 200) {
        // print("แก้ไขชื่อสำเร็จ");
        successDialog(context, "สำเร็จ", "แก้ไขที่อยู่สำเร็จ");
      } else {
        print("แก้ไขชื่อไม่สำเร็จ");
        normalDialog(context, "เตือน", "เกิดข้อผิดพลาด");
      }
    }
  }

  //ซูมภาพ
  Future<Null> zoom_img(file_index, int index) async {
    double size = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        children: [
          Column(
            children: [
              Image.file(
                file_index[index]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  //ซูมภาพเดิม
  Future<Null> zoom_img_old(url) async {
    double size = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        children: [
          Column(
            children: [
              FadeInImage.assetNetwork(
                  placeholder: 'images/load_img.gif',
                  image: 'http://${widget.ip_conn}/CheckerData2/$url'),
            ],
          ),
        ],
      ),
    );
  }

  Future<Null> delete_img_more(id_more) async {
    try {
      var uri = Uri.parse(
          "http://$ipconfig_checker/CheckerData2/api/DeleteImgMore.php");
      var request = new http.MultipartRequest("POST", uri);
      request.fields['id_more'] = id_more.toString();
      var response = await request.send();
      if (response.statusCode == 200) {
        print("แก้ไขสำเร็จ");
      } else {
        print("แก้ไขไม่สำเร็จ");
      }
      _list_more();
    } catch (e) {
      var uri = Uri.parse(
          "http://$ipconfig_checker_office/CheckerData2/api/DeleteImgMore.php");
      var request = new http.MultipartRequest("POST", uri);
      request.fields['id_more'] = id_more.toString();
      var response = await request.send();
      if (response.statusCode == 200) {
        print("แก้ไขสำเร็จ");
      } else {
        print("แก้ไขไม่สำเร็จ");
      }
      _list_more();
    }
  }
//------------------------------------------------------- บันทึก / จัดการภาพ เพิ่มเติม --------------------------------------------------------------------------

  Future<Null> img_more(name) async {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        title: ListTile(
          leading: Icon(
            Icons.image,
            size: 55,
          ),
          title: Text(
            '$name',
            style: MyConstant().h3Style(),
          ),
          subtitle: Text(
            'โปรดเลือกภาพ ',
            style: MyConstant().h3Style(),
          ),
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  process_img_more(ImageSource.gallery);
                },
                child: Text(
                  "คลังภาพ",
                  style: MyConstant().h3Style(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  process_img_more(ImageSource.camera);
                },
                child: Text(
                  "เปิดกล้อง",
                  style: MyConstant().h3Style(),
                ),
              ),
            ],
          )
        ],
      ),
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 0),
    );
  }

  Future<Null> process_img_more(ImageSource source) async {
    try {
      var result = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
      );
      setState(() {
        file_more = File(result!.path);
        upload_file_more();
      });
    } catch (e) {}
  }

  Future<Null> upload_file_more() async {
    try {
      int i = Random().nextInt(10000000);
      String nameFile = 'edit_checker_more$i.jpg';
      String api_upload_img_more =
          'http://$ipconfig_checker/CheckerData2/api/UploadImgMore.php?zone=${widget.zone}&saka=${widget.saka}&type_running=${widget.type_running}&running_id=${widget.running_id}';
      Map<String, dynamic> map_more = {};
      map_more['file'] =
          await MultipartFile.fromFile(file_more!.path, filename: nameFile);
      FormData data_more = FormData.fromMap(map_more);
      await Dio().post(api_upload_img_more, data: data_more).then((value) {
        _list_more();
        print("---------------- success upload ----------------------");
      });
    } catch (e) {
      int i = Random().nextInt(10000000);
      String nameFile = 'edit_checker_more$i.jpg';
      String api_upload_img_more =
          'http://$ipconfig_checker_office/CheckerData2/api/UploadImgMore.php?zone=${widget.zone}&saka=${widget.saka}&type_running=${widget.type_running}&running_id=${widget.running_id}';
      Map<String, dynamic> map_more = {};
      map_more['file'] =
          await MultipartFile.fromFile(file_more!.path, filename: nameFile);
      FormData data_more = FormData.fromMap(map_more);
      await Dio().post(api_upload_img_more, data: data_more).then((value) {
        _list_more();
        print("---------------- success upload ----------------------");
      });
    }
  }

// -
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        centerTitle: true,
        backgroundColor: MyConstant.dark_f,
        elevation: 0,
        title: Text(
          "แก้ไขข้อมูล",
          style: MyConstant().h2whiteStyle(),
        ),
      ),
      body: data_customer.isEmpty || files.isEmpty
          ? ShowProgress()
          : GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      input_runing(size),
                      SizedBox(height: 10),
                      input_customer(size),
                      SizedBox(height: 10),
                      input_kam1(size),
                      SizedBox(height: 10),
                      input_kam2(size),
                      SizedBox(height: 10),
                      input_kam3(size),
                      if (widget.level == "checker_runnig") ...[
                        SizedBox(height: 10),
                        input_other(size),
                      ],
                      SizedBox(height: 10),
                      input_more(size),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  //ข้อมูลเลขรันนิ่งสัญญา
  Widget input_runing(double size) => Container(
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15.0),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    color: Colors.blue[50],
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                    child: Row(
                      children: [
                        Text(
                          "เลขที่รันนิ่งสัญญา",
                          style: MyConstant().h2_5Style(),
                        )
                      ],
                    ),
                  ),
                  filtter_branch(context),
                ],
              ),
            ),
            Container(
              // margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: MyConstant().h3Style(),
                          controller: id_running_text,
                          maxLength: widget.level == "checker_runnig" ||
                                  widget.level == "chief" ||
                                  widget.level == "follow_up_debt"
                              ? 7
                              : 6,
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            prefixIcon: Icon(Icons.confirmation_number),
                            suffixIcon: Icon(
                              Icons.check,
                              color: Colors.green,
                              size: size * 0.06,
                            ),
                            labelText: "เลขรันนิ่งสัญญา",
                            labelStyle: MyConstant().normalStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.level == "checker_runnig") ...[
              Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    children: [
                      filtter_zone(context),
                      SizedBox(height: 10),
                      filtter_saka(context),
                      SizedBox(height: 10),
                      if (show_edit_zonesaka == true) ...[
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: MyConstant().normalyelloStyle(),
                          ),
                          onPressed: () {
                            change_zonesaka(val_zone, val_saka);
                          },
                          child: Text(
                            'แก้ไข',
                            style: MyConstant().normalyelloStyle(),
                          ),
                        ),
                      ]
                    ],
                  )),
            ] else ...[
              Container(
                padding: EdgeInsets.all(10),
                color: Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
                margin: EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_history,
                              color: Color.fromRGBO(27, 55, 120, 1.0),
                              size: size * 0.06,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "เขต : ${widget.zone}",
                              style: MyConstant().h3Style(),
                            ),
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_city_rounded,
                              color: Color.fromRGBO(27, 55, 120, 1.0),
                              size: size * 0.06,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "สาขา : ${widget.saka}",
                              style: MyConstant().h3Style(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Row filtter_branch(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.width * 0.11,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1.0,
                        style: BorderStyle.solid,
                        color: MyConstant.dark),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: DropdownButton(
                  isExpanded: true,
                  hint: Text(
                    "ประเภทเอกสาร",
                    style: MyConstant().normalStyle(),
                  ),
                  value: selectedValue,
                  items: <String>['A', 'C', 'D']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: null,
                  underline: Container(
                    height: 2,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  //ข้อมูลผู้ซื้อ
  Widget input_customer(double size) => Container(
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Colors.blue[50],
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Container(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_history),
                                Text(
                                  " ผู้ซื้อ",
                                  style: MyConstant().h2_5Style(),
                                )
                              ],
                            )
                          ],
                        ),
                        Column(
                          children: [
                            if (widget.level != "checker_runnig") ...{
                              InkWell(
                                onTap: () {
                                  if (lat != null) {
                                    // showmap();
                                    openMap();
                                  }
                                },
                                child: Icon(Icons.pin_drop_rounded),
                              ),
                            },
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: prefixname_customer_text,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(fontSize: 12),
                            contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          style: const TextStyle(color: Colors.deepPurple),
                          hint: Text(
                            "คำนำหน้าชื่อ",
                            style: MyConstant().normalStyle(),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              prefixname_customer_text = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'กรุณาเพิ่ม คำนำหน้าชื่อ';
                            }
                          },
                          items: <String>['นาย', 'นางสาว', 'นาง']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: MyConstant().h3Style(),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: MyConstant().h3Style(),
                          controller: name_customer_text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาเพิ่ม ชื่อ ผู้ซื้อ';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                            errorStyle: TextStyle(fontSize: 12),
                            prefixIcon: Icon(Icons.location_history),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            labelText: "ชื่อ",
                            labelStyle: MyConstant().normalStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: MyConstant().h3Style(),
                          controller: lastname_customer_text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาเพิ่ม นามสกุล ผู้ซื้อ';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                            errorStyle: TextStyle(fontSize: 12),
                            prefixIcon: Icon(Icons.location_history),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            labelText: "นามสกุล",
                            labelStyle: MyConstant().normalStyle(),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (data_customer[0]['status'] !=
                              "ตรวจสอบสัญญาเรียบร้อย" ||
                          widget.level == "checker_runnig") ...[
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: MyConstant().normalyelloStyle(),
                          ),
                          onPressed: () {
                            change_name(
                                prefixname_customer_text,
                                name_customer_text.text,
                                lastname_customer_text.text,
                                0);
                          },
                          child: Text(
                            'แก้ไข',
                            style: MyConstant().normalyelloStyle(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        size: size * 0.06,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "รูปบัตรประชาชน",
                        style: MyConstant().h3Style(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          if (data_customer[0]['status'] !=
                                  "ตรวจสอบสัญญาเรียบร้อย" ||
                              widget.level == "checker_runnig") {
                            img_customer("รูปบัตรประชาชน", 0);
                          }
                        },
                        onLongPress: () {
                          if (files[0] != null) {
                            zoom_img(files, 0);
                          } else {
                            zoom_img_old(data_customer[0]['cus_card_id_img']);
                          }
                        },
                        child: files[0] == null
                            ? show_imgold(size,
                                data_customer[0]['cus_card_id_img'], ipconfig)
                            : show_imgCustomer(size, 0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.map,
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        size: size * 0.06,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "แผนที่บ้าน",
                        style: MyConstant().h3Style(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          if (data_customer[0]['status'] !=
                                  "ตรวจสอบสัญญาเรียบร้อย" ||
                              widget.level == "checker_runnig") {
                            img_customer("แผนที่บ้าน", 1);
                          }
                        },
                        onLongPress: () {
                          if (files[1] != null) {
                            zoom_img(files, 1);
                          } else {
                            zoom_img_old(data_customer[0]['cus_maps_img']);
                          }
                        },
                        child: files[1] == null
                            ? show_imgold(size,
                                data_customer[0]['cus_maps_img'], ipconfig)
                            : show_imgCustomer(size, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.maps_home_work,
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        size: size * 0.06,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "รูปบ้าน",
                        style: MyConstant().h3Style(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          if (data_customer[0]['status'] !=
                                  "ตรวจสอบสัญญาเรียบร้อย" ||
                              widget.level == "checker_runnig") {
                            img_customer("รูปบ้าน", 2);
                          }
                        },
                        onLongPress: () {
                          if (files[2] != null) {
                            zoom_img(files, 2);
                          } else {
                            zoom_img_old(data_customer[0]['cus_address_img']);
                          }
                        },
                        child: files[2] == null
                            ? show_imgold(size,
                                data_customer[0]['cus_address_img'], ipconfig)
                            : show_imgCustomer(size, 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.create_rounded,
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        size: size * 0.06,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "รูปตอนเซ็น",
                        style: MyConstant().h3Style(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          if (data_customer[0]['status'] !=
                                  "ตรวจสอบสัญญาเรียบร้อย" ||
                              widget.level == "checker_runnig") {
                            img_customer("รูปตอนเซ็น", 3);
                          }
                        },
                        onLongPress: () {
                          if (files[3] != null) {
                            zoom_img(files, 3);
                          } else {
                            zoom_img_old(data_customer[0]['cus_licen_img']);
                          }
                        },
                        child: files[3] == null
                            ? show_imgold(size,
                                data_customer[0]['cus_licen_img'], ipconfig)
                            : show_imgCustomer(size, 3),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            if (widget.level == "checker_runnig") ...[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.book,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "หน้าสัญญา",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_customer(
                                "หน้าสัญญา${data_customer[0]['cus_contract_img']}",
                                16);
                          },
                          onLongPress: () {
                            if (files[16] != null) {
                              zoom_img(files, 16);
                            } else {
                              zoom_img_old(
                                  data_customer[0]['cus_contract_img']);
                            }
                          },
                          child: files[16] == null
                              ? show_imgold(
                                  size,
                                  data_customer[0]['cus_contract_img'],
                                  ipconfig)
                              : show_imgCustomer(size, 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "ใบขอเช่าซื้อ",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_customer("ใบขอเช่าซื้อ", 17);
                          },
                          onLongPress: () {
                            if (files[17] != null) {
                              zoom_img(files, 17);
                            } else {
                              zoom_img_old(
                                  data_customer[0]['cus_purchase_img']);
                            }
                          },
                          child: files[17] == null
                              ? show_imgold(
                                  size,
                                  data_customer[0]['cus_purchase_img'],
                                  ipconfig)
                              : show_imgCustomer(size, 17),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car_filled_rounded,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปรับรถ",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_customer("รูปรับรถ", 18);
                          },
                          onLongPress: () {
                            if (files[18] != null) {
                              zoom_img(files, 18);
                            } else {
                              zoom_img_old(data_customer[0]['cus_offer_img']);
                            }
                          },
                          child: files[18] == null
                              ? show_imgold(size,
                                  data_customer[0]['cus_offer_img'], ipconfig)
                              : show_imgCustomer(size, 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  //ผู้ค้ำ 1
  Widget input_kam1(double size) => Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                switch_form(1);
              },
              child: Container(
                color: Colors.blue[50],
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_history),
                                  Text(
                                    " ผู้ค้ำ 1",
                                    style: MyConstant().h2_5Style(),
                                  )
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              if (show_kam1 == false) ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_kam1 = true;
                                      });
                                    },
                                    child: Icon(Icons.arrow_drop_up_outlined)),
                              ] else ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_kam1 = false;
                                      });
                                    },
                                    child:
                                        Icon(Icons.arrow_drop_down_outlined)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (show_kam1 == true) ...[
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: prefixname_kam1_text,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 12),
                              contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            style: const TextStyle(color: Colors.deepPurple),
                            hint: Text(
                              "คำนำหน้าชื่อ",
                              style: MyConstant().normalStyle(),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                prefixname_kam1_text = newValue!;
                              });
                            },
                            items: <String>['นาย', 'นางสาว', 'นาง']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: MyConstant().h3Style(),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: name_kam1_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "ชื่อ ผู้ค้ำ 1",
                              labelStyle: MyConstant().normalStyle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: lastname_kam1_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "นามสกุล ผู้ค้ำ 1",
                              labelStyle: MyConstant().normalStyle(),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (data_customer[0]['status'] !=
                                "ตรวจสอบสัญญาเรียบร้อย" ||
                            widget.level == "checker_runnig") ...[
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: MyConstant().normalyelloStyle(),
                            ),
                            onPressed: () {
                              change_name(
                                  prefixname_kam1_text,
                                  name_kam1_text.text,
                                  lastname_kam1_text.text,
                                  1);
                            },
                            child: Text(
                              'แก้ไข',
                              style: MyConstant().normalyelloStyle(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปบัตรประชาชน (ผู้ค้ำ 1)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("รูปบัตรประชาชน", 4);
                            }
                          },
                          onLongPress: () {
                            if (files[4] != null) {
                              zoom_img(files, 4);
                            } else {
                              zoom_img_old(data_customer[0]['G1_IdcardImg']);
                            }
                          },
                          child: files[4] == null
                              ? show_imgold(size,
                                  data_customer[0]['G1_IdcardImg'], ipconfig)
                              : show_imgCustomer(size, 4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "แผนที่บ้าน (ผู้ค้ำ 1)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("แผนที่บ้าน", 5);
                            }
                          },
                          onLongPress: () {
                            if (files[5] != null) {
                              zoom_img(files, 5);
                            } else {
                              zoom_img_old(data_customer[0]['G1_MapImg']);
                            }
                          },
                          child: files[5] == null
                              ? show_imgold(
                                  size, data_customer[0]['G1_MapImg'], ipconfig)
                              : show_imgCustomer(size, 5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.maps_home_work,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปบ้าน (ผู้ค้ำ 1)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("รูปบ้าน", 6);
                            }
                          },
                          onLongPress: () {
                            if (files[6] != null) {
                              zoom_img(files, 6);
                            } else {
                              zoom_img_old(data_customer[0]['G1_HouseImg']);
                            }
                          },
                          child: files[6] == null
                              ? show_imgold(size,
                                  data_customer[0]['G1_HouseImg'], ipconfig)
                              : show_imgCustomer(size, 6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.create_rounded,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปตอนเซ็น (ผู้ค้ำ 1)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("รูปตอนเซ็น", 7);
                            }
                          },
                          onLongPress: () {
                            if (files[7] != null) {
                              zoom_img(files, 7);
                            } else {
                              zoom_img_old(data_customer[0]['G1_PactImg']);
                            }
                          },
                          child: files[7] == null
                              ? show_imgold(size,
                                  data_customer[0]['G1_PactImg'], ipconfig)
                              : show_imgCustomer(size, 7),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  //ผู้ค้ำ 2
  Widget input_kam2(double size) => Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                switch_form(2);
              },
              child: Container(
                color: Colors.blue[50],
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_history),
                                  Text(
                                    " ผู้ค้ำ 2",
                                    style: MyConstant().h2_5Style(),
                                  )
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              if (show_kam2 == false) ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_kam2 = true;
                                      });
                                    },
                                    child: Icon(Icons.arrow_drop_up_outlined)),
                              ] else ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_kam2 = false;
                                      });
                                    },
                                    child:
                                        Icon(Icons.arrow_drop_down_outlined)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (show_kam2 == true) ...[
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: prefixname_kam2_text,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 12),
                              contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            style: const TextStyle(color: Colors.deepPurple),
                            hint: Text(
                              "คำนำหน้าชื่อ",
                              style: MyConstant().normalStyle(),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                prefixname_kam2_text = newValue!;
                              });
                            },
                            items: <String>['นาย', 'นางสาว', 'นาง']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: MyConstant().h3Style(),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: name_kam2_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "ชื่อ ผู้ค้ำ 2",
                              labelStyle: MyConstant().normalStyle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: lastname_kam2_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "นามสกุล ผู้ค้ำ 2",
                              labelStyle: MyConstant().normalStyle(),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (data_customer[0]['status'] !=
                                "ตรวจสอบสัญญาเรียบร้อย" ||
                            widget.level == "checker_runnig") ...[
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: MyConstant().normalyelloStyle(),
                            ),
                            onPressed: () {
                              change_name(
                                  prefixname_kam2_text,
                                  name_kam2_text.text,
                                  lastname_kam2_text.text,
                                  2);
                            },
                            child: Text(
                              'แก้ไข',
                              style: MyConstant().normalyelloStyle(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปบัตรประชาชน (ผู้ค้ำ 2)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("รูปบัตรประชาชน", 8);
                            }
                          },
                          onLongPress: () {
                            if (files[8] != null) {
                              zoom_img(files, 8);
                            } else {
                              zoom_img_old(data_customer[0]['G2_IdcardImg']);
                            }
                          },
                          child: files[8] == null
                              ? show_imgold(size,
                                  data_customer[0]['G2_IdcardImg'], ipconfig)
                              : show_imgCustomer(size, 8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "แผนที่บ้าน (ผู้ค้ำ 2)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("แผนที่บ้าน", 9);
                            }
                          },
                          onLongPress: () {
                            if (files[9] != null) {
                              zoom_img(files, 9);
                            } else {
                              zoom_img_old(data_customer[0]['G2_MapImg']);
                            }
                          },
                          child: files[9] == null
                              ? show_imgold(
                                  size, data_customer[0]['G2_MapImg'], ipconfig)
                              : show_imgCustomer(size, 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.maps_home_work,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปบ้าน (ผู้ค้ำ 2)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("รูปบ้าน", 10);
                            }
                          },
                          onLongPress: () {
                            if (files[10] != null) {
                              zoom_img(files, 10);
                            } else {
                              zoom_img_old(data_customer[0]['G2_HouseImg']);
                            }
                          },
                          child: files[10] == null
                              ? show_imgold(size,
                                  data_customer[0]['G2_HouseImg'], ipconfig)
                              : show_imgCustomer(size, 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.create_rounded,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปตอนเซ็น (ผู้ค้ำ 2)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("รูปตอนเซ็น", 11);
                            }
                          },
                          onLongPress: () {
                            if (files[11] != null) {
                              zoom_img(files, 11);
                            } else {
                              zoom_img_old(data_customer[0]['G2_PactImg']);
                            }
                          },
                          child: files[11] == null
                              ? show_imgold(size,
                                  data_customer[0]['G2_PactImg'], ipconfig)
                              : show_imgCustomer(size, 11),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  //ผู้ค้ำ 3
  Widget input_kam3(double size) => Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                switch_form(3);
              },
              child: Container(
                color: Colors.blue[50],
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_history),
                                  Text(
                                    " ผู้ค้ำ 3",
                                    style: MyConstant().h2_5Style(),
                                  )
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              if (show_kam3 == false) ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_kam3 = true;
                                      });
                                    },
                                    child: Icon(Icons.arrow_drop_up_outlined)),
                              ] else ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_kam3 = false;
                                      });
                                    },
                                    child:
                                        Icon(Icons.arrow_drop_down_outlined)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (show_kam3 == true) ...[
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: prefixname_kam3_text,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 12),
                              contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            style: const TextStyle(color: Colors.deepPurple),
                            hint: Text(
                              "คำนำหน้าชื่อ",
                              style: MyConstant().normalStyle(),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                prefixname_kam3_text = newValue!;
                              });
                            },
                            items: <String>['นาย', 'นางสาว', 'นาง']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: MyConstant().h3Style(),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: name_kam3_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "ชื่อ ผู้ค้ำ 3",
                              labelStyle: MyConstant().normalStyle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: lastname_kam3_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "นามสกุล ผู้ค้ำ 3",
                              labelStyle: MyConstant().normalStyle(),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (data_customer[0]['status'] !=
                                "ตรวจสอบสัญญาเรียบร้อย" ||
                            widget.level == "checker_runnig") ...[
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: MyConstant().normalyelloStyle(),
                            ),
                            onPressed: () {
                              change_name(
                                  prefixname_kam3_text,
                                  name_kam3_text.text,
                                  lastname_kam3_text.text,
                                  3);
                            },
                            child: Text(
                              'แก้ไข',
                              style: MyConstant().normalyelloStyle(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปบัตรประชาชน (ผู้ค้ำ 3)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("รูปบัตรประชาชน", 12);
                            }
                          },
                          onLongPress: () {
                            if (files[12] != null) {
                              zoom_img(files, 12);
                            } else {
                              zoom_img_old(data_customer[0]['G3_IdcardImg']);
                            }
                          },
                          child: files[12] == null
                              ? show_imgold(size,
                                  data_customer[0]['G3_IdcardImg'], ipconfig)
                              : show_imgCustomer(size, 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "แผนที่บ้าน (ผู้ค้ำ 3)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("แผนที่บ้าน", 13);
                            }
                          },
                          onLongPress: () {
                            if (files[13] != null) {
                              zoom_img(files, 13);
                            } else {
                              zoom_img_old(data_customer[0]['G3_MapImg']);
                            }
                          },
                          child: files[13] == null
                              ? show_imgold(
                                  size, data_customer[0]['G3_MapImg'], ipconfig)
                              : show_imgCustomer(size, 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.maps_home_work,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปบ้าน (ผู้ค้ำ 3)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("รูปบ้าน", 14);
                            }
                          },
                          onLongPress: () {
                            if (files[14] != null) {
                              zoom_img(files, 14);
                            } else {
                              zoom_img_old(data_customer[0]['G3_HouseImg']);
                            }
                          },
                          child: files[14] == null
                              ? show_imgold(size,
                                  data_customer[0]['G3_HouseImg'], ipconfig)
                              : show_imgCustomer(size, 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.create_rounded,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "รูปตอนเซ็น (ผู้ค้ำ 3)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (data_customer[0]['status'] !=
                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                widget.level == "checker_runnig") {
                              img_customer("รูปตอนเซ็น", 15);
                            }
                          },
                          onLongPress: () {
                            if (files[15] != null) {
                              zoom_img(files, 15);
                            } else {
                              zoom_img_old(data_customer[0]['G3_PactImg']);
                            }
                          },
                          child: files[15] == null
                              ? show_imgold(size,
                                  data_customer[0]['G3_PactImg'], ipconfig)
                              : show_imgCustomer(size, 15),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  // อื่นๆ
  Widget input_other(double size) => Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                switch_form(4);
              },
              child: Container(
                color: Colors.blue[50],
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  // Icon(Icons.location_history),
                                  Text(
                                    " อื่นๆ",
                                    style: MyConstant().h2_5Style(),
                                  )
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              if (show_other == false) ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_other = true;
                                      });
                                    },
                                    child: Icon(Icons.arrow_drop_up_outlined)),
                              ] else ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_other = false;
                                      });
                                    },
                                    child:
                                        Icon(Icons.arrow_drop_down_outlined)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (show_other == true) ...[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "ใบรายงาน",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_customer("ใบรายงาน", 19);
                          },
                          child: files[19] == null
                              ? show_imgold(size,
                                  data_customer[0]['report_etc_img'], ipconfig)
                              : show_imgCustomer(size, 19),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "สัญญาหน้าหลังสุด(ลายเซ็นคนค้ำ)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_customer("สัญญาหน้าหลังสุด(ลายเซ็นคนค้ำ)", 20);
                          },
                          child: files[20] == null
                              ? show_imgold(size,
                                  data_customer[0]['licen_etc_img'], ipconfig)
                              : show_imgCustomer(size, 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  //ภาพเพิ่มเติม
  Widget input_more(double size) => Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                switch_form(5);
              },
              child: Container(
                color: Colors.blue[50],
                margin: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  // Icon(Icons.location_history),
                                  Text(
                                    " ภาพเพิ่มเติม",
                                    style: MyConstant().h2_5Style(),
                                  )
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              if (show_more == false) ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_more = true;
                                      });
                                    },
                                    child: Icon(Icons.arrow_drop_up_outlined)),
                              ] else ...[
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        show_more = false;
                                      });
                                    },
                                    child:
                                        Icon(Icons.arrow_drop_down_outlined)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (show_more == true) ...[
              Container(
                margin: EdgeInsets.only(bottom: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: Color.fromRGBO(27, 55, 120, 1.0),
                          size: size * 0.06,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "ภาพเพิ่มเติม (ไม่จำเป็นต้องระบุ)",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                    if (list_more.length > 0) ...[
                      SizedBox(width: 10),
                      Row(
                        children: [
                          Text(
                            '*ภาพเพิ่มเติมมี ${list_more.length} ภาพ',
                            style: MyConstant().h3Style(),
                          ),
                        ],
                      ),
                    ],
                    Column(
                      children: [
                        show_imgmore(size),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            img_more("ภาพเพิ่มเติม");
                          },
                          child: Icon(
                            Icons.add_photo_alternate_sharp,
                            color: Colors.grey[400],
                            size: size * 0.18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  //list โซน
  Row filtter_zone(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.width * 0.11,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1.0,
                        style: BorderStyle.solid,
                        color: MyConstant.dark),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: DropdownButton(
                  isExpanded: true,
                  hint: Text(
                    "โซน",
                    style: MyConstant().normalStyle(),
                  ),
                  value: val_zone,
                  items: list_zone.map((listzone) {
                    return DropdownMenuItem(
                        value: listzone['zone'],
                        child: Text(
                          listzone['zone'],
                          style: MyConstant().h3Style(),
                        ));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      val_zone = value as String?;
                      _list_saka(val_zone);
                      show_edit_zonesaka = false;
                    });
                  },
                  underline: Container(
                    height: 2,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

//list สาขา
  Row filtter_saka(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.width * 0.11,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1.0,
                        style: BorderStyle.solid,
                        color: MyConstant.dark),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: DropdownButton(
                  isExpanded: true,
                  hint: Text(
                    "สาขา",
                    style: MyConstant().normalStyle(),
                  ),
                  value: val_saka,
                  items: list_saka.map((listsaka) {
                    return DropdownMenuItem(
                        value: listsaka['saka'],
                        child: Text(
                          listsaka['saka'],
                          style: MyConstant().h3Style(),
                        ));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      val_saka = value as String?;
                      show_edit_zonesaka = true;
                    });
                  },
                  underline: Container(
                    height: 2,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Container show_imgold(size, img, ipconn) {
    if (img == "ไม่มี" ||
        img == "" ||
        img == "ยังไม่ได้ส่งหมอบ" ||
        img == null) {
      return Container(
          child: Icon(
        Icons.add_photo_alternate_sharp,
        color: Colors.grey[400],
        size: size * 0.18,
      ));
    } else {
      return Container(
        decoration: new BoxDecoration(color: Colors.white),
        alignment: Alignment.center,
        // height: size * 0.42,
        height: MediaQuery.of(context).size.height * 0.187,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FadeInImage.assetNetwork(
              placeholder: 'images/load_img.gif',
              image: 'http://${widget.ip_conn}/CheckerData2/$img'),
        ),
        // child: Image.network('http://${widget.ip_conn}/checker_data/$img'),
      );
    }
  }

  Stack show_imgCustomer(size, index) {
    return Stack(
      children: <Widget>[
        InkWell(
          child: Container(
            decoration: new BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.187,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                files[index]!,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container show_imgmore(size) {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (list_more.isNotEmpty) ...[
              for (var i = 0; i < list_more.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10),
                  child: Stack(
                    children: <Widget>[
                      InkWell(
                        // onTap: () => zoom_img(0),
                        child: Container(
                          decoration: new BoxDecoration(color: Colors.white),
                          alignment: Alignment.center,
                          height: size * 0.45,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FadeInImage.assetNetwork(
                                placeholder: 'images/load_img.gif',
                                image:
                                    'http://${widget.ip_conn}/CheckerData2/${list_more[i]['name_img']}'),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: InkWell(
                          onTap: () {
                            delete_img_more(list_more[i]['id_other']);
                          },
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              color: Colors.white38,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(27, 55, 120, 1.0),

                                  offset: Offset(0, 0), // Shadow position
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
