import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/detail_mechanicmodel.dart';
import 'package:technician/models/detail_product_mechanicmodel.dart';
import 'package:technician/models/job_log_addressmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;
import 'package:technician/widgets/show_progress.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailMechanic extends StatefulWidget {
  final idjob, idstaff, data_status, date_check, lat_staff, lng_staff, id_data;
  DetailMechanic(this.idjob, this.idstaff, this.data_status, this.date_check,
      this.lat_staff, this.lng_staff, this.id_data);

  @override
  _DetailMechanicState createState() => _DetailMechanicState();
}

class _DetailMechanicState extends State<DetailMechanic> {
  TextEditingController warningchange = TextEditingController();
  List<DetailMechanicmodel> data_user = [];
  List<DetailProductMechanicmodel> data_product = [];
  List<JobLogAddress> address_history = [];
  List id_product = [];
  String? selectedValue_mec, text_mec, id_branch;
  List dropdown_mec = [];
  var id_data;
  var mec_no_check = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdatauser();
    getdataproduct();
    _getAddress();
    _dropdown_mec();
  }

  //แสดงข้อมูลลูกค้า
  void getdatauser() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/detail_mechanic.php',
          {"id_gen_job": widget.idjob}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        // print("มีข้อมูล");
        setState(() {
          data_user = detailMechanicmodelFromJson(respose.body);
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  //แสดงข้อมูลสินค้า
  void getdataproduct() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig, '/flutter_api/api_staff/detail_product_mechanic.php', {
        "id_gen_job": widget.idjob,
        "id_staff": widget.idstaff,
        "date_time": widget.date_check.toString()
      }));
      if (respose.statusCode == 200) {
        // print("มีข้อมูล");
        setState(() {
          data_product = detailProductMechanicmodelFromJson(respose.body);
          id_data = data_product[0].idData;
          for (var i = 0; i < data_product.length; i++) {
            id_product.add(data_product[i].idProduct);
            if (data_product[i].checkMachineCode == null ||
                data_product[i].checkMachineCode == "") {
              mec_no_check = mec_no_check + 1;
            } else {
              mec_no_check = 0;
            }
          }
        });
      }
    } catch (e) {
      print("error=>$e");
    }
  }

  //เรียกใช้ api แสดง สถานที่ติดตั้ง
  void _getAddress() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_job_log_address.php',
          {"gen_id_job": widget.idjob}));
      // print(respose.body);
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

  //เช็คค่าว่างเปลี่ยนช่าง
  void process_change_mechianic() async {
    if (warningchange.text == "") {
      normalDialog(
          context, 'แจ้งเตือน', 'กรุณาระบุสาเหตุที่เปลี่ยนช่างติดตั้ง ?');
    }
    if (selectedValue_mec == "null" || selectedValue_mec == null) {
      normalDialog(context, 'แจ้งเตือน', 'กรุณาเลือกช่างติดตั้ง !!');
    }
    if (warningchange.text != "" &&
        selectedValue_mec != null &&
        selectedValue_mec != "null") {
      apichangeMechanic();
    }
  }

  //api เปลี่ยนช่างติดตั้ง
  Future<Null> apichangeMechanic() async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/insert_log_change_mechanic.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['selectedValue_mec'] = selectedValue_mec!;
    request.fields['warningchange'] = warningchange.text.toString();
    request.fields['id_data'] = widget.id_data;
    request.fields['idjob'] = widget.idjob;
    request.fields['idstaff'] = widget.idstaff;

    var response = await request.send();
    if (response.statusCode == 200) {
      successDialog(context, 'แก้ไขข้อมูล', 'เปลี่ยนช่างติดตั้งเสร็จสิ้น');
      print("อัปเดทข้อมูลสำเร็จ");
    } else {
      print("อัปเดทข้อมูลไม่สำเร็จ");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
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
          title: Text(
            "ข้อมูลงานติดตั้ง",
            style: MyConstant().h2whiteStyle(),
          ),
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
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              children: [
                datauser(size),
                underline(),
                dataproduct(size),
                underline(),
                address_install(),
                underline(),
                mark_mechanic(context),
                underline(),
                if (dropdown_mec != []) ...[dropdown_liststaff(context)],
                input_warning_change_staff(),
                button_change()
              ],
            ),
          ),
        ));
  }

  Container button_change() {
    return Container(
      margin: EdgeInsets.only(left: 40, right: 40, bottom: 15),
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
          'ยืนยันการเปลี่ยนแปลง',
          style: MyConstant().normalwhiteStyle(),
        ),
        onPressed: () {
          process_change_mechianic();
        },
      ),
    );
  }

  Row input_warning_change_staff() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 10.0),
            height: 110,
            child: TextFormField(
              style: MyConstant().h3Style(),
              minLines: 2,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: warningchange,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
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
    );
  }

  Container dropdown_liststaff(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text("เปลี่ยนช่างติดตั้ง", style: MyConstant().h2_5Style())
            ],
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
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
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
                              selectedValue_mec = value.toString();
                            });
                          } else {
                            selectedValue_mec = value.toString();
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
          )
        ],
      ),
    );
  }

  Container mark_mechanic(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
            child: Row(
              children: [
                Text(
                  "ที่อยู่ช่างติดตั้ง",
                  style: MyConstant().h2_5Style(),
                )
              ],
            ),
          ),
          Container(
            height: widget.lat_staff == ""
                ? MediaQuery.of(context).size.height * 0.10
                : MediaQuery.of(context).size.height * 0.40,
            width: double.infinity,
            child: widget.lat_staff == ""
                ? Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ช่างติดตั้งยังไม่ได้รับงาน",
                          style: MyConstant().h2_5Style(),
                        ),
                      ],
                    ),
                  )
                : widget.lat_staff == null
                    ? ShowProgress()
                    : GoogleMap(
                        myLocationEnabled: true,
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(double.parse('${widget.lat_staff}'),
                              double.parse('${widget.lng_staff}')),
                          zoom: 18,
                        ),
                        onMapCreated: (controller) async {},
                        gestureRecognizers: Set()
                          ..add(Factory<EagerGestureRecognizer>(
                              () => EagerGestureRecognizer())),
                        markers: <Marker>[
                          Marker(
                            markerId: MarkerId('ช่าง'),
                            position: LatLng(
                                double.parse('${widget.lat_staff}'),
                                double.parse('${widget.lng_staff}')),
                            infoWindow: InfoWindow(
                              title: 'ช่างติดตั้ง',
                              // snippet: 'Lat = $lat , lng = $lng',
                            ),
                          ),
                        ].toSet(),
                        onTap: (argument) {},
                      ),
          ),
        ],
      ),
    );
  }

  Container address_install() {
    return Container(
      padding:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          for (int i = 0; i < data_user.length; i++) ...[
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          "สถานที่ติดตั้ง",
                          style: MyConstant().h2_5Style(),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
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
                  )
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Container dataproduct(double size) {
    return Container(
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
                  children: [
                    Icon(
                      Icons.shopping_cart_rounded,
                      color: Color.fromRGBO(27, 55, 120, 1.0),
                      size: size * 0.06,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "ข้อมูลสินค้า",
                      style: MyConstant().h2_5Style(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int product = 0;
                    product < data_product.length;
                    product++) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (data_product[product].checkMachineCode ==
                            data_product[product].machineCode) ...[
                          Text(
                            "ยืนยันหมายเลขเครื่องเครื่อง",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 14,
                              color: Colors.green[400],
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ] else ...[
                          Text(
                            "ยังไม่ได้ยืนยันหมายเลขเครื่อง",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 14,
                              color: Colors.red[400],
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
                    child: Row(
                      children: [
                        Text(
                          "รหัสเครื่อง  ",
                          style: MyConstant().normalStyle(),
                        ),
                        Text(
                          "${data_product[product].machineCode}",
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
                          "ประเภทสินค้า  ",
                          style: MyConstant().normalStyle(),
                        ),
                        Text(
                          "${data_product[product].productType}",
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
                          "${data_product[product].productBrand}",
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
                                "${data_product[product].productDetail}",
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
                    padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
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
                                  "เงิน${data_product[product].productTypeContract}",
                                  style: MyConstant().h3Style(),
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                      child: new Divider()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox underline() {
    return SizedBox(
      width: double.infinity,
      height: 10,
      child: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
      ),
    );
  }

  Container datauser(double size) {
    return Container(
      padding:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          for (int i = 0; i < data_user.length; i++) ...[
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          "ข้อมูลลูกค้า",
                          style: MyConstant().h2_5Style(),
                        )
                      ],
                    ),
                  ),
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
                              SizedBox(width: 10),
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
                          "${data_user[i].fullname}",
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
                      SizedBox(width: 10),
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
                            "${data_user[0].addressUser} จ.${data_user[0].nameProvinces} อ.${data_user[0].nameAmphures} ต.${data_user[0].nameDistricts} ${data_user[0].zipCode}",
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
                      SizedBox(width: 10),
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
                            "${data_user[i].phoneUser}",
                            style: MyConstant().h3Style(),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            launch("tel://${data_user[i].phoneUser}");
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 2,
                                  offset: Offset(0, 0), // Shadow position
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.call,
                              color: Colors.green,
                              size: size * 0.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
