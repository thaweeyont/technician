import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:package_info/package_info.dart';
import 'package:technician/ipconfig.dart';
import 'package:http/http.dart' as http;
import 'package:technician/models/versionapp.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowVersion extends StatefulWidget {
  ShowVersion({Key? key}) : super(key: key);

  @override
  _ShowVersionState createState() => _ShowVersionState();
}

class _ShowVersionState extends State<ShowVersion> {
  String? version = MyConstant.version_app;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    // buildSignature: 'Unknown',
    // installerStore: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  Future<Null> oldversion(
      BuildContext context, String title, String message) async {
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
            leading: Image.asset('images/error_log.gif'),
            title: Text(
              title,
              style: MyConstant().h2_5whiteStyle(),
            ),
            subtitle: Text(
              message,
              style: MyConstant().normalStyle(),
            ),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () async {
                    await canLaunchUrl('${versions[0].urlVersion}' as Uri);
                    // await launch("${versions[0].urlVersion}");
                  },
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "ตกลง",
                            style: MyConstant().h3Style(),
                          ),
                        ],
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
                      Row(
                        children: [
                          Text(
                            "ยกเลิก",
                            style: MyConstant().normalredStyle(),
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
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 0),
    );
  }

  Future<Null> newversion(
      BuildContext context, String title, String message) async {
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
            leading: Image.asset('images/success.png'),
            title: Text(
              title,
              style: MyConstant().h2_5Style(),
            ),
            subtitle: Text(
              message,
              style: MyConstant().textVersion(),
            ),
          ),
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Column(
                children: [
                  Text(
                    "ตกลง",
                    style: MyConstant().h3Style(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 0),
    );
  }

  List<Version> versions = [];
  //เรียกใช้ api เช็ค version
  Future<Null> getversion() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig, '/flutter_api/api_staff/get_version_appstaff.php'));
      // print(respose.body);
      if (respose.statusCode == 200) {
        setState(() {
          versions = versionFromJson(respose.body);
          if (version == versions[0].version) {
            newversion(context, 'version $version',
                'แอปพลิเคชั่นเป็นเวอร์ชั่นปัจจุบัน');
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return ListTile(
      onTap: () async {
        // getversion();
        newversion(context, 'version ${packageInfo.version}',
            'แอปพลิเคชั่นเป็นเวอร์ชั่นปัจจุบัน');
      },
      leading: Icon(
        Icons.info_outline,
        size: size * 0.08,
      ),
      title: Text(
        "เวอร์ชั่นแอป",
        style: TextStyle(
          fontFamily: 'Prompt',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(27, 55, 120, 1.0),
        ),
      ),
      subtitle: Text(
        "เช็คเวอร์ชั่นแอปพลิเคชั่นล่าสุด",
        style: TextStyle(
          fontFamily: 'Prompt',
          fontSize: 12,
          color: Color.fromRGBO(27, 55, 120, 1.0),
        ),
      ),
    );
  }
}
