
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/mechanic/homt.dart';
import 'package:http/http.dart' as http;
import 'package:technician/ipconfig.dart';
import 'package:technician/models/detail_product_mechanicmodel.dart';
import 'package:technician/models/history_end_jobmodel.dart';
import 'package:technician/models/image_install_endmodel.dart';
import 'package:technician/models/job_log_addressmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_progress.dart';
import 'package:transparent_image/transparent_image.dart';

class History extends StatefulWidget {
  final namestaff;
  History(this.namestaff);
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool load = true;

  bool? haveData;
  var idStaff;
  var count = 0;
  var date_time;
  List<HistoryendModel> data_user = [];
  List<DetailProductMechanicmodel> data_product = [];
  List<ImageInstallEnd> data_img = [];
  List<JobLogAddress> address_history = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_id_staff();
    _getdatahistory();
  }

  //แสดงรายละเอียดข้อมูล
  void show_detail(String lat, String lng, String id_gen_job) async {
    double size = MediaQuery.of(context).size.width;
    showAnimatedDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => SafeArea(
        child: GestureDetector(
          child: StatefulBuilder(
            builder: (context, setState) => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: Scrollbar(
                radius: Radius.circular(30),
                thickness: 6,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 0,
                      color: Colors.white,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: data_product.isEmpty
                            ? Container(
                                child: ShowProgress(),
                              )
                            : Column(
                                children: [
                                  SizedBox(
                                    height: size * 0.03,
                                  ),
                                  //ภาพการติดตั้ง
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                      bottom: 15,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("ภาพการติดตั้ง",
                                            style: MyConstant().h2_5Style()),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    height: MediaQuery.of(context).size.height *
                                        0.20,
                                    child: ListView(
                                      physics: const BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics()),
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        for (var item in data_img) ...[
                                          if (item.imageInstall1
                                              .toString()
                                              .isNotEmpty) ...[
                                            InkWell(
                                              onTap: () => zoom_img(id_gen_job,
                                                  item.imageInstall1!),
                                              child: FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image:
                                                    'http://110.164.131.46//flutter_api/Img_end_install/$id_gen_job/${item.imageInstall1}',
                                                // width: 150,
                                                // height: 150,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                          if (item.imageInstall2
                                              .toString()
                                              .isNotEmpty) ...[
                                            InkWell(
                                              onTap: () => zoom_img(id_gen_job,
                                                  item.imageInstall2!),
                                              child: FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image:
                                                    'http://110.164.131.46//flutter_api/Img_end_install/$id_gen_job/${item.imageInstall2}',
                                                // width: 150,
                                                // height: 150,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                          if (item.imageInstall3
                                              .toString()
                                              .isNotEmpty) ...[
                                            InkWell(
                                              onTap: () => zoom_img(id_gen_job,
                                                  item.imageInstall3!),
                                              child: FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image:
                                                    'http://110.164.131.46//flutter_api/Img_end_install/$id_gen_job/${item.imageInstall3}',
                                                // width: 150,
                                                // height: 150,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                          if (item.imageInstall4
                                              .toString()
                                              .isNotEmpty) ...[
                                            InkWell(
                                              onTap: () => zoom_img(id_gen_job,
                                                  item.imageInstall4!),
                                              child: FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image:
                                                    'http://110.164.131.46//flutter_api/Img_end_install/$id_gen_job/${item.imageInstall4}',
                                                // width: 150,
                                                // height: 150,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                          if (item.imageReceipt1
                                              .toString()
                                              .isNotEmpty) ...[
                                            InkWell(
                                              onTap: () => zoom_img(id_gen_job,
                                                  item.imageReceipt1!),
                                              child: FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image:
                                                    'http://110.164.131.46//flutter_api/Img_end_install/$id_gen_job/${item.imageReceipt1}',
                                                // width: 150,
                                                // height: 150,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                          if (item.imageReceipt2
                                              .toString()
                                              .isNotEmpty) ...[
                                            InkWell(
                                              onTap: () => zoom_img(id_gen_job,
                                                  item.imageReceipt2!),
                                              child: FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image:
                                                    'http://110.164.131.46//flutter_api/Img_end_install/$id_gen_job/${item.imageReceipt2}',
                                                // width: 150,
                                                // height: 150,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  //แสดงข้อมูลสินค้า
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 10.0,
                                        bottom: 10.0),
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.shopping_cart_rounded,
                                                    color: Color.fromRGBO(
                                                        27, 55, 120, 1.0),
                                                    size: size * 0.06,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text("ข้อมูลสินค้า",
                                                      style: MyConstant()
                                                          .h2_5Style()),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (var item
                                                  in data_product) ...[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 35.0,
                                                          bottom: 10.0),
                                                  child: Row(
                                                    children: [
                                                      Text("หมายเลขเครื่อง  ",
                                                          style: MyConstant()
                                                              .normalStyle()),
                                                      Flexible(
                                                        child: Text(
                                                          "${item.machineCode}",
                                                          style: MyConstant()
                                                              .h3Style(),
                                                          softWrap: false,
                                                          overflow:
                                                              TextOverflow.fade,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 35.0,
                                                          bottom: 10.0),
                                                  child: Row(
                                                    children: [
                                                      Text("ประเภทสินค้า  ",
                                                          style: MyConstant()
                                                              .normalStyle()),
                                                      Text(
                                                        "${item.productType}",
                                                        style: MyConstant()
                                                            .h3Style(),
                                                        overflow:
                                                            TextOverflow.fade,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 35.0,
                                                          bottom: 10.0),
                                                  child: Row(
                                                    children: [
                                                      Text("แบรนด์สินค้า  ",
                                                          style: MyConstant()
                                                              .normalStyle()),
                                                      Text(
                                                        "${item.productBrand}",
                                                        style: MyConstant()
                                                            .h3Style(),
                                                        overflow:
                                                            TextOverflow.fade,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 35.0,
                                                          bottom: 10.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "ข้อมูลสินค้า",
                                                            style: MyConstant()
                                                                .normalStyle(),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              "${item.productDetail}",
                                                              style: MyConstant()
                                                                  .h3Style(),
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 35.0,
                                                          bottom: 10.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "ประเภทสัญญา  ",
                                                                style: MyConstant()
                                                                    .normalStyle(),
                                                              ),
                                                              Text(
                                                                "เงิน${item.productTypeContract}",
                                                                style: MyConstant()
                                                                    .h3Style(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 8.0,
                                                      right: 8.0,
                                                    ),
                                                    child: new Divider()),
                                              ],
                                              //-------------------
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //แสดงแผนที่ติดตั้ง
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                    ),
                                    child: Row(
                                      children: [
                                        Text("สถานที่ติดตั้ง",
                                            style: MyConstant().h2_5Style()),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
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
                                  ),
                                  // Container(
                                  //   padding: EdgeInsets.only(
                                  //     left: 15,
                                  //     right: 15,
                                  //     bottom: 15,
                                  //   ),
                                  //   height: MediaQuery.of(context).size.height *
                                  //       0.25,
                                  //   width: double.infinity,
                                  //   child: lat == null
                                  //       ? ShowProgress()
                                  //       : GoogleMap(
                                  //           // myLocationEnabled: true,
                                  //           mapType: MapType.normal,
                                  //           initialCameraPosition:
                                  //               CameraPosition(
                                  //             target: LatLng(
                                  //                 double.parse('$lat'),
                                  //                 double.parse('$lng')),
                                  //             zoom: 18,
                                  //           ),
                                  //           onMapCreated: (controller) async {},
                                  //           gestureRecognizers: Set()
                                  //             ..add(Factory<
                                  //                     EagerGestureRecognizer>(
                                  //                 () =>
                                  //                     EagerGestureRecognizer())),
                                  //           markers: <Marker>[
                                  //             Marker(
                                  //               markerId: MarkerId('id'),
                                  //               position: LatLng(
                                  //                   double.parse('$lat'),
                                  //                   double.parse('$lng')),
                                  //               infoWindow: InfoWindow(
                                  //                 title: 'สถานที่ติดตั้ง',
                                  //                 // snippet: 'Lat = $lat , lng = $lng',
                                  //               ),
                                  //             ),
                                  //           ].toSet(),
                                  //           onTap: (argument) {},
                                  //         ),
                                  // ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
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

  //แสดงข้อมูลสินค้า
  void getdataproduct(String id_gen_job, String lat, String lng, String datego,
      String iddata) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig, '/flutter_api/api_staff/detail_product_mechanic.php', {
        "id_gen_job": id_gen_job,
        "id_staff": idStaff,
        "date_time": datego,
      }));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล1");
        setState(() {
          data_product = detailProductMechanicmodelFromJson(respose.body);
        });
        getdataimage(id_gen_job, idStaff, lat, lng, iddata);
      }
    } catch (e) {
      print("ไม่มีข้อมูล1");
    }
  }

  //แสดงข้อมูลสินค้า
  void getdataimage(String id_gen_job, String idstaff, String lat, String lng,
      String iddata) async {
    print("iddata==>$iddata ,id_gen_job==>$id_gen_job ,idstaff==>$idstaff");
    try {
      var respose = await http.get(Uri.http(
          ipconfig, '/flutter_api/api_staff/show_image_install_end.php', {
        "id_gen_job": id_gen_job,
        "id_staff": idstaff,
        "iddata": iddata,
      }));
      print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล2");
        if (imageInstallEndFromJson(respose.body).isNotEmpty) {
          setState(() {
            data_img = imageInstallEndFromJson(respose.body);
          });
          Navigator.pop(context);
          show_detail(lat, lng, id_gen_job);
        }
      }
    } catch (e) {
      print("ไม่มีข้อมูล2");
    }
  }

  //ขยายภาพ
  Future<Null> zoom_img(String id_gen_job, String name_img) async {
    double size = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        children: [
          Column(
            children: [
              FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image:
                    'http://110.164.131.46//flutter_api/Img_end_install/$id_gen_job/$name_img',
                // width: 150,
                // height: 150,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // get_data
  Future<String> get_id_staff() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idStaff = preferences.getString('idStaff');
    });
    return idStaff;
  }

  //function select data
  Future<void> _getdatahistory() async {
    var id_mec = await get_id_staff();
    String api_get_history =
        'http://$ipconfig/flutter_api/api_staff/get_history_mec.php?id_staff=$id_mec';
    await Dio().get(api_get_history).then(
      (value) {
        if (value.toString() == "null") {
          setState(() {
            haveData = false;
            load = false;
          });
        } else {
          data_user = historyendModelFromJson(value.toString());
          setState(() {
            load = false;
            haveData = true;
          });
        }
      },
    );
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
        backgroundColor: Color.fromRGBO(27, 55, 120, 1.0),
        elevation: 0,
        title: Text("ประวัติงาน", style: MyConstant().h2whiteStyle()),
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
      // drawer: Drawer(
      //   child: Container(
      //     child: Stack(
      //       children: [
      //         ShowSignOut(),
      //         Column(
      //           children: [
      //             UserAccountsDrawerHeader(
      //               accountName: Text(
      //                 "${widget.namestaff}",
      //                 style: TextStyle(
      //                   fontFamily: 'Prompt',
      //                   fontSize: ResponsiveFlutter.of(context).fontSize(2.3),
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //               accountEmail: Text(
      //                 "พนักงานช่างติดตั้ง",
      //                 style: TextStyle(
      //                   fontFamily: 'Prompt',
      //                   fontSize: ResponsiveFlutter.of(context).fontSize(1.7),
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //               currentAccountPicture: ClipRRect(
      //                 borderRadius: BorderRadius.circular(110),
      //                 child: Icon(
      //                   Icons.account_circle,
      //                   color: Colors.white,
      //                   size: sizeh * 0.07,
      //                 ),
      //               ),
      //               decoration: BoxDecoration(
      //                 gradient: LinearGradient(
      //                     colors: [
      //                       const Color.fromRGBO(27, 55, 120, 1.0),
      //                       const Color.fromRGBO(62, 105, 201, 1),
      //                     ],
      //                     begin: Alignment.topCenter,
      //                     end: Alignment.bottomCenter,
      //                     stops: [0.0, 1.0],
      //                     tileMode: TileMode.clamp),
      //                 borderRadius: BorderRadius.only(
      //                   bottomLeft: Radius.circular(15),
      //                   bottomRight: Radius.circular(15),
      //                 ),
      //               ),
      //             ),
      //             ShowVersion(),
      //             new Divider(
      //               height: 0,
      //             ),
      //             ShowProfile(idStaff),
      //             new Divider(
      //               height: 0,
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: Column(
        children: [
          // header(size),
          Expanded(
            child: SafeArea(
              child: Scrollbar(
                radius: Radius.circular(30),
                thickness: 6,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  reverse: false,
                  child: load
                      ? Container(
                          height: size * 0.90,
                          child: ShowProgress(),
                        )
                      : haveData!
                          ? Column(
                              children: [
                                body_data(size),
                              ],
                            )
                          : Container(
                              height: size * 0.90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "ไม่มีข้อมูล",
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Home()));
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_shipping_rounded,
                              size: size * 0.1,
                              color: Colors.white,
                            ),
                            // Image.asset(
                            //   'images/truck.png',
                            //   height: MediaQuery.of(context).size.width * 0.10,
                            //   width: MediaQuery.of(context).size.width * 0.10,
                            // ),
                            Text(
                              "รับงานติดตั้ง",
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        onTap: () async {},
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
                              "ประวัติการติดตั้ง",
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 35, right: 35, top: 55),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ประวัติงาน",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Prompt',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "จำนวน : ${data_user.length}",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Prompt',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget body_data(size) => Container(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          for (var item in data_user) ...[
            // InkWell(
            //   onTap: () async {
            //     showProgressDialog(context);
            //     getdataproduct(
            //         item.idJobHead.toString(),
            //         item.latJob.toString(),
            //         item.lngJob.toString(),
            //         item.dateGo.toString(),
            //         item.idData.toString());
            //   },
            //   child: Card(
            //     shape: RoundedRectangleBorder(
            //       side: BorderSide(
            //         color: Color.fromRGBO(27, 55, 120, 1.0),
            //         width: 0.5,
            //       ),
            //       borderRadius: BorderRadius.circular(10.0),
            //     ),
            //     elevation: 0,
            //     color: Colors.white,
            //     child: Container(
            //       margin: EdgeInsets.all(10),
            //       child: Column(
            //         children: [
            //           Container(
            //             padding: EdgeInsets.only(
            //               left: 20,
            //               right: 20,
            //               top: 10,
            //             ),
            //             child: Column(
            //               children: [
            //                 Row(
            //                   children: [
            //                     Expanded(
            //                       child: Text(
            //                         "ชื่อ-นามสกุลลูกค้า : ${item.fullname}",
            //                         style: TextStyle(
            //                           fontFamily: 'Prompt',
            //                           fontSize: 14,
            //                           color: Colors.grey[800],
            //                         ),
            //                         overflow: TextOverflow.ellipsis,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //                 SizedBox(
            //                   height: 5,
            //                 ),
            //                 Row(
            //                   children: [
            //                     Expanded(
            //                       child: Text(
            //                         "สถานที่ติดตั้ง : ${item.addressDeliver}",
            //                         style: TextStyle(
            //                           fontFamily: 'Prompt',
            //                           fontSize: 14,
            //                           color: Colors.grey[800],
            //                         ),
            //                         overflow: TextOverflow.fade,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //                 SizedBox(
            //                   height: 5,
            //                 ),
            //                 Row(
            //                   children: [
            //                     Text(
            //                       "วันที่ติดตั้ง : ${DateFormat('d/M/y').format(item.dateGo!)}",
            //                       style: TextStyle(
            //                         fontFamily: 'Prompt',
            //                         fontSize: 14,
            //                         color: Colors.grey[800],
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Container(
              padding: EdgeInsets.only(
                top: 10,
                left: 15,
                right: 15,
              ),
              child: InkWell(
                onTap: () async {
                  showProgressDialog(context);
                  await _getAddress(item.idJobHead.toString());
                  getdataproduct(
                      item.idJobHead.toString(),
                      item.latJob.toString(),
                      item.lngJob.toString(),
                      item.dateGo.toString(),
                      item.idData.toString());
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
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.history,
                                            size: size * 0.06,
                                            color: Color.fromRGBO(
                                                27, 55, 120, 1.0),
                                          ),
                                          Text(" : ทวียนต์",
                                              style: MyConstant().h2_5Style()),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                                "${DateFormat('d/M/y').format(item.dateGo!)}",
                                                style:
                                                    MyConstant().normalStyle()),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "ชื่อลูกค้า: ",
                                            style: MyConstant().normalStyle(),
                                          ),
                                          Flexible(
                                            child: Text(
                                              "${item.fullname}",
                                              style: MyConstant().h3Style(),
                                              overflow: TextOverflow.fade,
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
                                            "สถานที่ติดตั้ง : ",
                                            style: MyConstant().normalStyle(),
                                          ),
                                          Expanded(
                                            child: Text(
                                              "${item.addressDeliver}",
                                              style: MyConstant().h3Style(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
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
          ],
        ]),
      );
}
