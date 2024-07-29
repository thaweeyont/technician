import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/mechanic/homt.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

class SettingMechanic extends StatefulWidget {
  final idjob, idstaff, status_show;
  SettingMechanic(this.idjob, this.idstaff, this.status_show);

  @override
  _SettingMechanicState createState() => _SettingMechanicState();
}

class _SettingMechanicState extends State<SettingMechanic> {
  TextEditingController warningchange = TextEditingController();
  String? selectedValue_mec;
  List dropdown_mec = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dropdown_mec();
  }

  //api ยกเลิกงานติดตั้ง
  Future<Null> apidropjob() async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/drop_job_mechanic.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['idgen'] = widget.idjob;
    request.fields['id_staff'] = widget.idstaff;

    var response = await request.send();
    if (response.statusCode == 200) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false);
      print("อัปเดทข้อมูลสำเร็จ");
    } else {
      print("อัปเดทข้อมูลไม่สำเร็จ ${response.request}");
    }
  }

  //api เปลี่ยนช่างติดตั้ง
  Future<Null> apichangeMechanic() async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/insert_log_change_mechanic.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['selectedValue_mec'] = selectedValue_mec!;
    request.fields['warningchange'] = warningchange.text.toString();
    request.fields['idjob'] = widget.idjob;
    request.fields['idstaff'] = widget.idstaff;

    var response = await request.send();
    if (response.statusCode == 200) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false);
      print("อัปเดทข้อมูลสำเร็จ");
    } else {
      print("อัปเดทข้อมูลไม่สำเร็จ");
    }
  }

  //ช่างติดตั้ง
  void _dropdown_mec() async {
    var respose = await http
        .get(Uri.http(ipconfig, '/flutter_api/api_staff/list_user_staff.php'));
    if (respose.statusCode == 200) {
      var jsonData = jsonDecode(respose.body);
      setState(() {
        dropdown_mec = jsonData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(27, 55, 120, 1.0),
          elevation: 0,
          title: Text(
            "ตั้งค่างาน",
            style: MyConstant().h2whiteStyle(),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Color.fromRGBO(62, 105, 201, 1),
                  Color.fromRGBO(27, 55, 120, 1.0),
                ],
              ),
            ),
          )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title_page(),
          drop_job(context),
          SizedBox(height: 2),
          cheang_mechanic(context),
        ],
      ),
    );
  }

  InkWell drop_job(BuildContext context) {
    return InkWell(
      onTap: () {
        if (int.parse(widget.status_show.toString()) <= 1) {
          showProgressDialog(context);
          apidropjob();
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.grey[200],
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("ยกเลิกงาน",
                style: int.parse(widget.status_show.toString()) <= 1
                    ? MyConstant().normalredStyle()
                    : MyConstant().normalStyle()),
            if (int.parse(widget.status_show.toString()) <= 1) ...[
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey,
              )
            ]
          ],
        ),
      ),
    );
  }

  InkWell cheang_mechanic(BuildContext context) {
    return InkWell(
      onTap: () {
        warningchange.clear();
        get_change_dialog();
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.grey[200],
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("เปลี่ยนช่างติดตั้ง", style: MyConstant().h3Style()),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Container title_page() {
    return Container(
      padding:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      child: Text(
        "จัดการข้อมูล",
        style: MyConstant().h2_5Style(),
      ),
    );
  }

  Future<Null> get_change_dialog() async {
    var mediaQuery = MediaQuery.of(context);
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
    showAnimatedDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0,
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: sizeh * 0.01,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "เปลี่ยนช่างติดตั้ง ",
                                  style: MyConstant().h2_5Style(),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: size * 0.06,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(left: 5),
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 1.0,
                                              style: BorderStyle.solid,
                                              color: MyConstant.dark),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.0)),
                                        ),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: DropdownButton(
                                        hint: Text(
                                          "ชื่อช่างติดตั้ง",
                                          style: MyConstant().h3Style(),
                                        ),
                                        value: selectedValue_mec,
                                        items: dropdown_mec.map((meclist) {
                                          return DropdownMenuItem(
                                              value: [
                                                meclist['id_staff'],
                                                meclist['fullname_staff']
                                              ],
                                              child: Text(
                                                meclist['fullname_staff'],
                                                style: MyConstant().h3Style(),
                                              ));
                                        }).toList(),
                                        onChanged: (value) async {
                                          if (value != null) {
                                            setState(() {
                                              selectedValue_mec =
                                                  value.toString();
                                            });
                                          } else {
                                            selectedValue_mec =
                                                value.toString();
                                          }
                                          // print("============>$selectedValue_mec");
                                        },
                                        underline: Container(
                                          height: 2,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  child: TextFormField(
                                    style: MyConstant().h3Style(),
                                    minLines: 2,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    controller: warningchange,
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 25),
                                        child: Icon(Icons.warning_rounded),
                                      ),
                                      hintText: "สาเหตุที่เปลี่ยนช่างติดตั้ง",
                                      hintStyle: MyConstant().normalStyle(),
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 15, bottom: 10),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyConstant.dark_f,
                              ),
                              label: Text(
                                "ยืนยันเปลี่ยนช่างติดตั้ง",
                                style: MyConstant().normalwhiteStyle(),
                              ),
                              icon: Icon(Icons.add_shopping_cart_rounded),
                              onPressed: () {
                                if (warningchange.text != "" &&
                                    selectedValue_mec != "null") {
                                  showProgressDialog(context);
                                  apichangeMechanic();
                                } else {
                                  normalDialog(context, 'แจ้งเตือน',
                                      'กรอกข้อมูลให้ครบถ้วน');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      animationType: DialogTransitionType.slideFromRight,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }
}
