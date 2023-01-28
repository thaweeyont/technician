import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:technician/credit/add_checker_log.dart';
import 'package:technician/credit/edit_Checker_log.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/ipconfig_checkerlog.dart';
import 'package:technician/models/customer_checker_logmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

class Home_Checker_log extends StatefulWidget {
  final String zone, saka, name_user, level, ip_conn;
  Home_Checker_log(
      this.zone, this.saka, this.name_user, this.level, this.ip_conn);

  @override
  _Home_Checker_logState createState() => _Home_Checker_logState();
}

class _Home_Checker_logState extends State<Home_Checker_log> {
  final f = new DateFormat('dd/MM/yyyy');
  List<CustomerCheckerLogModel> data_customer = [];
  TextEditingController search = TextEditingController();
  @override
  void initState() {
    super.initState();
    checker_log(widget.zone, widget.saka, widget.name_user);
  }

  //เรียกใช้ api แสดงข้อมูล
  Future<Null> checker_log(zone, saka, name_user) async {
    data_customer = [];
    try {
      var respose = await http.get(Uri.http(
          ipconfig_checker, '/checker_data/customer_checker_mobile.php', {
        "zone": zone,
        "saka": saka,
        "name_user": name_user,
        "level": widget.level.toString(),
      }));
      if (respose.statusCode == 200) {
        // print(respose.body);
        setState(() {
          data_customer = customerCheckerLogModelFromJson(respose.body);
          print("xxxxxxxxxxxxxxxxxxxxxx");
        });
        print("==============${data_customer[0].cusAddressImg}");
      }
    } catch (e) {
      print(widget.level);
      data_customer = [];
      var respose = await http.get(Uri.http(ipconfig_checker_office,
          '/checker_data/customer_checker_mobile.php', {
        "zone": zone,
        "saka": saka,
        "name_user": name_user,
        "level": widget.level.toString(),
      }));
      if (respose.statusCode == 200) {
        setState(() {
          print("zzzzzzzzzzzzzz");
          data_customer = customerCheckerLogModelFromJson(respose.body);
        });
        print("--------------${data_customer[0].cusAddressImg}");
      } else {
        normalDialog(context, 'Error', "check error");
      }
    }
  }

