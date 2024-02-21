import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
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
              exitDialog(context, 'ออกจากระบบ', 'คุณต้องการออกจากระบบนี้?');
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

  Future<Null> exitDialog(
      BuildContext context, String title, String message) async {
    var size = MediaQuery.of(context).size.width;
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
            // leading: Image.asset('images/error_log.gif'),
            leading: Icon(
              Icons.exit_to_app,
              size: size * 0.1,
              color: Colors.black,
            ),
            title: Text(title, style: MyConstant().h2_5Style()),
            subtitle: Text(message, style: MyConstant().normalStyle()),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    // SharedPreferences preferences =
                    //     await SharedPreferences.getInstance();
                    // preferences.clear().then((value) => Navigator.of(context)
                    //     .pushReplacement(
                    //         MaterialPageRoute(builder: (context) => Login())));
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    preferences.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Column(
                    children: [
                      Text("ออกจากระบบ", style: MyConstant().exitStyle()),
                    ],
                  ),
                ),
                SizedBox(width: 60),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Text("ยกเลิก", style: MyConstant().h3Style()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 0),
    );
  }
}
