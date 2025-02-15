import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:technician/ipconfig.dart';
import 'package:technician/models/job_log_addressmodel.dart';
import 'package:technician/models/job_log_history.dart';
import 'package:technician/models/product_job.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_progress.dart';

class jobHistory extends StatefulWidget {
  final String id_staff;
  jobHistory(this.id_staff);
  @override
  _jobHistoryState createState() => _jobHistoryState();
}

class _jobHistoryState extends State<jobHistory> {
  List<JobLogHistory> job_history = [];
  List<ProductJob> productjob = [];
  List<JobLogAddress> address_history = [];
  String? id_staff;
  double? lat, lng;
  final f = new DateFormat('dd/MM/yyyy');
  // var show = 0;
  Completer<GoogleMapController> _controller = Completer();

  //เรียกใช้ api แสดง สินค้า
  Future<Null> _getProduct(String gen_id_job) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_product_job.php',
          {"gen_id_job": gen_id_job}));
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

  //เรียกใช้ api แสดง งาน
  Future<Null> _get_job_history(String id_staff) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_job_log_history.php',
          {"id_sale": id_staff}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล");
        setState(() {
          job_history = jobLogHistoryFromJson(respose.body);
          var show = 1;
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
      setState(() {
        var show = 0;
      });
    }
  }

  Future<Null> show_dialog_data2(String id) async {
    double size = MediaQuery.of(context).size.width;
    showAnimatedDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int c = 0; c < job_history.length; c++) ...[
                    if (job_history[c].idJobHead == id) ...[
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
                                height: 20.0,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "ข้อมูลลูกค้า",
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 15,
                                        color: Color.fromRGBO(27, 55, 120, 1.0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(Icons.close),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 30.0, right: 30.0, top: 15),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "ชื่อลูกค้า : ${job_history[c].fullname}",
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 15,
                                            color: Color.fromRGBO(
                                                27, 55, 120, 1.0),
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "เบอร์โทร : ${job_history[c].phoneUser}",
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 15,
                                            color: Color.fromRGBO(
                                                27, 55, 120, 1.0),
                                            // fontWeight: FontWeight.bold,
                                          ),
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
                                            "ที่อยู่ : ${job_history[c].addressUser}",
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 15,
                                              color: Color.fromRGBO(
                                                  27, 55, 120, 1.0),
                                              // fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "ข้อมูลสินค้า ",
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 15,
                                        color: Color.fromRGBO(27, 55, 120, 1.0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 25.0,
                                  right: 25.0,
                                ),
                                child: Column(
                                  children: [
                                    // if (show == 1) ...[
                                    for (int x = 0;
                                        x < productjob.length;
                                        x++) ...[
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        elevation: 0,
                                        color: Colors.blue[50],
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "ประเภทสินค้า : ${productjob[x].productType}",
                                                    style: TextStyle(
                                                      fontFamily: 'Prompt',
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          27, 55, 120, 1.0),
                                                    ),
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
                                                    style: TextStyle(
                                                      fontFamily: 'Prompt',
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          27, 55, 120, 1.0),
                                                    ),
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
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 15,
                                                        color: Color.fromRGBO(
                                                            27, 55, 120, 1.0),
                                                      ),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "ประเภทสัญญา : ${productjob[x].productTypeContract}",
                                                    style: TextStyle(
                                                      fontFamily: 'Prompt',
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          27, 55, 120, 1.0),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${productjob[x].productCount} x",
                                                    style: TextStyle(
                                                      fontFamily: 'Prompt',
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          27, 55, 120, 1.0),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    // ] else if (show == 0) ...[
                                    //   ShowProgress()
                                    // ],
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "สถานที่ติดตั้ง ",
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 15,
                                        color: Color.fromRGBO(27, 55, 120, 1.0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 10,
                                ),
                                height: size * 0.65,
                                // color: Colors.amber,
                                width: double.infinity,
                                child: job_history[c].latJob == null
                                    ? ShowProgress()
                                    : GoogleMap(
                                        // myLocationEnabled: true,
                                        // mapType: MapType.hybrid,
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                              double.parse(
                                                  '${job_history[c].latJob}'),
                                              double.parse(
                                                  '${job_history[c].lngJob}')),
                                          zoom: 16,
                                        ),
                                        onMapCreated: (GoogleMapController
                                            controller) async {
                                          _controller.complete(controller);
                                        },
                                        gestureRecognizers: Set()
                                          ..add(Factory<EagerGestureRecognizer>(
                                              () => EagerGestureRecognizer())),
                                        markers: <Marker>[
                                          Marker(
                                            markerId: MarkerId('id'),
                                            position: LatLng(
                                                double.parse(
                                                    '${job_history[c].latJob}'),
                                                double.parse(
                                                    '${job_history[c].lngJob}')),
                                            infoWindow: InfoWindow(
                                                title: 'สถานที่ติดตั้ง',
                                                snippet:
                                                    'Lat = ${job_history[c].latJob} , lng = ${job_history[c].latJob}'),
                                          ),
                                        ].toSet(),
                                      ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      animationType: DialogTransitionType.slideFromBottomFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  Future<Null> show_dialog_data(String id) async {
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            content: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                children: [
                  for (int c = 0; c < job_history.length; c++) ...[
                    if (job_history[c].idJobHead == id) ...[
                      Container(
                        color: Colors.white,
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "ข้อมูลลูกค้า",
                                      style: MyConstant().h2_5Style(),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text("ชื่อลูกค้า : ",
                                            style: MyConstant().normalStyle()),
                                        Expanded(
                                          child: Text(
                                            "${job_history[c].fullname}",
                                            style: MyConstant().h3Style(),
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text("เบอร์โทร : ",
                                            style: MyConstant().normalStyle()),
                                        Text(
                                          "${job_history[c].phoneUser}",
                                          style: MyConstant().h3Style(),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text("ที่อยู่ : ",
                                            style: MyConstant().normalStyle()),
                                        Expanded(
                                          child: Text(
                                            "${job_history[c].addressUser} จ.${job_history[c].nameProvinces} อ.${job_history[c].nameAmphures} ต.${job_history[c].nameDistricts} รหัสไปรษณีย์ ${job_history[c].zipCode}",
                                            style: MyConstant().h3Style(),
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "ข้อมูลสินค้า ",
                                      style: MyConstant().h2_5Style(),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    // if (show == 1) ...[
                                    for (int x = 0;
                                        x < productjob.length;
                                        x++) ...[
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        elevation: 0,
                                        color: Colors.blue[50],
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "ประเภทสินค้า : ${productjob[x].productType}",
                                                    style:
                                                        MyConstant().h3Style(),
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
                                                    style:
                                                        MyConstant().h3Style(),
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
                                                      style: MyConstant()
                                                          .h3Style(),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "ประเภทสัญญา : ${productjob[x].productTypeContract}",
                                                    style:
                                                        MyConstant().h3Style(),
                                                  ),
                                                  Text(
                                                    "${productjob[x].productCount} x",
                                                    style:
                                                        MyConstant().h3Style(),
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
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "สถานที่ติดตั้ง ",
                                      style: MyConstant().h2_5Style(),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  for (var item in address_history) ...[
                                    Expanded(
                                      child: Text(
                                        "ที่อยู่จัดส่ง : ${item.addressDeliver} จ.${item.nameProvinces} อ.${item.nameAmphures} ต.${item.nameDistricts} รหัสไปรษณีย์ ${item.zipCode}",
                                        style: MyConstant().h3Style(),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              // Container(
                              //   height: sizeh * 0.30,
                              //   width: double.infinity,
                              //   child: job_history[c].latJob == null
                              //       ? ShowProgress()
                              //       : GoogleMap(
                              //           initialCameraPosition: CameraPosition(
                              //             target: LatLng(
                              //                 double.parse(
                              //                     '${job_history[c].latJob}'),
                              //                 double.parse(
                              //                     '${job_history[c].lngJob}')),
                              //             zoom: 16,
                              //           ),
                              //           onMapCreated: (GoogleMapController
                              //               controller) async {
                              //             _controller.complete(controller);
                              //           },
                              //           gestureRecognizers: Set()
                              //             ..add(Factory<EagerGestureRecognizer>(
                              //                 () => EagerGestureRecognizer())),
                              //           markers: <Marker>[
                              //             Marker(
                              //               markerId: MarkerId('id'),
                              //               position: LatLng(
                              //                   double.parse(
                              //                       '${job_history[c].latJob}'),
                              //                   double.parse(
                              //                       '${job_history[c].lngJob}')),
                              //               infoWindow: InfoWindow(
                              //                   title: 'สถานที่ติดตั้ง',
                              //                   snippet:
                              //                       'Lat = ${job_history[c].latJob} , lng = ${job_history[c].latJob}'),
                              //             ),
                              //           ].toSet(),
                              //         ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      animationType: DialogTransitionType.slideFromBottomFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    super.initState();
    _get_job_history(widget.id_staff);
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
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
        backgroundColor: Color.fromRGBO(27, 55, 120, 1.0),
        elevation: 0,
        title: Text("ประวัติการขาย ", style: MyConstant().h2whiteStyle()),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[MyConstant.dark_e, MyConstant.dark_f],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          radius: Radius.circular(30),
          thickness: 6,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                if (job_history.isNotEmpty) ...[
                  for (int i = 0; i < job_history.length; i++) ...[
                    // Container(
                    //   padding: EdgeInsets.only(
                    //     left: 15,
                    //     right: 15,
                    //     // top: 10,
                    //   ),
                    //   child: InkWell(
                    //     onTap: () async {
                    //       // print("${job_history[i].idJobHead}");
                    //       var id = job_history[i].idJobHead;
                    //       await _getProduct(id!);
                    //       await show_dialog_data(id);
                    //     },
                    //     child: Card(
                    //       shape: RoundedRectangleBorder(
                    //         side: BorderSide(
                    //           color: Color.fromRGBO(27, 55, 120, 1.0),
                    //           width: 0.5,
                    //         ),
                    //         borderRadius: BorderRadius.circular(10.0),
                    //       ),
                    //       elevation: 0,
                    //       color: Colors.white,
                    //       child: Container(
                    //         margin: EdgeInsets.all(10),
                    //         child: Column(
                    //           children: [
                    //             // Row(
                    //             //   mainAxisAlignment:
                    //             //       MainAxisAlignment.spaceBetween,
                    //             //   children: [
                    //             //     Row(
                    //             //       children: [
                    //             //         Icon(
                    //             //           Icons.list_alt,
                    //             //           color:
                    //             //               Color.fromRGBO(27, 55, 120, 1.0),
                    //             //         ),
                    //             //         Text(
                    //             //           " : เงิน${job_history[i].productTypeContract}",
                    //             //           style: TextStyle(
                    //             //             fontFamily: 'Prompt',
                    //             //             fontSize: 15,
                    //             //             color: Color.fromRGBO(
                    //             //                 27, 55, 120, 1.0),
                    //             //             fontWeight: FontWeight.bold,
                    //             //           ),
                    //             //         ),
                    //             //       ],
                    //             //     ),
                    //             //   ],
                    //             // ),
                    //             // Container(
                    //             //   padding: EdgeInsets.only(
                    //             //     left: 20,
                    //             //     right: 20,
                    //             //     top: 10,
                    //             //   ),
                    //             //   child: Column(
                    //             //     children: [
                    //             //       SizedBox(
                    //             //         height: 2,
                    //             //       ),
                    //             //       Row(
                    //             //         children: [
                    //             //           Expanded(
                    //             //             child: Text(
                    //             //               "Tracking Number : ${job_history[i].idJobHead}",
                    //             //               style: TextStyle(
                    //             //                 fontFamily: 'Prompt',
                    //             //                 fontSize: 15,
                    //             //               ),
                    //             //               overflow: TextOverflow.fade,
                    //             //             ),
                    //             //           ),
                    //             //         ],
                    //             //       ),
                    //             //       SizedBox(
                    //             //         height: 2,
                    //             //       ),
                    //             //       Row(
                    //             //         children: [
                    //             //           Expanded(
                    //             //             child: Text(
                    //             //               "ชื่อลูกค้า : ${job_history[i].fullname}",
                    //             //               style: TextStyle(
                    //             //                 fontFamily: 'Prompt',
                    //             //                 fontSize: 15,
                    //             //               ),
                    //             //               overflow: TextOverflow.fade,
                    //             //             ),
                    //             //           ),
                    //             //         ],
                    //             //       ),
                    //             //       SizedBox(
                    //             //         height: 2,
                    //             //       ),
                    //             //       Row(
                    //             //         children: [
                    //             //           Text(
                    //             //             "${job_history[i].cratedDate}",
                    //             //             style: TextStyle(
                    //             //               fontFamily: 'Prompt',
                    //             //               fontSize: 14,
                    //             //             ),
                    //             //           ),
                    //             //         ],
                    //             //       ),
                    //             //     ],
                    //             //   ),
                    //             // )
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        left: 15,
                        right: 15,
                      ),
                      child: InkWell(
                        onTap: () async {
                          var id = job_history[i].idJobHead;
                          await _getProduct(id!);
                          await _getAddress(id);
                          await show_dialog_data(id);
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.history,
                                                    size: size * 0.06,
                                                    color: Color.fromRGBO(
                                                        27, 55, 120, 1.0),
                                                  ),
                                                  Text(
                                                    " เงิน${job_history[i].productTypeContract} ",
                                                    style: MyConstant()
                                                        .h2_5Style(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      f.format(DateTime.parse(
                                                          job_history[i]
                                                              .cratedDate
                                                              .toString())),
                                                      style: MyConstant()
                                                          .normalStyle(),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ))
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "ชื่อลูกค้า: ",
                                                    style: MyConstant()
                                                        .normalStyle(),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      "${job_history[i].fullname}",
                                                      style: MyConstant()
                                                          .h3Style(),
                                                      overflow:
                                                          TextOverflow.fade,
                                                      softWrap: false,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Tracking Number : ",
                                                    style: MyConstant()
                                                        .normalStyle(),
                                                  ),
                                                  Text(
                                                    "${job_history[i].idJobHead}",
                                                    style:
                                                        MyConstant().h3Style(),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
