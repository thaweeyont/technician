import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:technician/credit/credit.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/mechanic/homt.dart';
import 'package:technician/ipconfig.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/models/staffmodel.dart';
import 'package:technician/models/versionapp.dart';
import 'package:technician/sale/sale.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //ประกาศตัวแปร
  TextEditingController id_staff = TextEditingController();
  String? version = MyConstant.version_app;
  List<Staff> datamechanic = [];
  String? token;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //function select data
  Future<void> _getid_staff(String id_staff) async {
    try {
      var respose = await http.get(
        Uri.http(ipconfig, '/flutter_api/api_staff/get_staff.php',
            {"id_staff": id_staff}),
      );
      print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล");

        setState(() {
          datamechanic = staffFromJson(respose.body);
          loginlog();
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
      normalDialog(context, 'แจ้งเตือน', "รหัสพนักงานไม่ถูกต้อง");
    }
  }

  @override
  void initState() {
    super.initState();
    _getversion();
  }

  Future<Null> gettoken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        token = value;
      });
      update_token(token!);
    });
  }

  Future<Null> update_token(String token) async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/update_token_staff.php");
    var request = new http.MultipartRequest("POST", uri);

    request.fields['token'] = token;
    request.fields['idstaff'] = id_staff.text;

    var response = await request.send();
    if (response.statusCode == 200) {
      print("==================>update_token_success");
      _getid_staff(id_staff.text);
    }
  }

  Future<Null> oldversion(
      BuildContext context, String title, String message) async {
    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Container(
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
              leading: Image.asset('images/error_log.gif'),
              title: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                ),
              ),
              subtitle: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: ResponsiveFlutter.of(context).fontSize(1.7),
                ),
              ),
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () async {
                      await launch("${versions[0].urlVersion}");
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "ตกลง",
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(1.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "ยกเลิก",
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(1.7),
                                color: Colors.red,
                              ),
                            ),
                          ],
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
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  List<Version> versions = [];
  //เรียกใช้ api เช็ค version
  Future<Null> _getversion() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig, '/flutter_api/api_staff/get_version_appstaff.php'));
      // print(respose.body);
      if (respose.statusCode == 200) {
        setState(() {
          versions = versionFromJson(respose.body);

          if (version == versions[0].version) {
            checkPreferance();
          } else {
            oldversion(context, 'version $version',
                'อัพเดตแอปพลิเคชั่น version $version => ${versions[0].version}');
          }
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  Future<Null> loginlog() async {
    var idStaff = datamechanic[0].idStaff;
    var status_staff = datamechanic[0].statusStaff;
    var name_staff = datamechanic[0].fullnameStaff;
    var zone_staff = datamechanic[0].zone;
    var initials_branch = datamechanic[0].initialsBranch;
    var branch_name = datamechanic[0].nameBranch;
    var branch_lat = datamechanic[0].latBranch;
    var branch_lng = datamechanic[0].lngBranch;
    var idBranch = datamechanic[0].idBranch;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('idStaff', idStaff!);
    preferences.setString('status_staff', status_staff!);
    preferences.setString('name_staff', name_staff!);
    preferences.setString('zone_staff', zone_staff!);
    preferences.setString('initials_branch', initials_branch!);
    preferences.setString('branch_name', branch_name!);
    preferences.setString('branch_lat', branch_lat!);
    preferences.setString('branch_lng', branch_lng!);
    preferences.setString('idBranch', idBranch!);

    if (status_staff == "1") {
      print("พนักงานขาย");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Sale(),
        ),
      );
    } else if (status_staff == "2") {
      print("สินเชื่อ");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Credit(),
        ),
      );
    } else if (status_staff == "3") {
      print("ช่างติดตั้ง");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    }
  }

  Future<Null> checkPreferance() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? check_staff = preferences.getString('status_staff');
      if (check_staff != null && check_staff.isNotEmpty) {
        if (check_staff == "1") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Sale(),
            ),
          );
        } else if (check_staff == "2") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Credit(),
            ),
          );
        } else if (check_staff == "3") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Home(),
            ),
          );
        }
      }
    } catch (e) {
      print("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [MyConstant.dark_f, MyConstant.dark_e],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logo(size),
              input_staff(size),
              button(size, sizeh, context),
            ],
          ),
        ),
      ),
    );
  }

  Container button(double size, double sizeh, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: size * 0.05),
      width: size * 0.35,
      height: sizeh * 0.05,
      // ignore: deprecated_member_use
      child: Container(
        decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(62, 105, 201, 1),
                Color.fromRGBO(27, 55, 120, 1.0)
              ],
            ),
            shadows: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 1,
                // offset: Offset(1, 2), // Shadow position
              ),
            ]),
        child: MaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.vpn_key_rounded,
                  size: size * 0.06,
                  color: Colors.white,
                ),
              ),
              Text(
                'เข้าสู่ระบบ',
                style: MyConstant().normalwhiteStyle(),
              ),
            ],
          ),
          onPressed: () {
            if (id_staff.text.isEmpty) {
              normalDialog(context, 'แจ้งเตือน', "กรุณากรอกรหัส");
            } else {
              gettoken();
            }
          },
        ),
      ),
    );
  }

  Container input_staff(double size) {
    return Container(
      margin: EdgeInsets.only(
        left: size * 0.10,
        right: size * 0.10,
        bottom: size * 0.04,
        top: size * 0.15,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(35),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.person,
              color: Colors.grey[450],
              size: size * 0.04,
            ),
            SizedBox(
              width: size * 0.02,
            ),
            Expanded(
              child: TextField(
                style: MyConstant().normaldarkStyle(),
                controller: id_staff,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "รหัสประจำตัวพนักงาน",
                  hintStyle: MyConstant().normallightStyle(),
                  border: InputBorder.none,
                ),
                onChanged: (String keyword) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container logo(double size) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        color: Colors.white,
      ),
      width: double.infinity,
      height: size * 0.30,
      child: Image.asset(
        'images/logo_mc2.png',
      ),
    );
  }
}
