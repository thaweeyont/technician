import 'package:flutter/material.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/login.dart';
import 'package:technician/utility/my_constant.dart';

class ShowSignOut extends StatelessWidget {
  const ShowSignOut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          child: ListTile(
            onTap: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.clear().then((value) => Navigator.of(context)
                  .pushReplacement(
                      MaterialPageRoute(builder: (context) => Login())));
            },
            leading: Icon(
              Icons.exit_to_app,
              size: size * 0.06,
              color: Colors.white,
            ),
            title: Text(
              "ออกจากระบบ",
              style: MyConstant().h2_5whiteStyle(),
            ),
            subtitle: Text(
              "ออกจากระบบเพื่อไปหน้า login",
              style: MyConstant().normalwhiteStyle(),
            ),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(27, 55, 120, 1.0),
                  const Color.fromRGBO(62, 105, 201, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ],
    );
  }
}
