import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/credit/add_job_checker.dart';
import 'package:technician/credit/consider_job.dart';
import 'package:technician/credit/history.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/login.dart';
import 'package:http/http.dart' as http;
import 'package:technician/models/data_checker.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_checker_log.dart';
import 'package:technician/widgets/show_profile.dart';
import 'package:technician/widgets/show_signout.dart';
import 'package:technician/widgets/show_version.dart';

class Credit extends StatefulWidget {
  @override
  _CreditState createState() => _CreditState();
}

class _CreditState extends State<Credit> {
  var zone_staff,
      initials_branch,
      branch_name,
      idStaff,
      name_staff,
      status_show;
  late Timer timer;
  List<DataChecker> data_checker = [];
  final f = new DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    getprofile_staff();
    _getjob_log();
  }

  Future<String> getprofile_staff() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      zone_staff = preferences.getString('zone_staff');
      initials_branch = preferences.getString('initials_branch');
      branch_name = preferences.getString('branch_name');
      idStaff = preferences.getString('idStaff');
      name_staff = preferences.getString('name_staff');
    });

    return idStaff;
  }

  //เรียกใช้ api แสดง log
  Future<Null> _getjob_log() async {
    try {
      data_checker = [];
      var id = await getprofile_staff();
      var respose = await http.get(Uri.http(ipconfig,
          '/flutter_api/api_staff/get_data_checker.php', {"id_credit": id}));

      if (respose.statusCode == 200) {
        setState(() {
          data_checker = dataCheckerFromJson(respose.body);
          status_show = 1;
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(27, 55, 120, 1.0),
        elevation: 0,
        title: Text(
          "$name_staff",
          style: MyConstant().h2whiteStyle(),
        ),
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            ShowSignOut(),
            Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    "$name_staff",
                    style: MyConstant().h2_5whiteStyle(),
                  ),
                  accountEmail: Text(
                    "พนักงานสินเชื่อ",
                    style: MyConstant().normalwhiteStyle(),
                  ),
                  currentAccountPicture: ClipRRect(
                    borderRadius: BorderRadius.circular(110),
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: sizeh * 0.07,
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
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                ),
                ShowVersion(),
                new Divider(
                  height: 0,
                ),
                ShowProfile(idStaff),
                new Divider(
                  height: 0,
                ),
                ShowCheckerLog(idStaff),
                new Divider(
                  height: 0,
                ),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _getjob_log();
        },
        child: ListView(
          children: [
            Column(
              children: [
                stack_head(size),
                Column(
                  children: [
                    title_show(),
                    if (data_checker.isNotEmpty) ...[
                      detail(size, sizeh),
                    ] else ...[
                      SizedBox(
                        height: sizeh * 0.1,
                      ),
                      no_data(size, sizeh),
                    ]
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget stack_head(size) => Stack(
        children: [
          Positioned(
            // top: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 15,
              ),
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
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 0.45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      // print("รับงาน");
                      if (idStaff != "") {
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (context) {
                          return add_job_checker(
                              zone_staff, initials_branch, idStaff);
                        })).then((value) => {_getjob_log()});
                      }
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.description,
                          size: size * 0.1,
                          color: Colors.white,
                        ),
                        // Image.asset(
                        //   'images/icon_c.png',
                        //   height: MediaQuery.of(context).size.width * 0.10,
                        //   width: MediaQuery.of(context).size.width * 0.10,
                        // ),
                        Text(
                          "รับพิจารณาสัญญา",
                          style: MyConstant().normalwhiteStyle(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  InkWell(
                    onTap: () async {
                      print("ประวัติ");
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return history(idStaff);
                      })).then((value) => {_getjob_log()});
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.checklist_rtl_sharp,
                          size: size * 0.1,
                          color: Colors.white,
                        ),
                        // Image.asset(
                        //   'images/history.png',
                        //   height: MediaQuery.of(context).size.width * 0.10,
                        //   width: MediaQuery.of(context).size.width * 0.10,
                        // ),
                        Text(
                          "ประวัติงาน",
                          style: MyConstant().normalwhiteStyle(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: MediaQuery.of(context).size.width * 0.25),
            child: Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.white,
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.17,
              child: Image.asset(
                'images/logo_mc2.png',
              ),
            ),
          ),
        ],
      );

  Widget title_show() => Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
        child: Row(
          children: [
            Text(
              "รายการทีรอดำเนินงาน",
              style: MyConstant().normalStyle(),
            ),
          ],
        ),
      );

  Widget detail(size, sizeh) => Column(
        children: [
          for (int i = 0; i < data_checker.length; i++) ...[
            Container(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: InkWell(
                onTap: () async {
                  var id_job = data_checker[i].idJob;
                  var id_job_head = data_checker[i].idJobHead;

                  Navigator.push(context,
                      CupertinoPageRoute(builder: (context) {
                    return consider_job(id_job, id_job_head, idStaff);
                  })).then((value) => {_getjob_log()});
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  elevation: 1,
                  color: Colors.white,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'images/icons-h.gif',
                                  height: sizeh * 0.025,
                                  width: sizeh * 0.025,
                                ),
                                // Icon(
                                //   Icons.access_time_rounded,
                                //   color:
                                //       Color.fromRGBO(27, 55, 120, 1.0),
                                // ),
                                Text(
                                  " : เงิน${data_checker[i].productTypeContract}",
                                  style: MyConstant().h2_5Style(),
                                ),
                              ],
                            ),
                            Text(
                              f.format(DateTime.parse(
                                  data_checker[i].cratedDate.toString())),
                              style: MyConstant().normalStyle(),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: sizeh * 0.01,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "เลขบัตรประชาชน : ${data_checker[i].idCardUser}",
                                      style: MyConstant().h3Style(),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "ชื่อลูกค้า : ${data_checker[i].fullname}",
                                      style: MyConstant().h3Style(),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: sizeh * 0.001,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      );

  Widget no_data(size, sizeh) => Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: size * 0.20,
              color: Colors.grey[400],
            ),
            Text(
              "ไม่มีข้อมูล",
              style: MyConstant().h3lightStyle(),
            ),
          ],
        ),
      );
}
