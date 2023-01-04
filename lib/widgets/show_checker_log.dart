import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:technician/credit/home_checker_log.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig_checkerlog.dart';
import 'package:technician/models/user_checker_logmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

class ShowCheckerLog extends StatefulWidget {
  final String? id_staff;
  ShowCheckerLog(this.id_staff);

  @override
  _ShowCheckerLogState createState() => _ShowCheckerLogState();
}

class _ShowCheckerLogState extends State<ShowCheckerLog> {
  List<UserCheckerLogModel> data_checker_log = [];

  //เรียกใช้ api login
  Future<Null> checker_log(idstaff) async {
    try {
      var respose = await http.get(Uri.http(ipconfig_checker,
          '/checker_data/login_mobile.php', {"pws_us": idstaff}));
      if (respose.statusCode == 200) {
        setState(() {
          data_checker_log = userCheckerLogModelFromJson(respose.body);
        });
        var zone = data_checker_log[0].zone;
        var saka = data_checker_log[0].saka;
        var name_user = data_checker_log[0].nameUser;
        var level = data_checker_log[0].levelStatus;
        var ip_conn = ipconfig_checker;
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
      }
    } catch (e) {
      // print("ไม่มีข้อมูล");
      var respose = await http.get(Uri.http(ipconfig_checker_office,
          '/checker_data/login_mobile.php', {"pws_us": idstaff}));
      if (respose.statusCode == 200) {
        setState(() {
          data_checker_log = userCheckerLogModelFromJson(respose.body);
        });
        var zone = data_checker_log[0].zone;
        var saka = data_checker_log[0].saka;
        var name_user = data_checker_log[0].nameUser;
        var level = data_checker_log[0].levelStatus;
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
