import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:technician/profile_setting.dart';
import 'package:technician/utility/my_constant.dart';

class ShowProfile extends StatelessWidget {
  final idstaff;
  ShowProfile(this.idstaff);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return ListTile(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) {
          return ProfileSetting(idstaff);
        }));
      },
      leading: Icon(
        Icons.account_circle,
        size: size * 0.06,
      ),
      title: Text(
        "โปรไฟล์",
        style: MyConstant().h2_5Style(),
      ),
      subtitle: Text(
        "ข้อมูลส่วนตัว / แก้ไขข้อมูล",
        style: MyConstant().h3Style(),
      ),
    );
  }
}
