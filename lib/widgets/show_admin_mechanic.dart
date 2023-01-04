import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:technician/admin_mechanic/home_mechanic.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

class ShowAdminMechanic extends StatefulWidget {
  final String? id_staff, idBranch;
  ShowAdminMechanic(this.id_staff, this.idBranch);

  @override
  _ShowAdminMechanicState createState() => _ShowAdminMechanicState();
}

class _ShowAdminMechanicState extends State<ShowAdminMechanic> {
  //เรียกใช้ api เช็คสถานะ Admin
  Future<Null> check_status(idstaff) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/check_admin_mechanic.php',
          {"idstaff": idstaff}));

      if (respose.statusCode == 200) {
        if (respose.body != 'NOData') {
          Navigator.pop(context);
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return HomeMechanic(widget.idBranch);
          }));
        } else {
          Navigator.pop(context);
          normalDialog(context, 'Error', "ขออภัย คุณไม่มีสิทธิ์เข้าถึง Admin");
        }
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return ListTile(
      onTap: () async {
        showProgressDialog(context);
        check_status(widget.id_staff);
      },
      leading: Icon(
        Icons.people_alt_outlined,
        size: size * 0.06,
      ),
      title: Text("Admin", style: MyConstant().h2_5Style()),
      subtitle: Text("ตรวจสอบข้อมูลการติดตั้ง", style: MyConstant().h3Style()),
    );
  }
}
