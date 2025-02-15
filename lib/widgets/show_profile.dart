import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:technician/profile_setting.dart';

class ShowProfile extends StatelessWidget {
  final idstaff;
  ShowProfile(this.idstaff);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    return ListTile(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) {
          return ProfileSetting(idstaff);
        }));
      },
      leading: Icon(
        Icons.account_circle,
        size: size * 0.08,
      ),
      title: Text(
        "โปรไฟล์",
        style: TextStyle(
          fontFamily: 'Prompt',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(27, 55, 120, 1.0),
        ),
      ),
      subtitle: Text(
        "ข้อมูลส่วนตัว / แก้ไขข้อมูล",
        style: TextStyle(
          fontFamily: 'Prompt',
          fontSize: 12,
          color: Color.fromRGBO(27, 55, 120, 1.0),
        ),
      ),
    );
  }
}
