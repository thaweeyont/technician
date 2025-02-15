import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig_checkerlog.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;
import 'package:technician/widgets/show_progress.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class AddCheckerLog extends StatefulWidget {
  final String? saka, zone, name_user, ip_conn, level;
  AddCheckerLog(this.saka, this.zone, this.name_user, this.ip_conn, this.level);

  @override
  _AddCheckerLogState createState() => _AddCheckerLogState();
}

class _AddCheckerLogState extends State<AddCheckerLog> {
  double? lat, lng;
  String? selectedValue;
  File? file;
  File? file_kam1;
  File? file_kam2;
  File? file_kam3;
  File? file_other;
  int index_more = 0;
  File? file_more;
  bool check_runing = false;
  List<File?> files = [];
  List<File?> files_kam1 = [];
  List<File?> files_kam2 = [];
  List<File?> files_kam3 = [];
  List<File?> files_other = [];
  List<File?> files_more = [];
  int check_kam1 = 0; //0 ไม่บันทึก 1 บันทึก 2 บันทึกไม่ครบ
  int check_kam2 = 0;
  int check_kam3 = 0;
  int check_other = 0;
  int check_more = 0;
  bool show_kam1 = false;
  bool show_kam2 = false;
  bool show_kam3 = false;
  bool show_other = false;
  bool show_more = false;
  bool isCheckedCK = false;
  List typerunnig = [];
  List list_zone = [];
  List list_saka = [];
  String? val_zone;
  String? val_saka;
  String? prefixname_customer_text;
  String? prefixname_kam1_text;
  String? prefixname_kam2_text;
  String? prefixname_kam3_text;
  String checkDoc = '';
  // ตั้ง id text in put
  TextEditingController id_running_text = TextEditingController();
  // TextEditingController prefixname_customer_text = TextEditingController();
  TextEditingController name_customer_text = TextEditingController();
  TextEditingController lastname_customer_text = TextEditingController();
  TextEditingController name_kam1_text = TextEditingController();
  TextEditingController lastname_kam1_text = TextEditingController();
  TextEditingController name_kam2_text = TextEditingController();
  TextEditingController lastname_kam2_text = TextEditingController();
  TextEditingController name_kam3_text = TextEditingController();
  TextEditingController lastname_kam3_text = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Completer<GoogleMapController> _controller = Completer();
  @override
  void initState() {
    super.initState();
    st_set_val();
    // _list_saka(widget.zone.toString());
    type_running();
    CheckPermission();
    initialFile_customer();
    _list_zone();
  }

  //set_st_value
  Future<void> st_set_val() async {
    if (widget.level == 'checker') {
      setState(() {
        val_zone = widget.zone;
        val_saka = widget.saka;
      });
    }
    print("zone=>$val_zone saka=>$val_saka");
  }

  //type_runing
  Future<Null> type_running() async {
    try {
      var respose = await http
          .get(Uri.http(ipconfig_checker, '/CheckerData2/api/TypeRunning.php'));
      if (respose.statusCode == 200) {
        var jsonData = jsonDecode(respose.body);
        setState(() {
          typerunnig = jsonData;
        });
      }
    } catch (e) {
      var respose = await http.get(Uri.http(
          ipconfig_checker_office, '/CheckerData2/api/TypeRunning.php'));
      if (respose.statusCode == 200) {
        var jsonData = jsonDecode(respose.body);
        setState(() {
          typerunnig = jsonData;
        });
      }
    }
  }

  //list_zone
  Future<void> _list_zone() async {
    try {
      var respose = await http
          .get(Uri.http(ipconfig_checker, '/CheckerData2/api/Zone.php'));
      if (respose.statusCode == 200) {
        var jsonData = json.decode(respose.body);
        setState(() {
          list_zone = jsonData;
        });
        // _list_saka(val_zone);
      }
    } catch (e) {
      var respose = await http
          .get(Uri.http(ipconfig_checker_office, '/CheckerData2/api/Zone.php'));
      if (respose.statusCode == 200) {
        var jsonData = json.decode(respose.body);
        setState(() {
          list_zone = jsonData;
        });
        // _list_saka(val_zone);
      }
    }
  }

  //list_saka
  Future<void> _list_saka(zone) async {
    try {
      var respose = await http.get(Uri.http(ipconfig_checker,
          '/CheckerData2/api/Branch.php', {"zone": zone.toString()}));
      if (respose.statusCode == 200) {
        var jsonData = json.decode(respose.body);
        setState(() {
          list_saka = jsonData;
        });
      }
    } catch (e) {
      var respose = await http.get(Uri.http(ipconfig_checker_office,
          '/CheckerData2/api/Branch.php', {"zone": zone.toString()}));
      if (respose.statusCode == 200) {
        var jsonData = json.decode(respose.body);
        setState(() {
          list_saka = jsonData;
        });
      }
    }
  }

  // CheckPermission
  Future<Null> CheckPermission() async {
    bool locationService;
    LocationPermission locationPermission;

    locationService = await Geolocator.isLocationServiceEnabled();
    if (locationService) {
      print('Service Location Open');
      locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.deniedForever) {
          alertLocationService(context, 'ไม่อนุญาติแชร์ Location1',
              'โปรดแชร์ location เพื่อใช้งาน');
        } else {
          // Find LatLong
          findLatLng();
        }
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          alertLocationService(context, 'ไม่อนุญาติแชร์ Location2',
              'โปรดแชร์ location เพื่อใช้งาน');
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
            'โปรดเลือกภาพ',
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
        maxWidth: 1080,
        maxHeight: 1920,
      );
      setState(() {
        file = File(result!.path);
        files[index] = file;
      });
    } catch (e) {}
  }

  //delete ภาพ
  Future<Null> delete_img_customer(int index) async {
    setState(() {
      files[index] = null;
    });
  }

  //ไฟล์ภาพ เซ็ทค่าตั้งต้น
  void initialFile_customer() {
    if (widget.level == "checker_runnig") {
      for (var i = 0; i < 7; i++) {
        files.add(null);
      }
    } else {
      for (var i = 0; i < 4; i++) {
        files.add(null);
      }
    }
    for (var i = 0; i < 4; i++) {
      files_kam1.add(null);
    }

    for (var i = 0; i < 4; i++) {
      files_kam2.add(null);
    }

    for (var i = 0; i < 4; i++) {
      files_kam3.add(null);
    }
    for (var i = 0; i < 2; i++) {
      files_other.add(null);
    }
  }

