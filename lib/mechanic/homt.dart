import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:decorated_icon/decorated_icon.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:technician/dialog/dialog.dart';
import 'package:technician/mechanic/add_job_mechanic.dart';
import 'package:technician/mechanic/detailjob.dart';
import 'package:technician/mechanic/history.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/login.dart';
import 'package:technician/models/detail_product.dart';
import 'package:technician/models/jobmodel.dart';
import 'package:technician/models/product_detail.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:technician/models/stampmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_admin_mechanic.dart';
import 'package:technician/widgets/show_profile.dart';
import 'package:technician/widgets/show_signout.dart';
import 'package:technician/widgets/show_version.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  var check;
  var id;
  var id_mc;
  var zone_staff,
      initials_branch,
      branch_name,
      idStaff,
      name_staff,
      status_show,
      branch_lat,
      idBranch,
      branch_lng;
  var date_st = null;
  bool status_on_off = true;
  List<Job> datajob = [];
  List<Stamp> dataStamp = [];
  double? lat, lng;
  bool show_icon_title = true;
  double opacity = 0.0;
  Timer? timer;
  Key key = UniqueKey();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    st_notification();
    getprofile_staff();
    aboutNotification();
    // _getstamp();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        // ออกแอป
        restartApp();
        break;
      case AppLifecycleState.resumed:
        //กลับมาเปิดแอป
        restartApp();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  //รีสตาร์ทแอป
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  //Notification
  Future<Null> aboutNotification() async {
    FirebaseMessaging.instance.getToken().then((value) {
      if (Platform.isAndroid) {
        print("ANDROID");

        // FirebaseMessaging.onMessage.listen((message) async {
        //   show_notification('แจ้งเตือน', 'มีงานใหม่');
        //   // showProgressDialog(context);
        // });

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (message.notification != null) {
            // print('Message on Foreground: ${message.notification}');
            // show_notification('แจ้งเตือน', 'มีงานติดตั้งกรุณาตรวจสอบ');
            show_notification('แจ้งเตือน', 'มีการอัปเดทข้อมูล');
            getprofile_staff();
          }
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          if (message.notification != null) {
            // print('Message on Foreground: ${message.notification}');
            getprofile_staff();
          }
        });

        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler);
      } else if (Platform.isIOS) {
        print("IOS");
      }
    });
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    print("Handling a background message :-): ${message.data}");
    //Here you can do what you want with the message :-)
  }

  //setting notification
  Future<void> st_notification() async {
    WidgetsFlutterBinding.ensureInitialized();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  //แสดงแจ้งเตื่อนถึงเวลาปิดงานทันที
  Future<void> show_notification(title, body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'nextflow_noti_001', 'แจ้งเตือนทั่วไป', 'แจ้งเตือนทั่วไป',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails platformChannelDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelDetails);
  }

  //แสดงแจ้งเตื่อนถึงเวลาปิดงานแบบตั้งเวลา
  Future<void> show_notification_delay() async {
    timer = Timer.periodic(Duration(minutes: 1), (Timer t) async {
      DateTime now = DateTime.now(); // 30/09/2021 15:54:30
      var hours = now.hour;
      var minute = now.minute;
      var timeDelayed = DateTime.now().add(Duration(seconds: 1));
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'nextflow_noti_001', 'แจ้งเตือนทั่วไป', 'แจ้งเตือนทั่วไป',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');

      const NotificationDetails platformChannelDetails = NotificationDetails(
        android: androidNotificationDetails,
      );
      await flutterLocalNotificationsPlugin.schedule(
          0,
          'แจ้งเตือน',
          'เวลา $hours:$minute นาที อย่าลืมปิดรับงานขอบคุณครับ',
          timeDelayed,
          platformChannelDetails);
    });
  }

  //function select data
  Future<Null> _getstamp() async {
    dataStamp = [];
    DateTime now = DateTime.now(); // 30/09/2021 15:54:30
    var hours = now.hour;
    var minute = now.minute;
    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      // print(idStaff);
      var respose = await http
          .get(Uri.http(ipconfig, '/flutter_api/api_staff/check_stamp.php', {
        "id_staff": idStaff,
        "date_stamp": convertedDateTime,
      }));
      print(respose.body);
      if (respose.statusCode == 200) {
        if (respose.body == "NO Data Found.") {
          //ไม่มีข้อมูล
          // print("1");
          setState(() {
            status_on_off = false;
          });
          // St_stamp(
          //     context,
          //     'เปิดรับงาน',
          //     'กดยืนยันเพื่อเปิดรับงานวันที่ $convertedDateTime',
          //     convertedDateTime);
        } else {
          //มีข้อมูล
          setState(() {
            dataStamp = stampFromJson(respose.body);
            if (dataStamp[0].statusStamp == "on") {
              status_on_off = true;
              if (hours >= 17) {
                if (hours == 17) {
                  if (minute >= 30) {
                    //แจ้งเตือน
                    show_notification('แจ้งเตือน',
                        'เวลา $hours:$minute นาที อย่าลืมปิดรับงานขอบคุณครับ');
                  }
                } else {
                  //แจ้งเตือน
                  show_notification('แจ้งเตือน',
                      'เวลา $hours:$minute นาที อย่าลืมปิดรับงานขอบคุณครับ');
                }
              }
            } else {
              status_on_off = false;
            }
          });
          // print("2");
        }
      }
    } catch (e) {
      // print("ไม่มีข้อมูล");
    }
  }

  Future<Null> stamplDialog(
      BuildContext context, String title, String message) async {
    DateTime now = DateTime.now(); // 30/09/2021 15:54:30
    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    showAnimatedDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Container(
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
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                ),
              ),
              subtitle: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: ResponsiveFlutter.of(context).fontSize(1.7),
                ),
              ),
            ),
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // St_stamp(
                  //     context,
                  //     'เปิดรับงาน',
                  //     'กดยืนยันเพื่อเปิดรับงานวันที่ $convertedDateTime',
                  //     convertedDateTime);
                },
                child: Column(
                  children: [
                    Text(
                      "ตกลง",
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: ResponsiveFlutter.of(context).fontSize(1.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  Future<Null> St_stamp(BuildContext context, String title, String message,
      convertedDateTime) async {
    double size = MediaQuery.of(context).size.width;
    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: StatefulBuilder(
          builder: (context, setState) => Container(
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
                leading: Icon(
                  Icons.date_range,
                  size: size * 0.08,
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                  ),
                ),
                subtitle: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: ResponsiveFlutter.of(context).fontSize(1.7),
                  ),
                ),
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () async {
                        CheckPermission();
                        showProgressDialog(context);
                        // await CheckPermission();
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "ตกลง",
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: ResponsiveFlutter.of(context)
                                      .fontSize(1.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.clear();
                        exit(0);
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "ออกจากระบบ",
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: ResponsiveFlutter.of(context)
                                      .fontSize(1.7),
                                  color: Colors.red,
                                ),
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
        ),
      ),
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  //เช็คการขอสิทใช้ gps
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

  Future<Position?> findPosition() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      return null;
    }
  }

  Future<Null> findLatLng() async {
    DateTime now = DateTime.now(); // 30/09/2021 15:54:30
    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    Position? position = await findPosition();
    setState(() {
      show_icon_title = true;
      lat = position!.latitude;

      lng = position.longitude;

      // print('lat = $lat, lng = $lng');
      if (lat != null) {
        Navigator.pop(context);

        var distance = calculateDistance();
        // if (distance < 0.500) {
        //   print("เริ่มงานได้1 ==> $distance");
        //   showProgressDialog(context);
        //   insert_stamp(convertedDateTime);
        // } else {
        //   print("ระยะทางไกลเกินไป ==> $distance");
        //   stamplDialog(
        //       context, 'เตือน !', 'คุณอยู่ห่างจากสาขาเกินระยะที่กำหนด');
        // }
        if (status_on_off == false) {
          //กดเปิดรับงาน
          var hours = now.hour;

          if (hours >= 8 && hours < 18) {
            print("เวลาชั่วโมง --------> $hours");

            if (distance < 0.500) {
              print("เปิดรับงาน ==> $distance");
              showProgressDialog(context);
              insert_stamp(convertedDateTime);
            } else {
              print("ระยะทางไกลเกินไป ==> $distance");
              stamplDialog(
                  context, 'เตือน !', 'คุณอยู่ห่างจากสาขาเกินระยะที่กำหนด');
            }
          } else {
            normalDialog(context, 'เตือน',
                'ไม่สามารถเปิดรับงานได้เพราะอยู่นอกเวลาที่กำหนด');
          }
        } else {
          //กดปิดรับงาน
          if (distance < 0.500) {
            print("ปิดรับงาน ==> $distance");
            showProgressDialog(context);
            insert_stamp(convertedDateTime);
          } else {
            print("ระยะทางไกลเกินไป ==> $distance");
            stamplDialog(
                context, 'เตือน !', 'คุณอยู่ห่างจากสาขาเกินระยะที่กำหนด');
          }
        }
      }
    });
  }

  //คำนวณหาระยะทาง หน่วย กิโลเมตร
  double calculateDistance() {
    double distance = 0;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((double.parse(branch_lat) - lat!) * p) / 2 +
        c(lat! * p) *
            c(double.parse(branch_lat) * p) *
            (1 - c((double.parse(branch_lng) - lng!) * p)) /
            2;
    distance = 12742 * asin(sqrt(a));
    return distance;
  }

  Future<Null> CheckStamp() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    DateTime now = DateTime.now(); // 30/09/2021 15:54:30
    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (preferences.getString('date_stamp') == null) {
      St_stamp(
          context,
          'เปิดรับงาน',
          'กดยืนยันเพื่อเปิดรับงานวันที่ $convertedDateTime',
          convertedDateTime);
    } else {
      date_st = preferences.getString('date_stamp');
      print("มีค่าอยู่แล้ว ===> $date_st");
    }
  }

  Future<Null> getprofile_staff() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      zone_staff = preferences.getString('zone_staff');
      initials_branch = preferences.getString('initials_branch');
      branch_name = preferences.getString('branch_name');
      idStaff = preferences.getString('idStaff');
      name_staff = preferences.getString('name_staff');
      branch_lat = preferences.getString('branch_lat');
      branch_lng = preferences.getString('branch_lng');
      idBranch = preferences.getString('idBranch');
    });
    _getJob();
    _getstamp();
  }

  //function select data
  Future<Null> _getJob() async {
    datajob = [];
    try {
      var respose = await http.get(Uri.http(ipconfig,
          '/flutter_api/api_staff/get_job_mc.php', {"id_mechanic": idStaff}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        // print("มีข้อมูล");
        setState(() {
          datajob = jobFromJson(respose.body);
        });
      }
    } catch (e) {
      // print("ไม่มีข้อมูล");
    }
  }

  //บันทึกการเข้างาน
  Future insert_stamp(date_st) async {
    var status;
    if (status_on_off == true) {
      setState(() {
        status = "off";
      });
    } else {
      setState(() {
        status = "on";
      });
    }
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/insert_stamp.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id_staff'] = idStaff;
    request.fields['date_stamp'] = date_st;
    request.fields['lat'] = lat.toString();
    request.fields['lng'] = lng.toString();
    request.fields['status'] = status;

    var response = await request.send();
    if (response.statusCode == 200) {
      print("เพิ่มข้อมูลสำเร็จ");
      Navigator.pop(context);
      _getJob();
      _getstamp();
    } else {
      print("ไม่สำเร็จ");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return Scaffold(
      key: key,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: status_on_off == true
            ? Color.fromRGBO(27, 55, 120, 1.0)
            : Color.fromRGBO(255, 219, 77, 1.0),
        elevation: 0,
        title: status_on_off == true
            ? Padding(
                padding: const EdgeInsets.only(right: 0),
                child: InkWell(
                  onTap: () async {
                    // show_notification();
                    setState(() {
                      opacity = 1.0;
                      show_icon_title = false;
                    });
                    showProgressDialog(context);
                    await Future.delayed(const Duration(seconds: 5));
                    CheckPermission();
                  },
                  child: show_icon_title == false
                      ? AnimatedOpacity(
                          duration: const Duration(seconds: 1),
                          opacity: opacity,
                          child: Text(
                            "ปิดรับงาน",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize:
                                  ResponsiveFlutter.of(context).fontSize(2.5),
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        )
                      : DecoratedIcon(
                          Icons.power_settings_new_rounded,
                          color: Colors.lightBlue.shade50,
                          size: size * 0.07,
                          shadows: [
                            BoxShadow(
                              blurRadius: 12.0,
                              color: Colors.blue,
                            ),
                            BoxShadow(
                              blurRadius: 12.0,
                              color: Colors.green,
                              offset: Offset(0, 6.0),
                            ),
                          ],
                        ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 0),
                child: InkWell(
                  onTap: () async {
                    // show_notification();
                    setState(() {
                      show_icon_title = false;
                    });
                    showProgressDialog(context);
                    await Future.delayed(const Duration(seconds: 5));
                    CheckPermission();
                  },
                  child: show_icon_title == false
                      ? Text(
                          "เปิดรับงาน",
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize:
                                ResponsiveFlutter.of(context).fontSize(2.5),
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        )
                      : DecoratedIcon(
                          Icons.power_settings_new_rounded,
                          color: Colors.red,
                          size: size * 0.07,
                          shadows: [
                            BoxShadow(
                              blurRadius: 12.0,
                              color: Colors.red,
                            ),
                            BoxShadow(
                              blurRadius: 12.0,
                              color: Colors.red,
                              offset: Offset(0, 6.0),
                            ),
                          ],
                        ),
                ),
              ),
        // ? Text(
        //     "เปิดรับงาน",
        //     style: TextStyle(
        //         fontFamily: 'Prompt',
        //         fontSize: ResponsiveFlutter.of(context).fontSize(2.5),
        //         fontWeight: FontWeight.bold,
        //         color: Colors.green),
        //   )
        // : Text(
        //     "ปิดรับงาน",
        //     style: TextStyle(
        //       fontFamily: 'Prompt',
        //       fontSize: ResponsiveFlutter.of(context).fontSize(2.5),
        //       fontWeight: FontWeight.bold,
        //       color: Colors.red,
        //     ),
        //   ),
        //---------------------------------
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: InkWell(
        //       onTap: () {
        //         showProgressDialog(context);
        //         CheckPermission();
        //       },
        //       child: Icon(
        //         Icons.power_settings_new_rounded,
        //         size: size * 0.07,
        //       ),
        //     ),
        //   ),
        // ],
        // actions: [
        //   InkWell(
        //     onTap: () {
        //       show_notification_delay();
        //     },
        //     child: Icon(Icons.ac_unit),
        //   ),
        // ],
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
                      "พนักงานช่างติดตั้ง",
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
                  ShowAdminMechanic(idStaff, idBranch),
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
          await _getJob();
        },
        child: ListView(
          children: [
            header(size),
            body_data(size, sizeh),
          ],
        ),
      ),
    );
  }

  //header
  Widget header(size) => Stack(
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
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return AddJobMechanic(idBranch);
                      })).then((value) => _getJob());
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          size: size * 0.1,
                          color: Colors.white,
                        ),
                        Text(
                          "รับงานติดตั้ง",
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
                      // Navigator.of(context).pushReplacement(MaterialPageRoute(
                      //     builder: (context) => History(name_staff)));
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return History(name_staff);
                      })).then((value) => _getJob());
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.checklist_rtl_sharp,
                          size: size * 0.1,
                          color: Colors.white,
                        ),
                        Text(
                          "ประวัติการติดตั้ง",
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
                  Radius.circular(20),
                ),
                color: Colors.white,
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.20,
              child: Image.asset(
                'images/logo_mc.png',
              ),
            ),
          ),
        ],
      );

  // body_data
  Widget body_data(size, sizeh) => Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15),
            child: Row(
              children: [
                Text(
                  "รายการทีดำเนินงานอยู่",
                  style: MyConstant().normalStyle(),
                ),
              ],
            ),
          ),
          if (status_on_off == true) ...[
            for (int i = 0; i < datajob.length; i++) ...[
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: InkWell(
                  onTap: () async {
                    var id_job_head = datajob[i].idJobHead;
                    var time_go = datajob[i].dateGo.toString();
                    var id_staff = idStaff;
                    if (id_staff != null) {
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return detailjob(id_job_head!, id_staff!, time_go);
                      })).then((value) => {
                            getprofile_staff(),
                          });
                    }
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
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'images/icons-h.gif',
                                        height: sizeh * 0.025,
                                        width: sizeh * 0.025,
                                      ),
                                      if (datajob[i].statusJob == "8") ...[
                                        Text(
                                          " : ดำเนินงานอยู่",
                                          style: MyConstant().h2_5greenStyle(),
                                        ),
                                      ] else ...[
                                        Text(
                                          " : ยังไม่ได้รับงาน",
                                          style: MyConstant().h2_5Style(),
                                        ),
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      if (datajob[i].statusData == "1") ...[
                                        Text(
                                          "รอรับงาน",
                                          style: MyConstant().normalStyle(),
                                        ),
                                      ],
                                      if (datajob[i].statusData == "2") ...[
                                        Text(
                                          "จัดเตรียมอุปกรณ์",
                                          style: MyConstant().normalStyle(),
                                        ),
                                      ],
                                      if (datajob[i].statusData == "3") ...[
                                        Text(
                                          "เตรียมการจัดส่ง",
                                          style: MyConstant().normalStyle(),
                                        ),
                                      ],
                                      if (datajob[i].statusData == "4") ...[
                                        Text(
                                          "กำลังจัดส่ง",
                                          style: MyConstant().normalStyle(),
                                        ),
                                      ],
                                      if (datajob[i].statusData == "5") ...[
                                        Text(
                                          "ติดตั้งสินค้า",
                                          style: MyConstant().normalStyle(),
                                        ),
                                      ],
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: sizeh * 0.01,
                                ),
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: Text(
                                //         "เลขบัตรประชาชน : ${datajob[i].idCardUser}",
                                //         style: TextStyle(
                                //           fontFamily: 'Prompt',
                                //           fontSize: 15,
                                //         ),
                                //         overflow: TextOverflow.fade,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // SizedBox(
                                //   height: 2,
                                // ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "ชื่อลูกค้า : ${datajob[i].fullname}",
                                        style: MyConstant().h3Style(),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                // SizedBox(
                                //   height: sizeh * 0.01,
                                // ),
                                Row(
                                  children: [
                                    Text(
                                      "วันที่ : ${datajob[i].datest}",
                                      style: MyConstant().h3Style(),
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
              SizedBox(
                height: 5,
              )
            ]
          ],
        ],
      );
}