  //เรียกใช้ api แสดงข้อมูล
  Future<Null> filter_checker_log(zone, saka, runing, name_user) async {
    setState(() {
      data_customer = [];
    });
    try {
      var respose = await http.get(
          // Uri.http(widget.ip_conn, '/checker_data/filter_runing_mobile.php', {
          Uri.http(
              ipconfig_checker, '/checker_data/filter_runing_mobile_v2.php', {
        "zone": zone,
        "saka": saka,
        "runnig_id": runing,
        "name_user": name_user.toString(),
        "level": widget.level.toString(),
      }));
      if (respose.statusCode == 200) {
        setState(() {
          data_customer = customerCheckerLogModelFromJson(respose.body);
        });
      }
    } catch (e) {
      data_customer = [];
      var respose = await http.get(
          // Uri.http(widget.ip_conn, '/checker_data/filter_runing_mobile.php', {
          Uri.http(ipconfig_checker_office,
              '/checker_data/filter_runing_mobile_v2.php', {
        "zone": zone,
        "saka": saka,
        "runnig_id": runing,
        "name_user": name_user.toString(),
        "level": widget.level.toString(),
      }));
      if (respose.statusCode == 200) {
        setState(() {
          data_customer = customerCheckerLogModelFromJson(respose.body);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
        backgroundColor: MyConstant.dark_f,
        elevation: 0,
        title: Text(
          "${widget.name_user}",
          style: MyConstant().h2whiteStyle(),
        ),
        actions: [],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: RefreshIndicator(
          onRefresh: () async {
            checker_log(widget.zone, widget.saka, widget.name_user);
          },
          child: Column(
            children: [
              search_runing(size, sizeh),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  children: [
                    if (data_customer.isNotEmpty) ...[
                      detail(size, sizeh),
                    ] else ...[
                      Center(
                        child: new Text(
                          'ยังไม่มีข้อมูลในวันนี้',
                          style: MyConstant().h3Style(),
                        ),
                      ),
                    ],
                  ],
                ),
              )
              // Expanded(
              //   child: Scrollbar(
              //     child: SingleChildScrollView(
              //       physics: const BouncingScrollPhysics(
              //           parent: AlwaysScrollableScrollPhysics()),
              //       child: Column(
              //         children: [
              //           detail(size, sizeh),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.level == "checker_runnig"
          ? FloatingActionButton(
              backgroundColor: Colors.amber[600],
              onPressed: () => {
                Navigator.push(context, CupertinoPageRoute(builder: (context) {
                  return AddCheckerLog(widget.saka, widget.zone,
                      widget.name_user, widget.ip_conn, widget.level);
                })).then(
                  (value) =>
                      checker_log(widget.zone, widget.saka, widget.name_user),
                )
              },
              tooltip: 'เพิ่มข้อมูล',
              child: Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: () => {
                Navigator.push(context, CupertinoPageRoute(builder: (context) {
                  return AddCheckerLog(widget.saka, widget.zone,
                      widget.name_user, widget.ip_conn, widget.level);
                })).then(
                  (value) =>
                      checker_log(widget.zone, widget.saka, widget.name_user),
                )
              },
              tooltip: 'เพิ่มข้อมูล',
              child: Icon(Icons.add),
            ),
    );
  }

  Widget search_runing(size, sizeh) => Stack(
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
              width: double.infinity,
              height: sizeh * 0.1,
              child: Container(
                margin: EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          style: MyConstant().normalStyle(),
                          controller: search,
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "ค้นหาเลขที่รันนิ่ง หรือ ชื่อ-สกุล",
                            hintStyle: MyConstant().normalStyle(),
                            border: InputBorder.none,
                          ),
                          onChanged: (String keyword) {
                            if (keyword == "") {
                              checker_log(
                                  widget.zone, widget.saka, widget.name_user);
                            } else {
                              filter_checker_log(widget.zone, widget.saka,
                                  keyword, widget.name_user);
                            }
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.search,
                            color: Colors.black.withAlpha(120),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget detail(size, sizeh) => Column(
        children: [
          for (int i = 0; i < data_customer.length; i++) ...[
            Container(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: InkWell(
                onTap: () async {},
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
                                Icon(
                                  Icons.drag_indicator,
                                  color: Color.fromRGBO(27, 55, 120, 1.0),
                                ),
                                Text(
                                  "${data_customer[i].runnigId}",
                                  style: MyConstant().h3Style(),
                                ),
                              ],
                            ),
                            Text(
                              "${f.format(DateTime.parse(data_customer[i].dateInsert.toString()))} : ${data_customer[i].timeInsert}",
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
                                      "ชื่อลูกค้า : ${data_customer[i].cusPrefix}${data_customer[i].cusName} ${data_customer[i].cusLastname}",
                                      style: MyConstant().h3Style(),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                              // Text("ลูกค้า1 : ${data_customer[i].kam1Name}"),
                              // Text("ลูกค้า2 : ${data_customer[i].kam2Name}"),
                              // Text("ลูกค้า3 : ${data_customer[i].kam3Name}"),
                              val_kam(data_customer: data_customer, i: i),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "สถานะ : ${data_customer[i].status}",
                                        style: MyConstant().h3Style(),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          textStyle:
                                              MyConstant().normalyelloStyle(),
                                        ),
                                        onPressed: () {
                                          if (data_customer[i]
                                                  .idUser!
                                                  .isNotEmpty &&
                                              data_customer[i]
                                                  .runnigId!
                                                  .isNotEmpty &&
                                              data_customer[i]
                                                  .typeRunning!
                                                  .isNotEmpty) {
                                            Navigator.push(context,
                                                CupertinoPageRoute(
                                                    builder: (context) {
                                              return EditCheckerLog(
                                                  data_customer[i].idUser,
                                                  data_customer[i].saka,
                                                  data_customer[i].zone,
                                                  widget.name_user,
                                                  widget.ip_conn,
                                                  data_customer[i].runnigId,
                                                  data_customer[i].typeRunning,
                                                  widget.level);
                                            })).then((value) => checker_log(
                                                widget.zone,
                                                widget.saka,
                                                widget.name_user));
                                            search.clear();
                                          } else {
                                            print("empty");
                                          }
                                        },
                                        child: data_customer[i].status ==
                                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                                data_customer[i].status ==
                                                    "ตรวจสอบเสร็จสิ้น"
                                            ? Text(
                                                'ดูข้อมูล',
                                                style: MyConstant()
                                                    .normaldarkStyle(),
                                              )
                                            : Text(
                                                'แก้ไข',
                                                style: MyConstant()
                                                    .normalyelloStyle(),
                                              ),
                                      ),
                                    ],
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
}

class val_kam extends StatelessWidget {
  const val_kam({
    Key? key,
    required this.data_customer,
    required this.i,
  }) : super(key: key);

  final List<CustomerCheckerLogModel> data_customer;
  final int i;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (data_customer[i].kam1Name == "ไม่มี") ...[
          Expanded(
            child: Text(
              "ไม่มีผู้ค้ำ",
              style: MyConstant().h3Style(),
              overflow: TextOverflow.fade,
            ),
          ),
        ] else if (data_customer[i].kam1Name != "ไม่มี" &&
            data_customer[i].kam2Name == "ไม่มี") ...[
          Expanded(
            child: Text(
              "มีผู้ค้ำ",
              style: MyConstant().h3Style(),
              overflow: TextOverflow.fade,
            ),
          ),
        ] else if (data_customer[i].kam2Name != "ไม่มี" &&
            data_customer[i].kam3Name == "ไม่มี") ...[
          Expanded(
            child: Text(
              "มีผู้ค้ำ 2 คน",
              style: MyConstant().h3Style(),
              overflow: TextOverflow.fade,
            ),
          ),
        ] else if (data_customer[i].kam2Name != "ไม่มี" &&
            data_customer[i].kam3Name != "ไม่มี") ...[
          Expanded(
            child: Text(
              "มีผู้ค้ำ 3 คน",
              style: MyConstant().h3Style(),
              overflow: TextOverflow.fade,
            ),
          ),
        ]
      ],
    );
  }
}