//------------------------------------------------------- บันทึก / จัดการภาพผู้ค้ำ 1 --------------------------------------------------------------------------
  Future<Null> img_kam1(name, index) async {
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
            '$name ผู้ค้ำ 1',
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
                  process_img_kam1(ImageSource.gallery, index);
                },
                child: Text(
                  "คลังภาพ",
                  style: MyConstant().h3Style(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  process_img_kam1(ImageSource.camera, index);
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

  Future<Null> process_img_kam1(ImageSource source, int index) async {
    try {
      var result = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
      );
      if (name_kam1_text.text == "") {
        normalDialog(context, "เตือน", "กรุณาเพิ่มชื่อ ผู้ค้ำ1");
      } else {
        setState(() {
          file_kam1 = File(result!.path);
          files_kam1[index] = file_kam1;

          int count_kam1 = 0;
          for (var item in files_kam1) {
            if (item == null) {
              count_kam1++;
            }
          }
          if (count_kam1 == 0) {
            check_kam1 = 1;
          } else if (count_kam1 == 4) {
            check_kam1 = 0;
          } else {
            check_kam1 = 2;
          }
        });
      }
    } catch (e) {}
  }

  //delete ภาพ
  Future<Null> delete_img_kam1(int index) async {
    setState(() {
      files_kam1[index] = null;
      int count_kam1 = 0;
      for (var item in files_kam1) {
        if (item == null) {
          count_kam1++;
        }
      }
      if (count_kam1 == 0) {
        check_kam1 = 1;
      } else if (count_kam1 == 4) {
        check_kam1 = 0;
        name_kam1_text.clear();
      } else {
        check_kam1 = 2;
      }
    });
  }

//------------------------------------------------------- บันทึก / จัดการภาพผู้ค้ำ 2 --------------------------------------------------------------------------
  Future<Null> img_kam2(name, index) async {
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
            '$name ผู้ค้ำ 2',
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
                  process_img_kam2(ImageSource.gallery, index);
                },
                child: Text(
                  "คลังภาพ",
                  style: MyConstant().h3Style(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  process_img_kam2(ImageSource.camera, index);
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

  Future<Null> process_img_kam2(ImageSource source, int index) async {
    try {
      var result = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
      );
      if (name_kam2_text.text == "") {
        normalDialog(context, "เตือน", "กรุณาเพิ่มชื่อ ผู้ค้ำ2");
      } else {
        setState(() {
          file_kam2 = File(result!.path);
          files_kam2[index] = file_kam2;

          int count_kam2 = 0;
          for (var item in files_kam2) {
            if (item == null) {
              count_kam2++;
            }
          }
          if (count_kam2 == 0) {
            check_kam2 = 1;
          } else if (count_kam2 == 4) {
            check_kam2 = 0;
          } else {
            check_kam2 = 2;
          }
        });
      }
    } catch (e) {}
  }

  //delete ภาพ
  Future<Null> delete_img_kam2(int index) async {
    setState(() {
      files_kam2[index] = null;
      int count_kam2 = 0;
      for (var item in files_kam2) {
        if (item == null) {
          count_kam2++;
        }
      }
      if (count_kam2 == 0) {
        check_kam2 = 1;
      } else if (count_kam2 == 4) {
        check_kam2 = 0;
        name_kam2_text.clear();
      } else {
        check_kam2 = 2;
      }
    });
  }

//------------------------------------------------------- บันทึก / จัดการภาพผู้ค้ำ 3 --------------------------------------------------------------------------
  Future<Null> img_kam3(name, index) async {
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
            '$name ผู้ค้ำ 3',
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
                  process_img_kam3(ImageSource.gallery, index);
                },
                child: Text(
                  "คลังภาพ",
                  style: MyConstant().h3Style(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  process_img_kam3(ImageSource.camera, index);
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

  Future<Null> process_img_kam3(ImageSource source, int index) async {
    try {
      var result = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
      );
      if (name_kam3_text.text == "") {
        normalDialog(context, "เตือน", "กรุณาเพิ่มชื่อ ผู้ค้ำ3");
      } else {
        setState(() {
          file_kam3 = File(result!.path);
          files_kam3[index] = file_kam3;

          int count_kam3 = 0;
          for (var item in files_kam3) {
            if (item == null) {
              count_kam3++;
            }
          }
          if (count_kam3 == 0) {
            check_kam3 = 1;
          } else if (count_kam3 == 4) {
            check_kam3 = 0;
          } else {
            check_kam3 = 2;
          }
        });
      }
    } catch (e) {}
  }

  //delete ภาพ
  Future<Null> delete_img_kam3(int index) async {
    setState(() {
      files_kam3[index] = null;
      int count_kam3 = 0;
      for (var item in files_kam3) {
        if (item == null) {
          count_kam3++;
        }
      }
      if (count_kam3 == 0) {
        check_kam3 = 1;
      } else if (count_kam3 == 4) {
        check_kam3 = 0;
        name_kam3_text.clear();
      } else {
        check_kam3 = 2;
      }
    });
  }

//------------------------------------------------------- บันทึก / จัดการภาพ อื่นๆ --------------------------------------------------------------------------

  Future<Null> img_other(name, index) async {
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
            '$name อื่นๆ',
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
                  process_img_other(ImageSource.gallery, index);
                },
                child: Text(
                  "คลังภาพ",
                  style: MyConstant().h3Style(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  process_img_other(ImageSource.camera, index);
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

  Future<Null> process_img_other(ImageSource source, int index) async {
    try {
      var result = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
      );
      setState(() {
        file_other = File(result!.path);
        files_other[index] = file_other;

        int count_other = 0;
        for (var item in files_other) {
          if (item == null) {
            count_other++;
          }
        }
        if (count_other == 0) {
          check_other = 1;
        } else if (count_other == 2) {
          check_other = 0;
        } else {
          check_other = 2;
        }
      });
    } catch (e) {}
  }

  //delete ภาพ
  Future<Null> delete_img_other(int index) async {
    setState(() {
      files_other[index] = null;
      int count_other = 0;
      for (var item in files_other) {
        if (item == null) {
          count_other++;
        }
      }
      if (count_other == 0) {
        check_other = 1;
      } else if (count_other == 2) {
        check_other = 0;
      } else {
        check_other = 2;
      }
    });
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
        files_more.add(null);
        file_more = File(result!.path);
        files_more[index_more] = file_more;
        index_more = index_more + 1;
      });
      print("-----------${files_more.length}");
    } catch (e) {}
  }

  //delete ภาพ
  Future<Null> delete_img_more(int index) async {
    setState(() {
      if (files_more.length == 1) {
        files_more.removeAt(index);
        index_more = 0;
        print("sssssssssssssssssssss");
      } else {
        files_more.removeAt(index);
        index_more = files_more.length;
        print("xxxxxxxxxxxxxxxxxxxxx");
      }
    });
  }

// -------------------------------------------------------------------------------------------------------------------------------------------------------

  //อัปโหลดไฟล์ ผู้ซื้อ / ผู้ค้ำ
  Future<Null> upload_file() async {
    try {
      for (var file_img_customer in files) {
        int i = Random().nextInt(10000000);
        String nameFile = 'checker$i.jpg';
        String api_upload_img_customer =
            'http://$ipconfig_checker/CheckerData2/api/ImgCustomer.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&lat=$lat&lng=$lng&name_cus=${name_customer_text.text}&name_admin=${widget.name_user}&level=${widget.level}&lastname_cus=${lastname_customer_text.text}&prefix_cus=$prefixname_customer_text&isCheckedCK=$checkDoc';
        Map<String, dynamic> map_customer = {};
        map_customer['file'] = await MultipartFile.fromFile(
            file_img_customer!.path,
            filename: nameFile);
        FormData data_customer = FormData.fromMap(map_customer);
        await Dio()
            .post(api_upload_img_customer, data: data_customer)
            .then((value) {
          print(value);
        });
      }
      //บันทึกผู้ค้ำ 1
      if (check_kam1 == 1) {
        int CountIndexG1 = 0;
        for (var file_img_kam1 in files_kam1) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_kam1$i.jpg';
          String api_upload_img_kam1 =
              'http://$ipconfig_checker/CheckerData2/api/ImgUploadG1.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&name_kam=${name_kam1_text.text}&lat=$lat&lng=$lng&lastname_kam=${lastname_kam1_text.text}&prefix_kam=$prefixname_kam1_text&CountIndexG1=$CountIndexG1&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_kam1 = {};
          map_kam1['file'] = await MultipartFile.fromFile(file_img_kam1!.path,
              filename: nameFile);
          CountIndexG1 = CountIndexG1 + 1;
          FormData data_kam1 = FormData.fromMap(map_kam1);
          await Dio().post(api_upload_img_kam1, data: data_kam1).then((value) {
            print(value);
          });
        }
        print(
            'zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&name_kam=${name_kam1_text.text}&lat=$lat&lng=$lng&lastname_kam=${lastname_kam1_text.text}&prefix_kam=$prefixname_kam1_text&CountIndexG1=$CountIndexG1&isCheckedCK=$checkDoc');
      }

      //บันทึกผู้ค้ำ 2
      if (check_kam2 == 1) {
        int CountIndexG2 = 0;
        for (var file_img_kam2 in files_kam2) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_kam2$i.jpg';
          String api_upload_img_kam2 =
              'http://$ipconfig_checker/CheckerData2/api/ImgUploadG2.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&name_kam=${name_kam2_text.text}&lat=$lat&lng=$lng&lastname_kam=${lastname_kam2_text.text}&prefix_kam=$prefixname_kam2_text&CountIndexG2=$CountIndexG2&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_kam2 = {};
          map_kam2['file'] = await MultipartFile.fromFile(file_img_kam2!.path,
              filename: nameFile);
          CountIndexG2 = CountIndexG2 + 1;
          FormData data_kam2 = FormData.fromMap(map_kam2);
          var response = await Dio()
              .post(api_upload_img_kam2, data: data_kam2)
              .then((value) {
            print(value);
          });
        }
      }

      //บันทึกผู้ค้ำ 3
      if (check_kam3 == 1) {
        int CountIndexG3 = 0;
        for (var file_img_kam3 in files_kam3) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_kam3$i.jpg';
          String api_upload_img_kam3 =
              'http://$ipconfig_checker/CheckerData2/api/ImgUploadG3.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&name_kam=${name_kam3_text.text}&lat=$lat&lng=$lng&lastname_kam=${lastname_kam3_text.text}&prefix_kam=$prefixname_kam3_text&CountIndexG3=$CountIndexG3&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_kam3 = {};
          map_kam3['file'] = await MultipartFile.fromFile(file_img_kam3!.path,
              filename: nameFile);
          CountIndexG3 = CountIndexG3 + 1;
          FormData data_kam3 = FormData.fromMap(map_kam3);
          await Dio().post(api_upload_img_kam3, data: data_kam3).then((value) {
            print(value);
          });
        }
      }

      //บันทึกอื่นๆ
      if (check_other == 1) {
        for (var file_img_other in files_other) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_other$i.jpg';
          String api_upload_img_other =
              'http://$ipconfig_checker/CheckerData2/api/ImgUploadOther.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&lat=$lat&lng=$lng&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_other = {};
          map_other['file'] = await MultipartFile.fromFile(file_img_other!.path,
              filename: nameFile);
          FormData data_other = FormData.fromMap(map_other);
          await Dio()
              .post(api_upload_img_other, data: data_other)
              .then((value) {
            print(value);
          });
        }
      }

      if (index_more > 0) {
        for (var file_img_more in files_more) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_more$i.jpg';
          String api_upload_img_more =
              'http://$ipconfig_checker/CheckerData2/api/ImgUploadMore.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_more = {};
          map_more['file'] = await MultipartFile.fromFile(file_img_more!.path,
              filename: nameFile);
          FormData data_more = FormData.fromMap(map_more);
          await Dio().post(api_upload_img_more, data: data_more).then((value) {
            print(value);
          });
        }
      }

      Navigator.pop(context);
      successSubmit(context, 'สำเร็จ', 'บันทึกข้อมูลสำเร็จ');
    } catch (e) {
      for (var file_img_customer in files) {
        int i = Random().nextInt(10000000);
        String nameFile = 'checker$i.jpg';
        String api_upload_img_customer =
            'http://$ipconfig_checker_office/CheckerData2/api/ImgCustomer.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&lat=$lat&lng=$lng&name_cus=${name_customer_text.text}&name_admin=${widget.name_user}&level=${widget.level}&lastname_cus=${lastname_customer_text.text}&prefix_cus=$prefixname_customer_text&isCheckedCK=$checkDoc';
        Map<String, dynamic> map_customer = {};
        map_customer['file'] = await MultipartFile.fromFile(
            file_img_customer!.path,
            filename: nameFile);
        FormData data_customer = FormData.fromMap(map_customer);
        await Dio()
            .post(api_upload_img_customer, data: data_customer)
            .then((value) {
          print(value);
        });
      }
      //บันทึกผู้ค้ำ 1
      if (check_kam1 == 1) {
        for (var file_img_kam1 in files_kam1) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_kam1$i.jpg';
          String api_upload_img_kam1 =
              'http://$ipconfig_checker_office/CheckerData2/api/ImgUploadG1.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&name_kam=${name_kam1_text.text}&lat=$lat&lng=$lng&lastname_kam=${lastname_kam1_text.text}&prefix_kam=$prefixname_kam1_text&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_kam1 = {};
          map_kam1['file'] = await MultipartFile.fromFile(file_img_kam1!.path,
              filename: nameFile);
          FormData data_kam1 = FormData.fromMap(map_kam1);
          await Dio().post(api_upload_img_kam1, data: data_kam1).then((value) {
            print(value);
          });
        }
      }

      //บันทึกผู้ค้ำ 2
      if (check_kam2 == 1) {
        for (var file_img_kam2 in files_kam2) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_kam2$i.jpg';
          String api_upload_img_kam2 =
              'http://$ipconfig_checker_office/CheckerData2/api/ImgUploadG2.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&name_kam=${name_kam2_text.text}&lat=$lat&lng=$lng&lastname_kam=${lastname_kam2_text.text}&prefix_kam=$prefixname_kam2_text&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_kam2 = {};
          map_kam2['file'] = await MultipartFile.fromFile(file_img_kam2!.path,
              filename: nameFile);
          FormData data_kam2 = FormData.fromMap(map_kam2);
          await Dio().post(api_upload_img_kam2, data: data_kam2).then((value) {
            print(value);
          });
        }
      }

      //บันทึกผู้ค้ำ 3
      if (check_kam3 == 1) {
        for (var file_img_kam3 in files_kam3) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_kam3$i.jpg';
          String api_upload_img_kam3 =
              'http://$ipconfig_checker_office/CheckerData2/api/ImgUploadG3.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&name_kam=${name_kam3_text.text}&lat=$lat&lng=$lng&lastname_kam=${lastname_kam3_text.text}&prefix_kam=$prefixname_kam3_text&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_kam3 = {};
          map_kam3['file'] = await MultipartFile.fromFile(file_img_kam3!.path,
              filename: nameFile);
          FormData data_kam3 = FormData.fromMap(map_kam3);
          await Dio().post(api_upload_img_kam3, data: data_kam3).then((value) {
            print(value);
          });
        }
      }

      //บันทึกอื่นๆ
      if (check_other == 1) {
        for (var file_img_other in files_other) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_other$i.jpg';
          String api_upload_img_other =
              'http://$ipconfig_checker_office/CheckerData2/api/ImgUploadOther.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&lat=$lat&lng=$lng&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_other = {};
          map_other['file'] = await MultipartFile.fromFile(file_img_other!.path,
              filename: nameFile);
          FormData data_other = FormData.fromMap(map_other);
          await Dio()
              .post(api_upload_img_other, data: data_other)
              .then((value) {
            print(value);
          });
        }
      }

      if (index_more > 0) {
        for (var file_img_more in files_more) {
          int i = Random().nextInt(10000000);
          String nameFile = 'checker_more$i.jpg';
          String api_upload_img_more =
              'http://$ipconfig_checker_office/CheckerData2/api/ImgUploadMore.php?zone=$val_zone&saka=$val_saka&type_running=$selectedValue&running_id=${id_running_text.text}&isCheckedCK=$checkDoc';
          Map<String, dynamic> map_more = {};
          map_more['file'] = await MultipartFile.fromFile(file_img_more!.path,
              filename: nameFile);
          FormData data_more = FormData.fromMap(map_more);
          await Dio().post(api_upload_img_more, data: data_more).then((value) {
            print(value);
          });
        }
      }
      Navigator.pop(context);
      successSubmit(context, 'สำเร็จ', 'บันทึกข้อมูลสำเร็จ');
    }
  }

  Future<Null> validate_image() async {
    int Files_customer = 0;
    for (var item in files) {
      if (item == null) {
        Files_customer++;
      }
    }
    // print("------------>$Files_customer");
    if (Files_customer == 0) {
      showProgressLoading(context);
      upload_file();
    } else {
      normalDialog(context, 'แจ้งเตือน', 'กรุณาเพิ่มรูปผู้ซื้อให้ครบถ้วน');
    }
  }

  //แจ้งเมื่อบันทึกสำเร็จ
  Future<Null> successSubmit(
      BuildContext context, String title, String message) async {
    showDialog(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
        ),
        child: SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          title: ListTile(
            leading: Image.asset('images/success.png'),
            title: Text(title, style: MyConstant().h2_5Style()),
            subtitle: Text(message, style: MyConstant().normalStyle()),
          ),
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    Text("ตกลง", style: MyConstant().h3Style()),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  //เช็ครันนิ่ง
  Future<Null> Checker_runing(type, runnig_id, isCheckedCK) async {
    // data_customer = [];
    try {
      var respose = await http.get(
          Uri.http('$ipconfig_checker', '/CheckerData2/api/CheckRunning.php', {
        "type_running": type,
        "running_id": runnig_id,
        "isCheckedCK": isCheckedCK,
      }));
      if (respose.statusCode == 200) {
        print(respose.body);
        if (respose.body == "success") {
          if (runnig_id.toString().length >= 6) {
            setState(() {
              check_runing = true;
            });
          } else {
            setState(() {
              check_runing = false;
            });
          }
        } else {
          setState(() {
            check_runing = false;
          });
        }
      } else {
        print("error no internet");
      }
    } catch (e) {
      // print("--------------");
      var respose = await http.get(Uri.http(
          '$ipconfig_checker_office', '/CheckerData2/api/CheckRunning.php', {
        "type_running": type,
        "running_id": runnig_id,
        "isCheckedCK": isCheckedCK,
      }));
      if (respose.statusCode == 200) {
        print(respose.body);
        if (respose.body == "success") {
          if (runnig_id.toString().length == 6) {
            setState(() {
              check_runing = true;
            });
          } else {
            setState(() {
              check_runing = false;
            });
          }
        } else {
          setState(() {
            check_runing = false;
          });
        }
      } else {
        print("error no internet");
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
    if (type == 4) {
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
    print('map> ${lat}_${lng}');
    Uri googleMapUrl = Uri.parse(
      'https://www.google.co.th/maps/search/?api=1&query=${lat},${lng}',
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
                        setState(() {
                          lat = argument.latitude;
                          lng = argument.longitude;
                          foucus_mark(lat!, lng!);
                        });
                        Navigator.pop(context);
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

  //ย้ายตำแหน่ง
  Future foucus_mark(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
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
            "เพิ่มข้อมูล",
            style: MyConstant().h2whiteStyle(),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        input_runing(size),
                        SizedBox(height: 10),
                        input_customer(size),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
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
                  SizedBox(height: 20),
                  name_admin(),
                  SizedBox(height: 10),
                  button_change(),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ));
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
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    color: Colors.blue[50],
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 10, right: 5),
                    child: Row(
                      children: [
                        Icon(
                          Icons.feed_outlined,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "เลขที่รันนิ่งสัญญา",
                          style: MyConstant().h2_5Style(),
                        )
                      ],
                    ),
                  ),
                  filtter_typerunnig(context),
                ],
              ),
            ),
            Row(
              children: [
                Checkbox(
                  side: WidgetStateBorderSide.resolveWith(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0), width: 1.7);
                      }
                      return const BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0), width: 1.7);
                    },
                  ),
                  value: isCheckedCK,
                  checkColor: const Color.fromARGB(255, 0, 0, 0),
                  activeColor: const Color.fromARGB(255, 255, 255, 255),
                  onChanged: (bool? value) {
                    setState(() {
                      isCheckedCK = value!;
                    });
                    if (isCheckedCK == true) {
                      checkDoc = 'true';
                    } else {
                      checkDoc = 'false';
                    }
                    Checker_runing(
                      selectedValue,
                      id_running_text.text,
                      checkDoc,
                    );
                  },
                ),
                Text(
                  'บันทึกเอกสารเดิม',
                  style: MyConstant().h3Style(),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: MyConstant().h3Style(),
                          onChanged: (String running) {
                            if (selectedValue == null) {
                              // Checker_runing("", running.toString());
                              normalDialog(
                                  context, "เตือน", "กรุณาเลือกประเภทเอกสาร");
                              id_running_text.clear();
                            } else {
                              print('c>>$checkDoc');
                              Checker_runing(
                                  selectedValue, running.toString(), checkDoc);
                            }
                          },
                          keyboardType: TextInputType.number,
                          controller: id_running_text,
                          maxLength: widget.level == "checker_runnig" ||
                                  widget.level == "chief" ||
                                  widget.level == "follow_up_debt"
                              ? 7
                              : 6,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาเพิ่ม เลขรันนิ่งสัญญา';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                            errorStyle: TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            prefixIcon: Icon(Icons.confirmation_number),
                            suffixIcon: check_runing == true
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: size * 0.06,
                                  )
                                : Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: size * 0.06,
                                  ),
                            labelText: "เลขรันนิ่งสัญญา",
                            labelStyle: MyConstant().normalStyle(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(360),
                              ),
                              borderSide: BorderSide(
                                color: MyConstant
                                    .dark, // สีของเส้น border เมื่อโฟกัส
                              ),
                            ),
                          ),
                        ),
                      ),
                      // check_runing == true
                      //     ? Icon(
                      //         Icons.check,
                      //         color: Colors.green,
                      //         size: size * 0.06,
                      //       )
                      //     : Icon(
                      //         Icons.close,
                      //         color: Colors.red,
                      //         size: size * 0.06,
                      //       ),
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
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(10),
                color: Color.fromARGB(255, 228, 228, 228).withAlpha(180),
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

  //ประเภทเอกสาร
  Row filtter_typerunnig(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // flex: 5,
          child: Column(
            children: [
              Container(
                child: DropdownButtonFormField<String>(
                  value: selectedValue,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: 12),
                    contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                      borderSide: BorderSide(
                        color: MyConstant.dark, // สีของเส้น border เมื่อโฟกัส
                      ),
                    ),
                  ),
                  hint: Text(
                    "ประเภทเอกสาร",
                    style: MyConstant().normalStyle(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                    if (id_running_text.text.toString().length == 6) {
                      Checker_runing(selectedValue,
                          id_running_text.text.toString(), checkDoc);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'กรุณาเพิ่ม ประเภทเอกสาร';
                    }
                    return null;
                  },
                  items: typerunnig.map((typelist) {
                    return DropdownMenuItem<String>(
                        value: typelist['type_running'],
                        child: Text(
                          typelist['type_running'],
                          style: MyConstant().h3Style(),
                        ));
                  }).toList(),
                ),
              )
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 20),
              //   decoration: ShapeDecoration(
              //     shape: RoundedRectangleBorder(
              //       side: BorderSide(
              //         // width: 1.0,
              //         // style: BorderStyle.solid,
              //         color: Color.fromARGB(255, 121, 121, 121),
              //       ),
              //       borderRadius: BorderRadius.all(
              //         Radius.circular(30.0),
              //       ),
              //     ),
              //   ),
              //   child: DropdownButton(
              //     isExpanded: true,
              //     hint: Text(
              //       "ประเภทเอกสาร",
              //       style: MyConstant().normalStyle(),
              //     ),
              //     value: selectedValue,
              //     items: typerunnig.map((typelist) {
              //       return DropdownMenuItem(
              //           value: typelist['type_running'],
              //           child: Text(
              //             typelist['type_running'],
              //             style: MyConstant().h3Style(),
              //           ));
              //     }).toList(),
              //     onChanged: (value) {
              //       setState(() {
              //         selectedValue = value as String?;
              //       });
              //       if (id_running_text.text.toString().length == 6) {
              //         Checker_runing(selectedValue,
              //             id_running_text.text.toString(), checkDoc);
              //       }
              //     },
              //     underline: Container(
              //       height: 2,
              //       color: Colors.transparent,
              //     ),
              //   ),
              // ),
            ],
          ),
        )
      ],
    );
  }

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
                                ),
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
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: DropdownButtonFormField<String>(
                          value: prefixname_customer_text,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(fontSize: 12),
                            contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              borderSide: BorderSide(
                                color: MyConstant
                                    .dark, // สีของเส้น border เมื่อโฟกัส
                              ),
                            ),
                          ),
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
                            return null;
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
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                            borderSide: BorderSide(
                              color: MyConstant
                                  .dark, // สีของเส้น border เมื่อโฟกัส
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                            borderSide: BorderSide(
                              color: MyConstant
                                  .dark, // สีของเส้น border เมื่อโฟกัส
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          img_customer("รูปบัตรประชาชน", 0);
                        },
                        onLongPress: () {
                          zoom_img(files, 0);
                        },
                        child: files[0] == null
                            ? Icon(
                                Icons.add_photo_alternate_sharp,
                                color: Colors.grey[400],
                                size: size * 0.18,
                              )
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          img_customer("แผนที่บ้าน", 1);
                        },
                        onLongPress: () {
                          zoom_img(files, 1);
                        },
                        child: files[1] == null
                            ? Icon(
                                Icons.add_photo_alternate_sharp,
                                color: Colors.grey[400],
                                size: size * 0.18,
                              )
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          img_customer("รูปบ้าน", 2);
                        },
                        onLongPress: () {
                          zoom_img(files, 2);
                        },
                        child: files[2] == null
                            ? Icon(
                                Icons.add_photo_alternate_sharp,
                                color: Colors.grey[400],
                                size: size * 0.18,
                              )
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
                      if (widget.level == "checker_runnig") ...[
                        Text(
                          "สช.ผู้ซื้อ",
                          style: MyConstant().h3Style(),
                        ),
                      ] else ...[
                        Text(
                          "รูปตอนเซ็น",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          img_customer("รูปตอนเซ็น", 3);
                        },
                        onLongPress: () {
                          zoom_img(files, 3);
                        },
                        child: files[3] == null
                            ? Icon(
                                Icons.add_photo_alternate_sharp,
                                color: Colors.grey[400],
                                size: size * 0.18,
                              )
                            : show_imgCustomer(size, 3),
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
                            img_customer("หน้าสัญญา", 4);
                          },
                          onLongPress: () {
                            zoom_img(files, 4);
                          },
                          child: files[4] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
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
                            img_customer("ใบขอเช่าซื้อ", 5);
                          },
                          onLongPress: () {
                            zoom_img(files, 5);
                          },
                          child: files[5] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
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
                            img_customer("รูปรับรถ", 6);
                          },
                          onLongPress: () {
                            zoom_img(files, 6);
                          },
                          child: files[6] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgCustomer(size, 6),
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
            Container(
              color: Colors.blue[50],
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      switch_form(1);
                    },
                    child: Container(
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
                  ),
                ],
              ),
            ),
            if (show_kam1 == true) ...[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
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
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color: MyConstant
                                      .dark, // สีของเส้น border เมื่อโฟกัส
                                ),
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
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: name_kam1_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(30, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "ชื่อ ผู้้ค้ำ 1",
                              labelStyle: MyConstant().normalStyle(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color: MyConstant
                                      .dark, // สีของเส้น border เมื่อโฟกัส
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: lastname_kam1_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(30, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "นามสกุล ผู้้ค้ำ 1",
                              labelStyle: MyConstant().normalStyle(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color: MyConstant
                                      .dark, // สีของเส้น border เมื่อโฟกัส
                                ),
                              ),
                            ),
                          ),
                        )
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_kam1("รูปบัตรประชาชน", 0);
                          },
                          onLongPress: () {
                            zoom_img(files_kam1, 0);
                          },
                          child: files_kam1[0] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam1(size, 0),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_kam1("แผนที่บ้าน", 1);
                          },
                          onLongPress: () {
                            zoom_img(files_kam1, 1);
                          },
                          child: files_kam1[1] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam1(size, 1),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_kam1("รูปบ้าน", 2);
                          },
                          onLongPress: () {
                            zoom_img(files_kam1, 2);
                          },
                          child: files_kam1[2] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam1(size, 2),
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
                        if (widget.level == "checker_runnig") ...[
                          Text(
                            "สช.ผู้ค้ำ 1",
                            style: MyConstant().h3Style(),
                          ),
                        ] else ...[
                          Text(
                            "รูปตอนเซ็น (ผู้ค้ำ 1)",
                            style: MyConstant().h3Style(),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (widget.level == "checker_runnig") {
                              img_kam1("สช.", 3);
                            } else {
                              img_kam1("รูปตอนเซ็น", 3);
                            }
                          },
                          onLongPress: () {
                            zoom_img(files_kam1, 3);
                          },
                          child: files_kam1[3] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam1(size, 3),
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
                margin: EdgeInsets.only(bottom: 10.0),
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
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color: MyConstant
                                      .dark, // สีของเส้น border เมื่อโฟกัส
                                ),
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
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: name_kam2_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(30, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "ชื่อ ผู้้ค้ำ 2",
                              labelStyle: MyConstant().normalStyle(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color: MyConstant
                                      .dark, // สีของเส้น border เมื่อโฟกัส
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: lastname_kam2_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(30, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "นามสกุล ผู้้ค้ำ 2",
                              labelStyle: MyConstant().normalStyle(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color: MyConstant
                                      .dark, // สีของเส้น border เมื่อโฟกัส
                                ),
                              ),
                            ),
                          ),
                        )
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_kam2("รูปบัตรประชาชน", 0);
                          },
                          onLongPress: () {
                            zoom_img(files_kam2, 0);
                          },
                          child: files_kam2[0] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam2(size, 0),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_kam2("แผนที่บ้าน", 1);
                          },
                          onLongPress: () {
                            zoom_img(files_kam2, 1);
                          },
                          child: files_kam2[1] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam2(size, 1),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_kam2("รูปบ้าน", 2);
                          },
                          onLongPress: () {
                            zoom_img(files_kam2, 2);
                          },
                          child: files_kam2[2] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam2(size, 2),
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
                        if (widget.level == "checker_runnig") ...[
                          Text(
                            "สช.ผู้ค้ำ 2",
                            style: MyConstant().h3Style(),
                          ),
                        ] else ...[
                          Text(
                            "รูปตอนเซ็น (ผู้ค้ำ 2)",
                            style: MyConstant().h3Style(),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (widget.level == "checker_runnig") {
                              img_kam2("สช.", 3);
                            } else {
                              img_kam2("รูปตอนเซ็น", 3);
                            }
                          },
                          onLongPress: () {
                            zoom_img(files_kam2, 3);
                          },
                          child: files_kam2[3] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam2(size, 3),
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
                margin: EdgeInsets.only(bottom: 10.0),
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
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color: MyConstant
                                      .dark, // สีของเส้น border เมื่อโฟกัส
                                ),
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
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: name_kam3_text,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(30, 5, 10, 5),
                                errorStyle: TextStyle(fontSize: 12),
                                prefixIcon: Icon(Icons.location_history),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                labelText: "ชื่อ ผู้้ค้ำ 3",
                                labelStyle: MyConstant().normalStyle(),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                  borderSide: BorderSide(
                                    color: MyConstant
                                        .dark, // สีของเส้น border เมื่อโฟกัส
                                  ),
                                )),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: MyConstant().h3Style(),
                            controller: lastname_kam3_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(30, 5, 10, 5),
                              errorStyle: TextStyle(fontSize: 12),
                              prefixIcon: Icon(Icons.location_history),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: "นามสกุล ผู้้ค้ำ 3",
                              labelStyle: MyConstant().normalStyle(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color: MyConstant
                                      .dark, // สีของเส้น border เมื่อโฟกัส
                                ),
                              ),
                            ),
                          ),
                        )
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_kam3("รูปบัตรประชาชน", 0);
                          },
                          onLongPress: () {
                            zoom_img(files_kam3, 0);
                          },
                          child: files_kam3[0] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam3(size, 0),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_kam3("แผนที่บ้าน", 1);
                          },
                          onLongPress: () {
                            zoom_img(files_kam3, 1);
                          },
                          child: files_kam3[1] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam3(size, 1),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            img_kam3("รูปบ้าน", 2);
                          },
                          onLongPress: () {
                            zoom_img(files_kam3, 2);
                          },
                          child: files_kam3[2] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam3(size, 2),
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
                        if (widget.level == "checker_runnig") ...[
                          Text(
                            "สช.ผู้ค้ำ 3",
                            style: MyConstant().h3Style(),
                          ),
                        ] else ...[
                          Text(
                            "รูปตอนเซ็น (ผู้ค้ำ 3)",
                            style: MyConstant().h3Style(),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (widget.level == "checker_runnig") {
                              img_kam3("สช.", 3);
                            } else {
                              img_kam3("รูปตอนเซ็น", 3);
                            }
                          },
                          onLongPress: () {
                            zoom_img(files_kam3, 3);
                          },
                          child: files_kam3[3] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgkam3(size, 3),
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

  //อื่นๆ
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
                            img_other("ใบรายงาน", 0);
                          },
                          onLongPress: () {
                            zoom_img(files_other, 0);
                          },
                          child: files_other[0] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgother(size, 0),
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
                            img_other("สัญญาหน้าหลังสุด(ลายเซ็นคนค้ำ)", 1);
                          },
                          onLongPress: () {
                            zoom_img(files_other, 1);
                          },
                          child: files_other[1] == null
                              ? Icon(
                                  Icons.add_photo_alternate_sharp,
                                  color: Colors.grey[400],
                                  size: size * 0.18,
                                )
                              : show_imgother(size, 1),
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
                    if (files_more.length > 0) ...[
                      SizedBox(width: 10),
                      Row(
                        children: [
                          Text(
                            '*ภาพเพิ่มเติมมี ${files_more.length} ภาพ',
                            style: MyConstant().h3Style(),
                          ),
                        ],
                      ),
                    ],
                    Column(
                      children: [
                        if (index_more > 0) ...[
                          show_imgmore(size),
                        ],
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
  //ปุ่มบันทึก
  Container button_change() {
    return Container(
      margin: EdgeInsets.only(left: 40, right: 40, bottom: 15),
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        gradient: LinearGradient(
          colors: [MyConstant.dark_e, MyConstant.dark_f],
        ),
      ),
      child: MaterialButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const StadiumBorder(),
        child: Text(
          'บันทึก',
          style: MyConstant().normalwhiteStyle(),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (selectedValue == null) {
              normalDialog(context, "เตือน", "กรุณาเลือกประเภทเอกสาร");
            } else {
              if (check_kam1 == 2) {
                normalDialog(context, "เตือน", "ภาพผู้ค้ำ 1 ไม่ครบถ้วน");
              }
              if (check_kam2 == 2) {
                normalDialog(context, "เตือน", "ภาพผู้ค้ำ 2 ไม่ครบถ้วน");
              }
              if (check_kam3 == 2) {
                normalDialog(context, "เตือน", "ภาพผู้ค้ำ 3 ไม่ครบถ้วน");
              }
              if (check_other == 2) {
                normalDialog(context, "เตือน", "ภาพอื่นๆ ไม่ครบถ้วน");
              }
              if (val_saka == "" || val_saka == null) {
                normalDialog(context, "เตือน", "กรุณาเลือกสาขา");
              }

              if (check_kam1 != 2 &&
                  check_kam2 != 2 &&
                  check_kam3 != 2 &&
                  check_other != 2 &&
                  val_saka != "" &&
                  val_saka != null) {
                if (check_kam3 == 1 && check_kam2 == 0) {
                  normalDialog(
                      context, "เตือน", "กรุณาระบุคนค้ำตามลำดับให้ถูกต้อง");
                } else if (check_kam2 == 1 && check_kam1 == 0) {
                  normalDialog(
                      context, "เตือน", "กรุณาระบุคนค้ำตามลำดับให้ถูกต้อง");
                } else if (check_runing == false) {
                  normalDialog(context, "เตือน", "เลขรันนิ่งสัญญาไม่ครบถ้วน");
                } else {
                  validate_image();
                }
              }
            }
          } else {
            normalDialog(context, "เตือน", "กรุณากรอกข้อมูลหลังให้ถูกต้อง");
          }
        },
      ),
    );
  }

  //ชื่อเจ้าหน้าที่
  Widget name_admin() => Text(
        "ผู้บันทึก [ ${widget.name_user} ] ",
        style: MyConstant().h3Style(),
      );

  Stack show_imgCustomer(size, index) {
    return Stack(
      children: <Widget>[
        InkWell(
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: new BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                files[index]!,
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: () {
              delete_img_customer(index);
            },
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Color.fromARGB(97, 112, 112, 112),
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
        )
      ],
    );
  }

  Stack show_imgkam1(size, index) {
    return Stack(
      children: <Widget>[
        InkWell(
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: new BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                files_kam1[index]!,
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: () {
              delete_img_kam1(index);
            },
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Color.fromARGB(97, 112, 112, 112),
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
        )
      ],
    );
  }

  Stack show_imgkam2(size, index) {
    return Stack(
      children: <Widget>[
        InkWell(
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: new BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                files_kam2[index]!,
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: () {
              delete_img_kam2(index);
            },
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Color.fromARGB(97, 112, 112, 112),
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
        )
      ],
    );
  }

  Stack show_imgkam3(size, index) {
    return Stack(
      children: <Widget>[
        InkWell(
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: new BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                files_kam3[index]!,
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: () {
              delete_img_kam3(index);
            },
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Color.fromARGB(97, 112, 112, 112),
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
        )
      ],
    );
  }

  Stack show_imgother(size, index) {
    return Stack(
      children: <Widget>[
        InkWell(
          child: Container(
            decoration: new BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                files_other[index]!,
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: () {
              delete_img_other(index);
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
        )
      ],
    );
  }

  Container show_imgmore(size) {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < files_more.length; i++) ...[
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 10),
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: new BoxDecoration(color: Colors.white),
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            files_more[i]!,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: () {
                          delete_img_more(i);
                        },
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                            color: Color.fromARGB(97, 112, 112, 112),
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
        ),
      ),
    );
  }
}
