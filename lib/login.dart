import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/models/staffmodel.dart';
import 'package:technician/utility/my_constant.dart';

import 'credit/home_checker_log.dart';
import 'ipconfig_checkerlog.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var zone_staff,
      initials_branch,
      branch_name,
      idStaff,
      name_staff,
      levelStatus,
      status_show;
  //ประกาศตัวแปร
  TextEditingController id_staff = TextEditingController();
  String? version = MyConstant.version_app;
  List<Staff> datamechanic = [];
  List data_checker_log = [];
  String? token;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    getprofile_staff();
  }

  Future<void> getprofile_staff() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idStaff = preferences.getString('idstaff');
    });

    if (idStaff != null) {
      checker_log(idStaff);
    }
  }

  //เรียกใช้ api login
  Future<Null> checker_log(idstaff) async {
    try {
      var respose = await http.get(Uri.http(
        ipconfig_checker,
        '/CheckerData2/api/Login.php',
        {"pws_us": idstaff},
      ));
      if (respose.statusCode == 200) {
        var status = json.decode(respose.body);
        if (status['status'] == 200) {
          data_checker_log = status['data'];
          setState(() {});
          var zone = data_checker_log[0]['zone'];
          var saka = data_checker_log[0]['saka'];
          var name_user = data_checker_log[0]['name_user'];
          var level = data_checker_log[0]['level_status'];
          var status_user = data_checker_log[0]['status_user'];
          var ip_conn = ipconfig_checker_office;
          print("========>no_office");
          if (respose.body != 'error') {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.setString('idstaff', idstaff!);
            preferences.setString('name_staff', name_user!);
            preferences.setString('statusUser', status_user!);
            if (status_user == '0') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => Home_Checker_log(
                        zone!, saka!, name_user!, level!, ip_conn)),
                (Route<dynamic> route) => false,
              );
            } else {
              normalDialog(
                  context, 'แจ้งเตือน', "ขออภัยรหัสนี้ไม่มีสิทธิ์เข้าใช้งาน");
            }
          } else {
            Navigator.pop(context);
            normalDialog(context, 'Error',
                "ขออภัย คุณไม่มีสิทธิ์เข้าถึง หน้า Checker Log");
          }
        } else {
          normalDialog(context, 'แจ้งเตือน', "ไม่พบรหัสพนักงาน");
        }
      }
    } catch (e) {
      var respose = await http.get(Uri.http(ipconfig_checker_office,
          '/CheckerData2/api/Login.php', {"pws_us": idstaff}));
      if (respose.statusCode == 200) {
        var status = json.decode(respose.body);

        if (status['status'] == 200) {
          data_checker_log = status['data'];
          setState(() {});
          var zone = data_checker_log[0]['zone'];
          var saka = data_checker_log[0]['saka'];
          var name_user = data_checker_log[0]['name_user'];
          var level = data_checker_log[0]['level_status'];
          var status_user = data_checker_log[0]['status_user'];
          var ip_conn = ipconfig_checker_office;
          print("========>office");
          if (respose.body != 'error') {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.setString('idstaff', idstaff!);
            preferences.setString('name_staff', name_user!);
            preferences.setString('statusUser', status_user!);
            if (status_user == '0') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => Home_Checker_log(
                    zone!,
                    saka!,
                    name_user!,
                    level!,
                    ip_conn,
                  ),
                ),
                (Route<dynamic> route) => false,
              );
            } else {
              normalDialog(
                  context, 'แจ้งเตือน', "ขออภัยรหัสนี้ไม่มีสิทธิ์เข้าใช้งาน");
            }
          } else {
            Navigator.pop(context);
            normalDialog(context, 'Error',
                "ขออภัย คุณไม่มีสิทธิ์เข้าถึง หน้า Checker Log");
          }
        } else {
          normalDialog(context, 'แจ้งเตือน', "ไม่พบรหัสพนักงาน");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    // return Scaffold(
    //   appBar: AppBar(
    //     centerTitle: true,
    //     elevation: 0,
    //     backgroundColor: MyConstant.dark_f,
    //   ),
    //   body: Container(
    //     width: double.infinity,
    //     height: double.infinity,
    //     decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //         colors: [
    //           MyConstant.dark_f,
    //           MyConstant.dark_e,
    //         ],
    //         begin: Alignment.topCenter,
    //         end: Alignment.bottomCenter,
    //         stops: [0.0, 1.0],
    //         tileMode: TileMode.clamp,
    //       ),
    //     ),
    //     child: Stack(
    //       alignment: Alignment.center,
    //       children: [
    //         Positioned(
    //           top: size * 0.28,
    //           child: Container(
    //             child: Column(
    //               children: [
    //                 logo(size),
    //               ],
    //             ),
    //           ),
    //         ),
    //         Positioned(
    //           top: size * 0.65,
    //           child: Container(
    //             width: MediaQuery.of(context).size.width * 0.798,
    //             height: MediaQuery.of(context).size.height * 0.15,
    //             decoration: BoxDecoration(
    //               color: Color.fromARGB(255, 231, 231, 231),
    //               borderRadius: BorderRadius.circular(25),
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: Color.fromARGB(255, 43, 43, 4).withAlpha(130),
    //                   spreadRadius: 0.8,
    //                   blurRadius: 20,
    //                   offset: const Offset(0, 7),
    //                 )
    //               ],
    //             ),
    //             child: Column(
    //               children: [
    //                 Padding(
    //                   padding: const EdgeInsets.all(10.0),
    //                   child: Text(
    //                     'เข้าสู่ระบบ',
    //                     style: MyConstant().text(),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         Positioned(
    //           top: size * 0.75,
    //           child: Container(
    //             width: MediaQuery.of(context).size.width * 0.8,
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(25),
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: Color.fromARGB(255, 43, 43, 43).withAlpha(130),
    //                   spreadRadius: 0.8,
    //                   blurRadius: 20,
    //                   offset: const Offset(0, 7),
    //                 )
    //               ],
    //             ),
    //             child: Column(
    //               children: [
    //                 SizedBox(height: 20),
    //                 input_staff(size),
    //                 SizedBox(height: 10),
    //                 button(size, sizeh, context),
    //                 SizedBox(height: 30),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(242, 246, 249, 255),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 194, 194, 194).withAlpha(130),
                    spreadRadius: 0.2,
                    blurRadius: 7,
                    offset: const Offset(0, 1),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    MyConstant.dark_f,
                    const Color.fromRGBO(62, 105, 201, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Container(
                  height: 350,
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(130),
                        spreadRadius: 0.2,
                        blurRadius: 7,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/TWYLOGO.png',
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),
                      SizedBox(height: 50),
                      input_staff(size),
                      SizedBox(height: 10),
                      button(size, sizeh, context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container button(double size, double sizeh, BuildContext context) {
    return Container(
      // width: size * 0.35,
      // height: sizeh * 0.05,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: Color.fromRGBO(62, 105, 201, 1),
          // gradient: LinearGradient(
          //   colors: [
          //     Color.fromRGBO(62, 105, 201, 1),
          //     Color.fromRGBO(27, 55, 120, 1.0)
          //   ],
          // ),
          shadows: [
            BoxShadow(
              color: Color.fromARGB(255, 150, 150, 150).withAlpha(130),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 5),
            )
          ],
        ),
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
              checker_log(id_staff.text);
            }
          },
        ),
      ),
    );
  }

  Container input_staff(double size) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(131, 228, 228, 228),
          borderRadius: BorderRadius.all(
            Radius.circular(35),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.account_circle,
              color: Color.fromARGB(132, 82, 82, 82),
              size: size * 0.06,
            ),
            SizedBox(
              width: size * 0.02,
            ),
            Expanded(
              child: TextField(
                style: MyConstant().normalblackStyle(),
                controller: id_staff,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "รหัสประจำตัวพนักงาน",
                  hintStyle: MyConstant().normalStyle(),
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
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 43, 43, 43).withAlpha(130),
            spreadRadius: 0.8,
            blurRadius: 20,
            offset: const Offset(0, 7),
          )
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      height: size * 0.30,
      child: Image.asset(
        'images/logo_mc2.png',
      ),
    );
  }
}
