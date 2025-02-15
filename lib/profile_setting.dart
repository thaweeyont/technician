import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/ipconfig_checkerlog.dart';
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
  TextEditingController nameuser = TextEditingController();
  TextEditingController pwsuser = TextEditingController();
  TextEditingController job = TextEditingController();
  TextEditingController area = TextEditingController();
  List<Staff> datamechanic = [];
  List dataUser = [];
  var checkJob = '';
  bool isReadOnly = true;

  @override
  void initState() {
    super.initState();
    // getid_staff(widget.idstaff);
    getDataUser();
  }

  //เรียกใช้ api แก้ไขข้อมูล
  Future update_profile() async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/edit_profilestaff.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['idstaff'] = widget.idstaff;
    request.fields['name'] = nameuser.text.toString();
    request.fields['phone'] = job.text.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      print("แก้ไขข้อมูลไม่สำเร็จ");
    }
  }

  Future<void> getDataUser() async {
    bool success = await fetchUserData(ipconfig_checker);

    if (!success) {
      success = await fetchUserData(ipconfig_checker_office);
    }

    if (!success) {
      normalDialog(context, 'แจ้งเตือน', "ไม่พบข้อมูลพนักงาน");
    }
  }

  Future<bool> fetchUserData(String baseUrl) async {
    print('ip>$baseUrl');
    try {
      var response = await http.get(Uri.http(baseUrl,
          '/CheckerData2/api/GetdataUser.php', {"pws_us": widget.idstaff}));

      if (response.statusCode == 200) {
        var status = json.decode(response.body);
        if (status['status'] == 200) {
          setState(() {
            dataUser = status['data'];
            nameuser.text = dataUser[0]['name_user'];
            pwsuser.text = dataUser[0]['pws'];
            job.text = checkJobPosition(dataUser[0]['level_status']);
            area.text =
                (dataUser[0]['zone'] != null && dataUser[0]['zone'] != '')
                    ? '${dataUser[0]['zone']} / ${dataUser[0]['saka']}'
                    : '-';
          });
          print('ได้ข่าววว');
          return true; // ✅ สำเร็จ return true
        }
      }
    } catch (e) {
      print("Error: $e");
    }
    print('จบข่าวววว');
    return false; // ❌ ล้มเหลว return false
  }

  // Future<void> getDataUser() async {
  //   try {
  //     var response = await http.get(Uri.http(
  //       ipconfig_checker,
  //       '/CheckerData2/api/GetdataUser.php',
  //       {"pws_us": widget.idstaff},
  //     ));
  //     if (response.statusCode == 200) {
  //       var status = json.decode(response.body);
  //       if (status['status'] == 200) {
  //         setState(() {
  //           dataUser = status['data'];
  //           nameuser.text = dataUser[0]['name_user'];
  //           pwsuser.text = dataUser[0]['pws'];
  //           job.text = checkJobPosition(dataUser[0]['level_status']);
  //           area.text = dataUser[0]['zone'] != null && dataUser[0]['zone'] != ''
  //               ? '${dataUser[0]['zone']} / ${dataUser[0]['saka']}'
  //               : '-';
  //         });
  //         print('1> $dataUser');
  //       }
  //     } else {
  //       normalDialog(context, 'แจ้งเตือน', "ไม่พบข้อมูลพนักงาน");
  //     }
  //   } catch (e) {
  //     var response = await http.get(Uri.http(
  //       ipconfig_checker_office,
  //       '/CheckerData2/api/GetdataUser.php',
  //       {"pws_us": widget.idstaff},
  //     ));
  //     if (response.statusCode == 200) {
  //       var status = json.decode(response.body);
  //       if (status['status'] == 200) {
  //         setState(() {
  //           dataUser = status['data'];
  //           nameuser.text = dataUser[0]['name_user'];
  //           pwsuser.text = dataUser[0]['pws'];
  //           job.text = checkJobPosition(dataUser[0]['level_status']);
  //           area.text = dataUser[0]['zone'] != null && dataUser[0]['zone'] != ''
  //               ? '${dataUser[0]['zone']} / ${dataUser[0]['saka']}'
  //               : '-';
  //         });
  //         print('2> $dataUser');
  //       }
  //     } else {
  //       normalDialog(context, 'แจ้งเตือน', "ไม่พบข้อมูลพนักงาน");
  //     }
  //   }
  // }

  checkJobPosition(position) {
    switch (position) {
      case 'chief':
        checkJob = 'ผจก.เช็คเกอร์';
        break;
      case 'checker_runnig':
        checkJob = 'ธุรการเช็คเกอร์';
        break;
      case 'checker':
        checkJob = 'พนักงานเช็คเกอร์';
        break;
      default:
        checkJob = '-';
        break;
    }
    return checkJob;
  }

  //function select data
  Future<void> getid_staff(String id_staff) async {
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
          nameuser.text = datamechanic[0].fullnameStaff!;
          if (datamechanic[0].phoneStaff != null) {
            job.text = datamechanic[0].phoneStaff!;
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
        backgroundColor: MyConstant.dark_f,
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: [
                tapbar(size, sizeh),
                SizedBox(height: sizeh * 0.02),
                username(size),
                pws(size),
                jobPosition(size),
                areasaka(size),
                submit(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tapbar(double size, sizeh) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          child: Container(
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
                tileMode: TileMode.clamp,
              ),
            ),
            width: size,
            height: sizeh * 0.13,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: sizeh * 0.07),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(100),
                ),
                color: Colors.white,
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
  }

  Widget username(size) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: nameuser,
              style: MyConstant().h3Style(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาเพิ่มชื่อ-สกุลพนักงาน';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person,
                  size: size * 0.06,
                ),
                labelText: "ชื่อ-สกุลพนักงาน",
                labelStyle: MyConstant().normalStyle(),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(360),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(360),
                  ),
                  borderSide: BorderSide(
                    color: MyConstant.dark, // สีของเส้น border เมื่อโฟกัส
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget pws(size) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: pwsuser,
              style: MyConstant().h3Style(),
              keyboardType: TextInputType.number,
              readOnly: isReadOnly,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาเพิ่มรหัสพนักงาน';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.badge,
                  size: size * 0.06,
                ),
                labelText: "รหัสพนักงาน",
                labelStyle: MyConstant().normalStyle(),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(360),
                  ),
                ),
                focusedBorder: isReadOnly
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(360),
                        ),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 121, 121, 121),
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(360),
                        ),
                        borderSide: BorderSide(
                          color: MyConstant.dark, // สีของเส้น border เมื่อโฟกัส
                        ),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget jobPosition(size) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              style: MyConstant().h3Style(),
              controller: job,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกตำแหน่ง';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.work,
                  size: size * 0.06,
                ),
                labelText: "ตำแหน่ง",
                labelStyle: MyConstant().normalStyle(),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(360),
                  ),
                ),
                focusedBorder: isReadOnly
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(360),
                        ),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 121, 121, 121),
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(360),
                        ),
                        borderSide: BorderSide(
                          color: MyConstant.dark, // สีของเส้น border เมื่อโฟกัส
                        ),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget areasaka(size) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              style: MyConstant().h3Style(),
              controller: area,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณา';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.fmd_good_rounded,
                  size: size * 0.06,
                ),
                labelText: "โซน/สาขา",
                labelStyle: MyConstant().normalStyle(),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(360),
                  ),
                ),
                focusedBorder: isReadOnly
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(360),
                        ),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 121, 121, 121),
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(360),
                        ),
                        borderSide: BorderSide(
                          color: MyConstant.dark, // สีของเส้น border เมื่อโฟกัส
                        ),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget submit(size) => Padding(
  //       padding: EdgeInsets.only(left: 20, right: 20),
  //       child: Container(
  //         decoration: ShapeDecoration(
  //           shape: const StadiumBorder(),
  //           gradient: LinearGradient(
  //             colors: [MyConstant.dark_e, MyConstant.dark_f],
  //           ),
  //         ),
  //         child: MaterialButton(
  //           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //           shape: const StadiumBorder(),
  //           child: Text(
  //             'แก้ไข',
  //             style: MyConstant().normalwhiteStyle(),
  //           ),
  //           onPressed: () {
  //             if (_formKey.currentState!.validate()) {
  //               String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
  //               RegExp regExp = new RegExp(pattern);
  //               if (!regExp.hasMatch(phonetext.text)) {
  //                 normalDialog(context, 'แจ้งเตือน', "เบอร์โทรไม่ถูกต้อง");
  //               } else {
  //                 // print(phonetext.text);
  //                 update_profile();
  //               }
  //             }
  //           },
  //         ),
  //       ),
  //     );
  Widget submit(size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MaterialButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const StadiumBorder(),
        padding: EdgeInsets.zero,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // final regExp = RegExp(r'(^(?:[+0]9)?[0-9]{10}$)');
            // if (!regExp.hasMatch(job.text)) {
            // normalDialog(context, 'แจ้งเตือน', "กรุณากรอกข้อมูลให้ครบ");
            // } else {}
            // } else {
            // update_profile();
            print('update');
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyConstant.dark_e, MyConstant.dark_f],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 45,
            child: Text(
              'แก้ไข',
              style: MyConstant().normalwhiteStyle(),
            ),
          ),
        ),
      ),
    );
  }
}
