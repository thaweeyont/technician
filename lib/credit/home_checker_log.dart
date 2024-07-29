import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/credit/add_checker_log.dart';
import 'package:technician/credit/edit_Checker_log.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig_checkerlog.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

import '../widgets/show_profile.dart';
import '../widgets/show_signout.dart';
import '../widgets/show_version.dart';

class Home_Checker_log extends StatefulWidget {
  final String zone, saka, name_user, level, ip_conn;
  Home_Checker_log(
      this.zone, this.saka, this.name_user, this.level, this.ip_conn);

  @override
  _Home_Checker_logState createState() => _Home_Checker_logState();
}

class _Home_Checker_logState extends State<Home_Checker_log> {
  var zone_staff,
      initials_branch,
      branch_name,
      idStaff,
      name_staff,
      status_show;
  double? lat, lng;
  String position = '';
  final f = new DateFormat('dd/MM/yyyy');
  List data_customer = [], dataAddress = [];
  TextEditingController search = TextEditingController();
  @override
  void initState() {
    super.initState();
    getprofile_staff();
    CheckPermission();
    checker_log(widget.zone, widget.saka, widget.name_user);
  }

  Future<void> getprofile_staff() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idStaff = preferences.getString('idstaff');
      name_staff = preferences.getString('name_staff');
    });
  }

  // CheckPermission
  Future<Null> CheckPermission() async {
    bool locationService;
    LocationPermission locationPermission;

    locationService = await Geolocator.isLocationServiceEnabled();
    if (locationService) {
      print('Service Location Open');
      locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.deniedForever) {
          alertLocationService(
              context, 'ไม่อนุญาติแชร์ Location', 'โปรดแชร์ location');
        } else {
          // Find LatLong
          findLatLng();
        }
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          alertLocationService(
              context, 'ไม่อนุญาติแชร์ Location', 'โปรดแชร์ location');
        } else {
          // Find LatLong
          findLatLng();
        }
      }
    } else {
      print('Service Location Close');
      alertLocationService(
          context, 'Location ปิดอยู่?', 'กรุณาเปิด Location ด้วยคะ');
    }
  }

  Future<Null> findLatLng() async {
    Position? position = await findPosition();
    setState(() {
      lat = position!.latitude;
      lng = position.longitude;
      print('lat_mec = $lat, lng_mec = $lng');
      getAddressFromCoordinates();
    });
  }

  void getAddressFromCoordinates() async {
    var latitude = lat;
    var longitude = lng;
    String address = await getAddress(latitude, longitude);
    setState(() {
      position = address;
    });
    print('Address: $address');
  }

  Future<String> getAddress(latitude, longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks != 'null' && placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address =
            '${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}';
        return address;
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return 'null';
  }

  Future<Position?> findPosition() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return position;
    } catch (e) {
      return null;
    }
  }

  //เรียกใช้ api แสดงข้อมูล
  Future<Null> checker_log(zone, saka, name_user) async {
    data_customer = [];
    try {
      var respose = await http.post(
          Uri.http(ipconfig_checker, '/CheckerData2/api/GetdataContract.php', {
        "zone": zone,
        "saka": saka,
        "name_user": name_user,
        "level": widget.level.toString(),
        "IdUser": idStaff,
      }));
      if (respose.statusCode == 200) {
        var status = json.decode(respose.body);
        if (status['status'] == 200) {
          setState(() {
            data_customer = status['data'];
          });
        }
      }
    } catch (e) {
      data_customer = [];
      var respose = await http.get(Uri.http(
          ipconfig_checker_office, '/CheckerData2/api/GetdataContract.php', {
        "zone": zone,
        "saka": saka,
        "name_user": name_user,
        "level": widget.level.toString(),
        "IdUser": idStaff,
      }));

      if (respose.statusCode == 200) {
        var status = json.decode(respose.body);
        if (status['status'] == 200) {
          setState(() {
            data_customer = status['data'];
          });
          print('${data_customer[0]['G1_Fname']}');
        }
      } else {
        normalDialog(context, 'Error', "check error");
      }
    }
  }

  //เรียกใช้ api แสดงข้อมูล
  Future<Null> filter_checker_log(zone, saka, running, name_user) async {
    data_customer = [];
    try {
      var respose = await http.get(Uri.http(
          ipconfig_checker, '/CheckerData2/api/GetSearchContract.php', {
        "zone": zone,
        "saka": saka,
        "running_id": running.toString(),
        "name_user": name_user.toString(),
        "level": widget.level.toString(),
      }));
      if (respose.statusCode == 200) {
        var status = json.decode(respose.body);

        if (status['status'] == 200) {
          setState(() {
            data_customer = status['data'];
          });
        }
      }
    } catch (e) {
      data_customer = [];
      var respose = await http.get(Uri.http(
          ipconfig_checker_office, '/CheckerData2/api/GetSearchContract.php', {
        "zone": zone,
        "saka": saka,
        "running_id": running.toString(),
        "name_user": name_user.toString(),
        "level": widget.level.toString(),
      }));
      if (respose.statusCode == 200) {
        var status = json.decode(respose.body);
        if (status['status'] == 200) {
          setState(() {
            data_customer = status['data'];
          });
        }
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
        centerTitle: true,
        backgroundColor: MyConstant.dark_f,
        elevation: 0,
        title: Image.asset(
          'images/logo_mc2.png',
          width: MediaQuery.of(context).size.width * 0.25,
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                color: Colors.white,
                Icons.menu,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: drawerStaff(sizeh),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              checker_log(widget.zone, widget.saka, widget.name_user);
            });
          },
          child: Column(
            children: [
              search_running(size, sizeh),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    if (data_customer.isNotEmpty) ...[
                      detail(size, sizeh),
                      SizedBox(height: 80),
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.level == "checker_runnig"
          ? FloatingActionButton(
              backgroundColor: Colors.amber[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
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
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : FloatingActionButton(
              backgroundColor: MyConstant.dark_f,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
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
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
    );
  }

  Drawer drawerStaff(double sizeh) {
    return Drawer(
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
                color: Colors.grey[200],
              ),
              ShowProfile(idStaff),
              new Divider(
                height: 0,
                color: Colors.grey[200],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget search_running(size, sizeh) => Stack(
        children: [
          Positioned(
            child: Container(
              // padding: EdgeInsets.only(top: 0),
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
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      children: [
                        Text(
                          "สวัสดีคุณ $name_staff",
                          style: MyConstant().h2whiteStyle(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: Colors.red,
                          size: MediaQuery.of(context).size.width * 0.05,
                        ),
                        Text(
                          '$position',
                          style: MyConstant().smallwhiteStyle(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Text(
                          "ค้นหาเอกสารสัญญา",
                          style: MyConstant().h2_5whiteStyle(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 0),
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
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "กรอกเลขรันนิ่งสัญญา",
                                hintStyle: MyConstant().normalStyle(),
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.black.withAlpha(120),
                                ),
                              ),
                              onChanged: (String keyword) {
                                if (keyword == "") {
                                  checker_log(widget.zone, widget.saka,
                                      widget.name_user);
                                } else {
                                  filter_checker_log(widget.zone, widget.saka,
                                      keyword, widget.name_user);
                                }
                              },
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(
                          //     Icons.search,
                          //     color: Colors.black.withAlpha(120),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget detail(size, sizeh) => Column(
        children: [
          for (var i = 0; i < data_customer.length; i++) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                onTap: () async {},
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  elevation: 1,
                  color: Colors.white,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.feed_outlined,
                                  color: Color.fromRGBO(27, 55, 120, 1.0),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "${data_customer[i]['running_id']}",
                                  style: MyConstant().h3Style(),
                                ),
                              ],
                            ),
                            Text(
                              "${f.format(DateTime.parse(data_customer[i]['date_insert']))} : ${data_customer[i]['time_insert']}",
                              style: MyConstant().normalStyle(),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              SizedBox(
                                height: sizeh * 0.01,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "ชื่อลูกค้า : ${data_customer[i]['cus_prefix']}${data_customer[i]['cus_name']} ${data_customer[i]['cus_lastname']}",
                                      style: MyConstant().h3Style(),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3),
                              val_kam(data_customer: data_customer, i: i),
                              SizedBox(height: 3),
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
                                        "สถานะ : ${data_customer[i]['status']}",
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
                                          if (data_customer[i]['id_user']
                                                  .toString()
                                                  .isNotEmpty &&
                                              data_customer[i]['running_id']
                                                  .toString()
                                                  .isNotEmpty &&
                                              data_customer[i]['type_running']
                                                  .toString()
                                                  .isNotEmpty) {
                                            Navigator.push(context,
                                                CupertinoPageRoute(
                                                    builder: (context) {
                                              return EditCheckerLog(
                                                  data_customer[i]['id_user'],
                                                  data_customer[i]['saka'],
                                                  data_customer[i]['zone'],
                                                  widget.name_user,
                                                  widget.ip_conn,
                                                  data_customer[i]
                                                      ['running_id'],
                                                  data_customer[i]
                                                      ['type_running'],
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
                                        child: data_customer[i]['status'] ==
                                                    "ตรวจสอบสัญญาเรียบร้อย" ||
                                                data_customer[i]['status'] ==
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

  final List data_customer;
  final int i;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (data_customer[i]['G1_Fname'] == null) ...[
          Expanded(
            child: Text(
              "ไม่มีผู้ค้ำ",
              style: MyConstant().h3Style(),
              overflow: TextOverflow.fade,
            ),
          ),
        ] else if (data_customer[i]['G1_Fname'] != null &&
            data_customer[i]['G2_Fname'] == null) ...[
          Expanded(
            child: Text(
              "มีผู้ค้ำ 1 คน",
              style: MyConstant().h3Style(),
              overflow: TextOverflow.fade,
            ),
          ),
        ] else if (data_customer[i]['G2_Fname'] != null &&
            data_customer[i]['G3_Fname'] == null) ...[
          Expanded(
            child: Text(
              "มีผู้ค้ำ 2 คน",
              style: MyConstant().h3Style(),
              overflow: TextOverflow.fade,
            ),
          ),
        ] else if (data_customer[i]['G2_Fname'] != null &&
            data_customer[i]['G3_Fname'] != null) ...[
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
