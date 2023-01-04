import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/login.dart';
import 'package:technician/models/job_log.dart';
import 'package:technician/sale/adduser.dart';
import 'package:http/http.dart' as http;
import 'package:technician/sale/job_history.dart';
import 'package:technician/sale/log_adduser.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_profile.dart';
import 'package:technician/widgets/show_signout.dart';
import 'package:technician/widgets/show_version.dart';

class Sale extends StatefulWidget {
  Sale({Key? key}) : super(key: key);

  @override
  _SaleState createState() => _SaleState();
}

class _SaleState extends State<Sale> {
  var id_staff, name_staff;
  var status_show;
  late Timer timer;
  List<JobLog> job_log = [];
  final f = new DateFormat('dd/MM/yyyy');
  //เรียกใช้ api แสดง log
  Future<Null> _getjob_log() async {
    print("start");
    job_log = [];
    try {
      var id = await getprofile_staff();
      var respose = await http.get(Uri.http(
          ipconfig, '/flutter_api/api_staff/get_job_log.php', {"id_sale": id}));
      print(respose.body);
      if (respose.statusCode == 200) {
        setState(() {
          job_log = jobLogFromJson(respose.body);
        });
      }
    } catch (e) {}
  }

  //เรียกใช้ api ลบข้อมูล สินค้า
  Future<Null> _getDelete_log(String id_job) async {
    try {
      var respose = await http.get(Uri.http(ipconfig,
          '/flutter_api/api_staff/delete_job.php', {"id_job": id_job}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("ลบข้อมูลเสร็จสิ้น");
        _getjob_log();
      }
    } catch (e) {
      print("ลบไม่สำเร็จ");
    }
  }

  Future<Null> delete_job_dialog(String id_job, String name) async {
    showDialog(
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
            leading: Image.asset(
              'images/bin.gif',
              // width: 25,
              // height: 25,
            ),
            title: Text(
              '${name}',
              style: MyConstant().h2_5Style(),
            ),
            subtitle: Text(
              'ท่านต้องการลบข้อมูลใช่หรือไม่ ?',
              style: MyConstant().normalStyle(),
            ),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    _getDelete_log(id_job);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Text(
                        "ลบข้อมูล",
                        style: MyConstant().normalredStyle(),
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
                      Text(
                        "ยกเลิก",
                        style: MyConstant().h3Style(),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<String> getprofile_staff() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id_staff = preferences.getString('idStaff');
      name_staff = preferences.getString('name_staff');
    });

    return id_staff;
  }

  @override
  void initState() {
    super.initState();
    getprofile_staff();
    _getjob_log();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: MyConstant.dark_f,
        elevation: 0,
        title: Text(
          "$name_staff",
          style: MyConstant().h2whiteStyle(),
        ),
      ),
      drawer: Drawer(
        child: Container(
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
                      "พนักงานขาย",
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
                  ShowProfile(id_staff),
                  new Divider(
                    height: 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _getjob_log();
        },
        child: ListView(
          children: [
            header(size),
            Align(
              alignment: Alignment.center,
              child: body(size, sizeh),
            ),
          ],
        ),
      ),
    );
  }

  //header
  Widget header(size) => Stack(
        children: [
          Positioned(
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
                    colors: [MyConstant.dark_f, MyConstant.dark_e],
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
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return Adduser();
                      })).then((value) => {_getjob_log()});
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_shopping_cart_rounded,
                          size: size * 0.1,
                          color: Colors.white,
                        ),
                        Text(
                          "บันทึกการซื้อสินค้า",
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
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return jobHistory(id_staff!);
                      })).then((value) => {_getjob_log()});
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.checklist_rtl_sharp,
                          size: size * 0.1,
                          color: Colors.white,
                        ),
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
                top: MediaQuery.of(context).size.height * 0.15),
            child: Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Colors.white,
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.20,
              child: Image.asset(
                'images/logo_mc2.png',
              ),
            ),
          ),
        ],
      );

  Widget nodata(size, sizeh) => Center(
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

  Widget body(size, sizeh) => Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
            child: Row(
              children: [
                Text(
                  "รายการทีดำเนินงานอยู่",
                  style: MyConstant().normalStyle(),
                ),
              ],
            ),
          ),
          if (job_log.isNotEmpty) ...[
            for (int i = 0; i < job_log.length; i++) ...[
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: InkWell(
                  onTap: () async {
                    var id_job_head = job_log[i].idJobHead;
                    var id_card = job_log[i].idCardUser;
                    var name_u = job_log[i].fullname;
                    var phone_u = job_log[i].phoneUser;
                    var address_u = job_log[i].addressUser;

                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) {
                      return Log_Adduser(id_job_head!, id_card!, name_u!,
                          phone_u!, address_u!);
                    }));
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
                                  Text(
                                    " : ทวียนต์",
                                    style: MyConstant().h2_5Style(),
                                  ),
                                ],
                              ),
                              Text(
                                f.format(DateTime.parse(
                                    job_log[i].cratedDate.toString())),
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
                                        "ชื่อลูกค้า : ${job_log[i].fullname}",
                                        style: MyConstant().h3Style(),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        var id_job_log = job_log[i].idJob;
                                        var name = job_log[i].fullname;
                                        delete_job_dialog(id_job_log!, name!);
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: size * 0.06,
                                      ),
                                    )
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
              SizedBox(
                height: sizeh * 0.02,
              )
            ]
          ] else ...[
            SizedBox(
              height: sizeh * 0.1,
            ),
            nodata(size, sizeh),
          ]
        ],
      );
}
