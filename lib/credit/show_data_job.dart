import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technician/credit/credit.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/job_log_addressmodel.dart';
import 'package:technician/models/job_log_history.dart';
import 'package:technician/models/product_job.dart';
import 'package:technician/models/show_user_data_job.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_progress.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_flutter/responsive_flutter.dart';

class show_data_job extends StatefulWidget {
  final idjob, idjobgen, idstaff;
  show_data_job(this.idjob, this.idjobgen, this.idstaff);

  @override
  _show_data_jobState createState() => _show_data_jobState();
}

class _show_data_jobState extends State<show_data_job> {
  var show = 0;
  Completer<GoogleMapController> _controller = Completer();
  List<UserDataJob> user_data_job = [];
  List<ProductJob> productjob = [];
  List<JobLogAddress> address_history = [];

  //เรียกใช้ api แสดง งาน
  Future<Null> _get_user_job(String idjob) async {
    try {
      var respose = await http.get(Uri.http(ipconfig,
          '/flutter_api/api_staff/show_user_data_job.php', {"idjob": idjob}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล");
        setState(() {
          user_data_job = userDataJobFromJson(respose.body);
          show = 1;
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  //รับงาน dialog
  Future<Null> receive_job(String name) async {
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
            leading: Image.asset('images/add_checker.gif'),
            title: Text(
              'ลูกค้า : $name',
              style: MyConstant().h2_5Style(),
            ),
            subtitle: Text(
              'ท่านต้องการรับงานใช่หรือไม่ ?',
              style: MyConstant().normalStyle(),
            ),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    showProgressDialog(context);
                    _getreceive_job();
                  },
                  child: Column(
                    children: [
                      Text(
                        "รับงาน",
                        style: MyConstant().h3Style(),
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
                        style: MyConstant().normalredStyle(),
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
      duration: Duration(seconds: 1),
    );
  }

  //เรียกใช้ api แสดง สินค้า
  Future<Null> _getProduct(String idjobgen) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_product_job.php',
          {"gen_id_job": idjobgen}));
      print(respose.body);
      if (respose.statusCode == 200) {
        // print("show");
        setState(() {
          productjob = productJobFromJson(respose.body);
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูลสินค้า");
    }
  }

  // เรียกใช้ api รับงาน
  Future<Null> _getreceive_job() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/getreceive_job.php',
          {"id_job": widget.idjob, "id_staff": widget.idstaff}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Credit()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("รับไม่สำเร็จ");
    }
  }

  //เรียกใช้ api แสดง สถานที่ติดตั้ง
  Future<Null> _getAddress(String gen_id_job) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_job_log_address.php',
          {"gen_id_job": gen_id_job}));
      print(respose.body);
      if (respose.statusCode == 200) {
        // print("show");
        setState(() {
          address_history = jobLogAddressFromJson(respose.body);
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูลสินค้า");
    }
  }

  //แสดงแผนที่
  Future<Null> showmap() async {
    double size = MediaQuery.of(context).size.width;
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(5),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: size * 1.2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: user_data_job[0].latJob == null
                  ? ShowProgress()
                  : GoogleMap(
                      myLocationEnabled: true,
                      // mapType: MapType.hybrid,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            double.parse('${user_data_job[0].latJob}'),
                            double.parse('${user_data_job[0].lngJob}')),
                        zoom: 16,
                      ),
                      onMapCreated: (controller) {},
                      markers: <Marker>[
                        Marker(
                          markerId: MarkerId('id'),
                          position: LatLng(
                              double.parse('${user_data_job[0].latJob}'),
                              double.parse('${user_data_job[0].lngJob}')),
                          infoWindow: InfoWindow(
                              title: 'สถานที่ติดตั้ง',
                              snippet:
                                  'Lat = ${user_data_job[0].latJob} , lng = ${user_data_job[0].latJob}'),
                        ),
                      ].toSet(),
                    ),
            )
          ],
        ),
      ),
      animationType: DialogTransitionType.slideFromBottomFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_user_job(widget.idjob);
    _getProduct(widget.idjobgen);
    _getAddress(widget.idjobgen);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
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
          "รายละเอียดข้อมูล",
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
        ),
      ),
      body: user_data_job.isEmpty
          ? WillPopScope(
              child: Center(child: CircularProgressIndicator()),
              onWillPop: () async {
                return false;
              },
            )
          : Scrollbar(
              radius: Radius.circular(30),
              thickness: 6,
              child: RefreshIndicator(
                onRefresh: () async {
                  _get_user_job(widget.idjob);
                  _getProduct(widget.idjobgen);
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Container(
                    child: Container(
                      child: Column(
                        children: [
                          title_data_user(size, sizeh),
                          data_user(size, sizeh),
                          SizedBox(
                            width: double.infinity,
                            height: sizeh * 0.02,
                            child: const DecoratedBox(
                              decoration:
                                  BoxDecoration(color: Color(0xFFEEEEEE)),
                            ),
                          ),
                          data_product(size, sizeh),
                          SizedBox(
                            width: double.infinity,
                            height: sizeh * 0.02,
                            child: const DecoratedBox(
                              decoration:
                                  BoxDecoration(color: Color(0xFFEEEEEE)),
                            ),
                          ),
                          title_map(size),
                          address_install(),
                          // detail_map(size, sizeh),
                          SizedBox(height: 10),
                          submit_button(size, sizeh),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget title_data_user(size, sizeh) => Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 15, right: 15, top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "ข้อมูลลูกค้า",
              style: MyConstant().h2_5Style(),
            ),
          ],
        ),
      );

  Widget data_user(size, sizeh) => Container(
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Color.fromRGBO(27, 55, 120, 1.0),
                                size: size * 0.06,
                              ),
                              SizedBox(width: size * 0.03),
                              Text(
                                "ชื่อผู้รับสินค้า",
                                style: MyConstant().normalStyle(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Row(
                      children: [
                        Text(
                          "${user_data_job[0].fullname}",
                          style: MyConstant().h3Style(),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pin_drop,
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        size: size * 0.06,
                      ),
                      SizedBox(width: size * 0.03),
                      Text(
                        "ที่อยู่",
                        style: MyConstant().normalStyle(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${user_data_job[0].addressUser} จ.${user_data_job[0].nameProvinces} อ.${user_data_job[0].nameAmphures} ต.${user_data_job[0].nameDistricts} ${user_data_job[0].zipCode}",
                            style: MyConstant().h3Style(),
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.call,
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        size: size * 0.06,
                      ),
                      SizedBox(width: size * 0.03),
                      Text(
                        "เบอร์โทรผู้รับสินค้า",
                        style: MyConstant().normalStyle(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${user_data_job[0].phoneUser}",
                            style: MyConstant().h3Style(),
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );

  Widget title_product() => Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "ข้อมูลสินค้า ",
              style: MyConstant().h2_5Style(),
            ),
          ],
        ),
      );

  Widget detail_product() => Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 15.0),
        child: Column(
          children: [
            for (int x = 0; x < productjob.length; x++) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                elevation: 0,
                color: Colors.blue[50],
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ประเภทสินค้า : ${productjob[x].productType}",
                            style: MyConstant().normalStyle(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            "แบรนด์สินค้า : ${productjob[x].productBrand}",
                            style: MyConstant().h3Style(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "ข้อมูลสินค้า : ${productjob[x].productDetail}",
                              style: MyConstant().normalStyle(),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ประเภทสัญญา : ${productjob[x].productTypeContract}",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 15,
                              color: Color.fromRGBO(27, 55, 120, 1.0),
                            ),
                          ),
                          Text(
                            "${productjob[x].productCount} x",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 15,
                              color: Color.fromRGBO(27, 55, 120, 1.0),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );

  Widget title_map(size) => Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "สถานที่ติดตั้ง ",
              style: MyConstant().h2_5Style(),
            ),
            InkWell(
              onTap: () {
                // showmap();
              },
              child: Icon(
                Icons.map_outlined,
                color: Color.fromRGBO(27, 55, 120, 1.0),
                size: size * 0.06,
              ),
            )
          ],
        ),
      );

  Widget detail_map(size, sizeh) => Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          // top: 10,
        ),
        height: sizeh * 0.40,
        // color: Colors.amber,
        width: double.infinity,
        child: user_data_job[0].latJob == null
            ? ShowProgress()
            : GoogleMap(
                // myLocationEnabled: true,
                // mapType: MapType.hybrid,
                initialCameraPosition: CameraPosition(
                  target: LatLng(double.parse('${user_data_job[0].latJob}'),
                      double.parse('${user_data_job[0].lngJob}')),
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                },
                gestureRecognizers: Set()
                  ..add(Factory<EagerGestureRecognizer>(
                      () => EagerGestureRecognizer())),
                markers: <Marker>[
                  Marker(
                    markerId: MarkerId('id'),
                    position: LatLng(double.parse('${user_data_job[0].latJob}'),
                        double.parse('${user_data_job[0].lngJob}')),
                    infoWindow: InfoWindow(
                        title: 'สถานที่ติดตั้ง',
                        snippet:
                            'Lat = ${user_data_job[0].latJob} , lng = ${user_data_job[0].latJob}'),
                  ),
                ].toSet(),
              ),
      );

  Widget submit_button(size, sizeh) => Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        width: double.infinity,
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
            'รับพิจารณาสัญญา',
            style: MyConstant().normalwhiteStyle(),
          ),
          onPressed: () {
            receive_job("${user_data_job[0].fullname}");
          },
        ),
      );

  Widget data_product(size, sizeh) => Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_rounded,
                            color: MyConstant.dark,
                            size: size * 0.06,
                          ),
                          Text(
                            "  ข้อมูลสินค้า",
                            style: MyConstant().h2_5Style(),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            for (int i = 0; i < productjob.length; i++) ...[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "ประเภทสินค้า  ",
                            style: MyConstant().normalStyle(),
                          ),
                          Text(
                            "${productjob[i].productType}",
                            style: MyConstant().h3Style(),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "แบรนด์สินค้า  ",
                            style: MyConstant().normalStyle(),
                          ),
                          Text(
                            "${productjob[i].productBrand}",
                            style: MyConstant().h3Style(),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "ข้อมูลสินค้า",
                                style: MyConstant().normalStyle(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${productjob[i].productDetail}",
                                  style: MyConstant().h3Style(),
                                  overflow: TextOverflow.fade,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 35.0, right: 35.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "ประเภทสัญญา  ",
                                    style: MyConstant().normalStyle(),
                                  ),
                                  Text(
                                    "เงิน${productjob[i].productTypeContract}",
                                    style: MyConstant().h3Style(),
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "x ${productjob[i].productCount}",
                                style: MyConstant().h3Style(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 10.0),
                        child: new Divider()),
                  ],
                ),
              ),
              SizedBox(
                height: sizeh * 0.01,
              )
            ],
          ],
        ),
      );

  Widget address_install() => Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Row(
          children: [
            for (var item in address_history) ...[
              Expanded(
                child: Text(
                  "ที่อยู่จัดส่ง : ${item.addressDeliver} จ.${item.nameProvinces} อ.${item.nameAmphures} ต.${item.nameDistricts} รหัสไปรษณีย์ ${item.zipCode}",
                  style: MyConstant().normalStyle(),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ],
        ),
      );
}
// receive_job("${user_data_job[0].fullname}");