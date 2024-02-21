import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/staffmodel.dart';
import 'package:technician/utility/my_constant.dart';

class ProfileSetting extends StatefulWidget {
  final idstaff;
  ProfileSetting(this.idstaff);

  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nametext = TextEditingController();
  TextEditingController phonetext = TextEditingController();
  List<Staff> datamechanic = [];

  @override
  void initState() {
    super.initState();
    _getid_staff(widget.idstaff);
  }

  //เรียกใช้ api แก้ไขข้อมูล
  Future update_profile() async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/edit_profilestaff.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['idstaff'] = widget.idstaff;
    request.fields['name'] = nametext.text.toString();
    request.fields['phone'] = phonetext.text.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      print("แก้ไขข้อมูลไม่สำเร็จ");
    }
  }

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
          nametext.text = datamechanic[0].fullnameStaff!;
          if (datamechanic[0].phoneStaff != null) {
            phonetext.text = datamechanic[0].phoneStaff!;
          }
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "แก้ไขโปรไฟล์",
          style: MyConstant().h2whiteStyle(),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: [
              tapbar(size, sizeh),
              SizedBox(height: sizeh * 0.02),
              username(size),
              phone(size),
              submit(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget tapbar(double size, sizeh) => Stack(
        children: [
          Positioned(
            top: 0,
            child: Container(
              // padding: EdgeInsets.only(
              //   top: 15,
              // ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
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
              width: size,
              height: sizeh * 0.15,
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [],
              // ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: sizeh * 0.10),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                  color: Colors.grey[50],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: size * 0.25,
                      color: Color.fromRGBO(62, 105, 201, 1),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  Widget username(size) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: nametext,
                style: MyConstant().h3Style(),
                // keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเพิ่มชื่อ-สกุลพนักงาน';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.account_box_rounded,
                    size: size * 0.06,
                  ),
                  labelText: "ชื่อ-สกุลพนักงาน",
                  labelStyle: MyConstant().normalStyle(),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(360),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );

  Widget phone(size) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                style: MyConstant().h3Style(),
                controller: phonetext,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเพิ่มเบอร์โทร';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.local_phone_rounded,
                    size: size * 0.06,
                  ),
                  labelText: "เบอร์โทร",
                  labelStyle: MyConstant().normalStyle(),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(360),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );

  Widget submit(size) => Padding(
      padding: EdgeInsets.only(left: 35, right: 35),
      child: Container(
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          gradient: LinearGradient(
            colors: [MyConstant.dark_e, MyConstant.dark_f],
          ),
        ),
        child: MaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
          child: Text(
            'แก้ไข',
            style: MyConstant().normalwhiteStyle(),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
              RegExp regExp = new RegExp(pattern);
              if (!regExp.hasMatch(phonetext.text)) {
                normalDialog(context, 'แจ้งเตือน', "เบอร์โทรไม่ถูกต้อง");
              } else {
                // print(phonetext.text);
                update_profile();
              }
            }
          },
        ),
      ));
}
