import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:technician/credit/home_checker_log.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig_checkerlog.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

class ShowCheckerLog extends StatefulWidget {
  final String? id_staff;
  ShowCheckerLog(this.id_staff);

  @override
  _ShowCheckerLogState createState() => _ShowCheckerLogState();
}

class _ShowCheckerLogState extends State<ShowCheckerLog> {
  List data_checker_log = [];

  @override
  void initState() {
    super.initState();
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
        setState(() {
          // data_checker_log = userCheckerLogModelFromJson(respose.body);
          data_checker_log = json.decode(respose.body);
        });
        var zone = data_checker_log[0]['zone'];
        var saka = data_checker_log[0]['saka'];
        var name_user = data_checker_log[0]['name_user'];
        var level = data_checker_log[0]['level_status'];
        var ip_conn = ipconfig_checker_office;
        print("========>auther");
        if (respose.body != 'error') {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return Home_Checker_log(zone!, saka!, name_user!, level!, ip_conn);
          }));
        } else {
          Navigator.pop(context);
          normalDialog(context, 'Error',
              "ขออภัย คุณไม่มีสิทธิ์เข้าถึง หน้า Checker Log");
        }
      } else {
        normalDialog(context, 'Error', "check error");
      }
    } catch (e) {
      // print("ไม่มีข้อมูล");
      var respose = await http.get(Uri.http(ipconfig_checker_office,
          '/CheckerData2/api/Login.php', {"pws_us": idstaff}));
      if (respose.statusCode == 200) {
        setState(() {
          // data_checker_log = userCheckerLogModelFromJson(respose.body);
          data_checker_log = json.decode(respose.body);
        });
        var zone = data_checker_log[0]['zone'];
        var saka = data_checker_log[0]['saka'];
        var name_user = data_checker_log[0]['name_user'];
        var level = data_checker_log[0]['level_status'];
        var ip_conn = ipconfig_checker_office;
        print("========>office");
        if (respose.body != 'error') {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return Home_Checker_log(zone!, saka!, name_user!, level!, ip_conn);
          }));
        } else {
          Navigator.pop(context);
          normalDialog(context, 'Error',
              "ขออภัย คุณไม่มีสิทธิ์เข้าถึง หน้า Checker Log");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return ListTile(
      onTap: () async {
        checker_log(widget.id_staff);
        // print("login ${widget.id_staff}");
      },
      leading: Icon(
        Icons.domain_verification_outlined,
        size: size * 0.06,
      ),
      title: Text("Checker Log", style: MyConstant().h2_5Style()),
      subtitle: Text("บันทึกรูป/ข้อมูลทั่วไป", style: MyConstant().h3Style()),
    );
  }
}
