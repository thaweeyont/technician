import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/job_log_addressmodel.dart';
import 'package:technician/models/product_job.dart';
import 'package:technician/models/show_user_data_job.dart';
import 'package:technician/models/user_documentmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_progress.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class consider_job extends StatefulWidget {
  final idjob, idjobgen, idstaff;
  consider_job(this.idjob, this.idjobgen, this.idstaff);
  @override
  _consider_jobState createState() => _consider_jobState();
}

class _consider_jobState extends State<consider_job>
    with WidgetsBindingObserver {
  bool id_card_Checked = false;
  bool id_card_guarantor_Checked = false;
  bool home_Checked = false;
  bool home_guarantor_Checked = false;
  bool income_document = false;
  Completer<GoogleMapController> _controller = Completer();
  var show,
      progress,
      val_id_card_Checked,
      val_id_card_guarantor_Checked,
      val_home_Checked,
      val_home_guarantor_Checked,
      val_income_document;
  List<UserDataJob> user_data_job = [];
  List<UserDocument> user_document = [];
  List<ProductJob> productjob = [];
  List<JobLogAddress> address_history = [];
  Key key = UniqueKey();

// ตัวจัดการ
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        // ออกแอป
        break;
      case AppLifecycleState.resumed:
        //กลับมาเปิดแอป
        restartApp();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  //เรียกใช้ api แสดง การขอเอกสารเพิ่ม
  Future<Null> _get_user_document() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_user_document.php',
          {"id_gen_job": widget.idjobgen}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล");
        setState(() {
          user_document = userDocumentFromJson(respose.body);
          val_id_card_Checked = user_document[0].idCardChecked;
          val_id_card_guarantor_Checked =
              user_document[0].idCardGuarantorChecked;
          val_home_Checked = user_document[0].homeChecked;
          val_home_guarantor_Checked = user_document[0].idCardGuarantorChecked;
          val_income_document = user_document[0].incomeDocument;
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  //เรียกใช้ api แสดง งาน
  Future<Null> _get_user_job(String idjob) async {
    try {
      var respose = await http.get(Uri.http(ipconfig,
          '/flutter_api/api_staff/show_user_data_job.php', {"idjob": idjob}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล");
        setState(() {
          user_data_job = userDataJobFromJson(respose.body);
          show = 1;
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  //เรียกใช้ api แสดง สินค้า
  Future<Null> _getProduct(String idjobgen) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_product_job.php',
          {"gen_id_job": idjobgen}));
      print(respose.body);
      if (respose.statusCode == 200) {
        // print("show");
        setState(() {
          productjob = productJobFromJson(respose.body);
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูลสินค้า");
    }
  }

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
              child: user_data_job[0].latJob == null
                  ? ShowProgress()
                  : GoogleMap(
                      myLocationEnabled: true,
                      // mapType: MapType.hybrid,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            double.parse('${user_data_job[0].latJob}'),
                            double.parse('${user_data_job[0].lngJob}')),
                        zoom: 16,
                      ),
                      onMapCreated: (controller) {},
                      markers: <Marker>[
                        Marker(
                          markerId: MarkerId('id'),
                          position: LatLng(
                              double.parse('${user_data_job[0].latJob}'),
                              double.parse('${user_data_job[0].lngJob}')),
                          infoWindow: InfoWindow(
                              title: 'สถานที่ติดตั้ง',
                              snippet:
                                  'Lat = ${user_data_job[0].latJob} , lng = ${user_data_job[0].latJob}'),
                        ),
                      ].toSet(),
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

  //ผ่านสัญญา dialog
  Future<Null> contract_passed(String name, String token, String status) async {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    showAnimatedDialog(
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
            leading: Image.asset('images/success.gif'),
            title: Text(
              '$name',
              style: MyConstant().h2_5Style(),
            ),
            subtitle: Text(
              'ท่านต้องการยอมรับว่าสัญญาผ่านใช่หรือไม่ ?',
              style: MyConstant().normalStyle(),
            ),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    showProgressDialog(context);
                    contract_process_api("1", token, name, status);
                  },
                  child: Column(
                    children: [
                      Text(
                        "สัญญาผ่าน",
                        style: MyConstant().h3Style(),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Text(
                        "ยกเลิก",
                        style: MyConstant().normalredStyle(),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      animationType: DialogTransitionType.slideFromBottomFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  //ไม่ผ่านสัญญา dialog
  Future<Null> contract_not_passed(
      String name, String token, String status) async {
    showAnimatedDialog(
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
            leading: Image.asset('images/no_success.gif'),
            title: Text(
              '$name',
              style: MyConstant().h2_5Style(),
            ),
            subtitle: Text(
              'ท่านต้องการยอมรับว่าสัญญาไม่ผ่านใช่หรือไม่ ?',
              style: MyConstant().normalStyle(),
            ),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    showProgressDialog(context);
                    contract_process_api("2", token, name, status);
                  },
                  child: Column(
                    children: [
                      Text(
                        "สัญญาไม่ผ่าน",
                        style: MyConstant().normalredStyle(),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Text(
                        "ยกเลิก",
                        style: MyConstant().h3Style(),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      animationType: DialogTransitionType.slideFromBottomFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  // dialog ขอสัญญาเพิ่มเติม
  Future<Null> add_document() async {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    if (val_id_card_Checked == "true") {
      id_card_Checked = true;
    }
    if (val_id_card_guarantor_Checked == "true") {
      id_card_guarantor_Checked = true;
    }
    if (val_home_Checked == "true") {
      home_Checked = true;
    }
    if (val_home_guarantor_Checked == "true") {
      home_guarantor_Checked = true;
    }
    if (val_income_document == "true") {
      income_document = true;
    }
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            children: [
              Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ขอเอกสารเพิ่มเติม",
                          style: MyConstant().h2_5Style(),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(Colors.blue),
                          value: id_card_Checked,
                          onChanged: (bool? value) {
                            setState(() {
                              id_card_Checked = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "สำเนาบัตรประชาชนผู้ซื้อ",
                            style: MyConstant().normalStyle(),
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(Colors.blue),
                          value: home_Checked,
                          onChanged: (bool? value) {
                            setState(() {
                              home_Checked = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "สำเนาทะเบียนบ้านผู้ซื้อ",
                            style: MyConstant().normalStyle(),
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(Colors.blue),
                          value: id_card_guarantor_Checked,
                          onChanged: (bool? value) {
                            setState(() {
                              id_card_guarantor_Checked = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "สำเนาบัตรประชาชนผู้ค้ำประกัน",
                            style: MyConstant().normalStyle(),
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(Colors.blue),
                          value: home_guarantor_Checked,
                          onChanged: (bool? value) {
                            setState(() {
                              home_guarantor_Checked = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "สำเนาทะเบียนบ้านผู้ค้ำประกัน",
                            style: MyConstant().normalStyle(),
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(Colors.blue),
                          value: income_document,
                          onChanged: (bool? value) {
                            setState(() {
                              income_document = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "เอกสารแสดงรายได้ผู้เช่าซื้อ (ถ้ามี)",
                            style: MyConstant().normalStyle(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, bottom: 25),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "**การขอเอกสารเพิ่มจะแจ้งเตื่อนไปยังลูกค้า",
                              style: MyConstant().normalredStyle(),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async {
                      showProgressDialog(context);
                      add_document_api();
                      // Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Text(
                          "ขอเอกสาร",
                          style: MyConstant().h3Style(),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Text(
                          "ยกเลิก",
                          style: MyConstant().normalredStyle(),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      animationType: DialogTransitionType.slideFromBottomFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  // เรียกใช้ api contract_passed
  Future<Null> contract_process_api(
      String function, String token, String name, String status) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/contract_process_api.php',
          {"id_job": widget.idjob, "function": function}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        if (function == "1") {
          Notification_api(token, name, status, "1");
        } else {
          Notification_api(token, name, status, "2");
        }
      }
    } catch (e) {
      print("จัดการสัญญาไม่สำเร็จ");
    }
  }

  //เรียกใช้ api Notification ให้ลูกค้าเมื่อกดอณุมัติหรือไม่อนุมัติ
  Future<Null> Notification_api(
      String token, String name, String body, String status) async {
    if (status == "1") {
      progress = "ผ่านการอนุมัติ";
      try {
        var respose = await http.get(
            Uri.http(ipconfig, '/flutter_api/api_staff/apiNotification.php', {
          "isAdd": "true",
          "token": token,
          "title": "สถานะสัญญาเงิน$body",
          "body": "คุณ $name $progress และรอดำเนินการถัดไป"
        }));
        if (respose.statusCode == 200) {
          print("notificationสำเร็จ");
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (e) {
        print("notificationไม่สำเร็จ");
      }
    } else {
      progress = "สัญญาไม่เข้าเงื่อนไขตาที่บริษัทกำหนด";

      try {
        var respose = await http.get(
            Uri.http(ipconfig, '/flutter_api/api_staff/apiNotification.php', {
          "isAdd": "true",
          "token": token,
          "title": "สถานะสัญญาเงิน$body",
          "body": "คุณ $name $progress"
        }));
        if (respose.statusCode == 200) {
          print("notificationสำเร็จ");
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (e) {
        print("notificationไม่สำเร็จ");
      }
    }
  }

  //เรียกใช้ api Notification ให้ลูกค้า
  Future<Null> Notification_api_add_doc(String token) async {
    try {
      var respose = await http.get(
          Uri.http(ipconfig, '/flutter_api/api_staff/apiNotification.php', {
        "isAdd": "true",
        "token": token,
        "title": "เอกสารสัญญา",
        "body": "ขอเอกสารเพิ่มเติมเพื่อพิจารณาสัญญา"
      }));
      if (respose.statusCode == 200) {
        print("notificationสำเร็จ");
        Navigator.pop(context);
        Navigator.pop(context);
        // successDialog(
        //     context, 'แจ้งเตือน', 'ทำการแจ้งข้อมูลให้ลูกค้าเสร็จสิ้น');
      }
    } catch (e) {
      print("notificationไม่สำเร็จ");
    }
  }

  //เรียกใช้ api ขอสัญญาเพิ่ม
  Future<Null> add_document_api() async {
    try {
      var respose = await http
          .get(Uri.http(ipconfig, '/flutter_api/api_staff/add_document.php', {
        "id_gen_job": widget.idjobgen,
        "id_card_Checked": id_card_Checked.toString(),
        "home_Checked": home_Checked.toString(),
        "id_card_guarantor_Checked": id_card_guarantor_Checked.toString(),
        "home_guarantor_Checked": home_guarantor_Checked.toString(),
        "income_document": income_document.toString(),
      }));
      print(respose.body);
      if (respose.statusCode == 200) {
        print("ขอเอกสารเพิ่มเติมสำเร็จ");
        var token = user_data_job[0].token;
        Notification_api_add_doc(token!);
        _get_user_document();
      }
    } catch (e) {
      print(e);
      print("ขอเอกสารเพิ่มเติมไม่สำเร็จ");
    }
  }

  //เรียกใช้ api แสดง สถานที่ติดตั้ง
  Future<Null> _getAddress(String gen_id_job) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_job_log_address.php',
          {"gen_id_job": gen_id_job}));
      print(respose.body);
      if (respose.statusCode == 200) {
        // print("show");
        setState(() {
          address_history = jobLogAddressFromJson(respose.body);
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูลสินค้า");
    }
  }

  //รีสตาร์ทแอป
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _get_user_job(widget.idjob);
    _getProduct(widget.idjobgen);
    _getAddress(widget.idjobgen);
    _get_user_document();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return Scaffold(
      key: key,
      backgroundColor: Colors.white,
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
        backgroundColor: Color.fromRGBO(27, 55, 120, 1.0),
        elevation: 0,
        title: Text(
          "พิจารณาสัญญา",
          style: MyConstant().h2whiteStyle(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Color.fromRGBO(62, 105, 201, 1),
                Color.fromRGBO(27, 55, 120, 1.0),
              ],
            ),
          ),
        ),
      ),
      body: user_data_job.isEmpty
          ? WillPopScope(
              child: Center(child: CircularProgressIndicator()),
              onWillPop: () async {
                return false;
              },
            )
          : Scrollbar(
              radius: Radius.circular(30),
              thickness: 6,
              child: RefreshIndicator(
                onRefresh: () async {
                  _get_user_job(widget.idjob);
                  _getProduct(widget.idjobgen);
                  _get_user_document();
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Container(
                    child: Column(
                      children: [
                        for (var i = 0; i < user_data_job.length; i++) ...[
                          Container(
                            child: Container(
                              child: Column(
                                children: [
                                  title_data_user(),
                                  data_user(size, sizeh),
                                  SizedBox(
                                    width: double.infinity,
                                    height: sizeh * 0.02,
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: Color(0xFFEEEEEE)),
                                    ),
                                  ),
                                  data_product(size, sizeh),
                                  SizedBox(
                                    width: double.infinity,
                                    height: sizeh * 0.02,
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: Color(0xFFEEEEEE)),
                                    ),
                                  ),
                                  title_map(size),
                                  address_install(),
                                  // detail_map(size, sizeh),
                                  SizedBox(
                                    width: double.infinity,
                                    height: sizeh * 0.02,
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: Color(0xFFEEEEEE)),
                                    ),
                                  ),
                                  get_doc(size, sizeh),
                                  button_submit(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget title_data_user() => Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 15, right: 15, top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "ข้อมูลลูกค้า",
              style: MyConstant().h2_5Style(),
            ),
          ],
        ),
      );

  Widget data_user(size, sizeh) => Container(
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Color.fromRGBO(27, 55, 120, 1.0),
                                size: size * 0.06,
                              ),
                              SizedBox(width: size * 0.03),
                              Text(
                                "ชื่อผู้รับสินค้า",
                                style: MyConstant().normalStyle(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Row(
                      children: [
                        Text(
                          "${user_data_job[0].fullname}",
                          style: MyConstant().h3Style(),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pin_drop,
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        size: size * 0.06,
                      ),
                      SizedBox(width: size * 0.03),
                      Text(
                        "ที่อยู่",
                        style: MyConstant().normalStyle(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${user_data_job[0].addressUser} จ.${user_data_job[0].nameProvinces} อ.${user_data_job[0].nameAmphures} ต.${user_data_job[0].nameDistricts} ${user_data_job[0].zipCode}",
                            style: MyConstant().h3Style(),
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.call,
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        size: size * 0.06,
                      ),
                      SizedBox(width: size * 0.03),
                      Text(
                        "เบอร์โทรผู้รับสินค้า",
                        style: MyConstant().normalStyle(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${user_data_job[0].phoneUser}",
                            style: MyConstant().h3Style(),
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );

  Widget data_product(size, sizeh) => Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_rounded,
                            color: Color.fromRGBO(27, 55, 120, 1.0),
                            size: size * 0.06,
                          ),
                          Text(
                            "  ข้อมูลสินค้า",
                            style: MyConstant().h2_5Style(),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            for (int i = 0; i < productjob.length; i++) ...[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "ประเภทสินค้า  ",
                            style: MyConstant().normalStyle(),
                          ),
                          Text(
                            "${productjob[i].productType}",
                            style: MyConstant().h3Style(),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "แบรนด์สินค้า  ",
                            style: MyConstant().normalStyle(),
                          ),
                          Text(
                            "${productjob[i].productBrand}",
                            style: MyConstant().h3Style(),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "ข้อมูลสินค้า",
                                style: MyConstant().normalStyle(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${productjob[i].productDetail}",
                                  style: MyConstant().h3Style(),
                                  overflow: TextOverflow.fade,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 35.0, right: 35.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "ประเภทสัญญา  ",
                                    style: MyConstant().normalStyle(),
                                  ),
                                  Text(
                                    "เงิน${productjob[i].productTypeContract}",
                                    style: MyConstant().h3Style(),
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "x ${productjob[i].productCount}",
                                style: MyConstant().h3Style(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 10.0),
                        child: new Divider()),
                  ],
                ),
              ),
              SizedBox(
                height: sizeh * 0.01,
              )
            ],
          ],
        ),
      );

  Widget title_map(size) => Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "สถานที่ติดตั้ง ",
              style: MyConstant().h2_5Style(),
            ),
            InkWell(
              onTap: () {
                // showmap();
              },
              child: Icon(
                Icons.map_outlined,
                color: Color.fromRGBO(27, 55, 120, 1.0),
                size: size * 0.06,
              ),
            )
          ],
        ),
      );

  Widget detail_map(size, sizeh) => Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 15),
        height: sizeh * 0.40,
        // color: Colors.amber,
        width: double.infinity,
        child: user_data_job[0].latJob == null
            ? ShowProgress()
            : GoogleMap(
                // myLocationEnabled: true,
                // mapType: MapType.hybrid,
                initialCameraPosition: CameraPosition(
                  target: LatLng(double.parse('${user_data_job[0].latJob}'),
                      double.parse('${user_data_job[0].lngJob}')),
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                },
                gestureRecognizers: Set()
                  ..add(Factory<EagerGestureRecognizer>(
                      () => EagerGestureRecognizer())),
                markers: <Marker>[
                  Marker(
                    markerId: MarkerId('id'),
                    position: LatLng(double.parse('${user_data_job[0].latJob}'),
                        double.parse('${user_data_job[0].lngJob}')),
                    infoWindow: InfoWindow(
                        title: 'สถานที่ติดตั้ง',
                        snippet:
                            'Lat = ${user_data_job[0].latJob} , lng = ${user_data_job[0].latJob}'),
                  ),
                ].toSet(),
              ),
      );

  Widget get_doc(size, sizeh) => Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ขอเอกสารเพิ่มเติมจากลูกค้า",
                  style: MyConstant().h2_5Style(),
                ),
                InkWell(
                  onTap: () {
                    launch("tel://${user_data_job[0].phoneUser}");
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2,
                          offset: Offset(0, 0), // Shadow position
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.call,
                      size: size * 0.05,
                      color: Colors.green,
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30.0, right: 30.0, bottom: 15.0, top: 15.0),
              child: InkWell(
                onTap: () {
                  id_card_Checked = false;
                  id_card_guarantor_Checked = false;
                  home_Checked = false;
                  home_guarantor_Checked = false;
                  income_document = false;
                  add_document();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: Color.fromRGBO(27, 55, 120, 1.0),
                      size: 20,
                    ),
                    Text(
                      "ขอเอกสารเพิ่มเติมจากลูกค้า",
                      style: MyConstant().h3Style(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget button_submit() => Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  // print("ผ่านสัญญา");
                  contract_passed(
                      "${user_data_job[0].fullname}",
                      "${user_data_job[0].token}",
                      "${user_data_job[0].productTypeContract}");
                },
                child: Column(
                  children: [
                    Text(
                      "สัญญาผ่าน",
                      style: MyConstant().h3Style(),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // print("สัญญาไม่ผ่าน");
                  contract_not_passed(
                      "${user_data_job[0].fullname}",
                      "${user_data_job[0].token}",
                      "${user_data_job[0].productTypeContract}");
                  // Navigator.pop(context);
                },
                child: Column(
                  children: [
                    Text(
                      "สัญญาไม่ผ่าน",
                      style: MyConstant().normalredStyle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget address_install() => Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Row(
          children: [
            for (var item in address_history) ...[
              Expanded(
                child: Text(
                  "ที่อยู่จัดส่ง : ${item.addressDeliver} จ.${item.nameProvinces} อ.${item.nameAmphures} ต.${item.nameDistricts} รหัสไปรษณีย์ ${item.zipCode}",
                  style: MyConstant().normalStyle(),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ],
        ),
      );
}
