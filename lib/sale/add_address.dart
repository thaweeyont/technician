import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/address_usermodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_progress.dart';
import 'package:http/http.dart' as http;

class Add_address extends StatefulWidget {
  final String? idcard;
  Add_address(this.idcard);
  @override
  _Add_addressState createState() => _Add_addressState();
}

class _Add_addressState extends State<Add_address> {
  TextEditingController name_user_address = TextEditingController();
  TextEditingController user_address = TextEditingController();
  TextEditingController lat_add = TextEditingController();
  TextEditingController lng_add = TextEditingController();
  TextEditingController lanlng_add = TextEditingController();

  TextEditingController edit_name_user_address = TextEditingController();
  TextEditingController edit_user_address = TextEditingController();
  // TextEditingController edit_lat_add = TextEditingController();
  // TextEditingController edit_lng_add = TextEditingController();
  TextEditingController edit_lanlng_add = TextEditingController();

  TextEditingController lanlng = TextEditingController();
  double? lat, lng, lat_a, lng_a, edit_lat_a, edit_lng_a;
  String? edit_lng_add, edit_lat_add;
  String? selectedValue_provinces;
  String? selectedValue_amphures;
  String? selectedValue_districts;
  String? edit_selectedValue_provinces;
  String? edit_selectedValue_amphures;
  String? edit_selectedValue_districts;
  String? value_provinces, value_amphures, value_districts;
  List provinces_list = [];
  List amphures_list = [];
  List districts_list = [];
  var mk, show_log_address, check_null_address = 0, status_delete = 0, active;
  String? setaddress;
  Completer<GoogleMapController> _controller = Completer();
  List<AddressUser> address_user = [];

  @override
  void initState() {
    super.initState();
    CheckPermission();
    get_provinces();
    // _get_addressuser(widget.idcard);
  }

  //api ข้อมูลจังหวัด
  Future get_provinces() async {
    var respose = await http
        .get(Uri.http(ipconfig, '/flutter_api/api_staff/get_provinces.php'));
    if (respose.statusCode == 200) {
      var jsonData_provinces = jsonDecode(respose.body);
      setState(() {
        provinces_list = jsonData_provinces;
      });
    }
  }

  //api ข้อมูลอำเภอ
  Future get_amphures(provinces_id) async {
    var respose = await http.get(Uri.http(
        ipconfig,
        '/flutter_api/api_staff/get_amphures.php',
        {"province_id": provinces_id}));
    if (respose.statusCode == 200) {
      var jsonData_amphures = jsonDecode(respose.body);
      setState(() {
        amphures_list = jsonData_amphures;
      });
    }
  }

  //api ข้อมูลตำบล
  Future get_districts(amphure_id) async {
    var respose = await http.get(Uri.http(
        ipconfig,
        '/flutter_api/api_staff/get_districts.php',
        {"amphure_id": amphure_id}));
    if (respose.statusCode == 200) {
      var jsonData_districts = jsonDecode(respose.body);
      setState(() {
        districts_list = jsonData_districts;
      });
    }
  }

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
      lat_a = position.latitude;
      lng_a = position.longitude;

      print('lat = $lat, lng = $lng');

      lanlng_add.text = "$lat,$lng";
    });
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

  //เรียกใช้ api เพิ่มที่อยู่
  Future add_address() async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/add_user_address.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id_card_user'] = widget.idcard!;
    request.fields['name_user_address'] = name_user_address.text;
    request.fields['address_user'] = user_address.text;
    request.fields['provinces'] = selectedValue_provinces!;
    request.fields['amphures'] = selectedValue_amphures!;
    request.fields['districts'] = selectedValue_districts!;
    request.fields['lat'] = '19.872728055076823';
    request.fields['lng'] = '99.82792486694699';
    // request.fields['lat'] = lat_a.toString();
    // request.fields['lng'] = lng_a.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      print("เพิ่มข้อมูลสำเร็จ");
      Navigator.pop(context);
    } else {
      print("ไม่สำเร็จ");
    }
  }

  //focus lat/lng
  Future foucus_mark(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
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
        elevation: 0,
        title: Text(
          "เพิ่มสถานที่ติดตั้ง ",
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
      body: Container(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: StatefulBuilder(
            builder: (context, setState) => Container(
              // alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: SingleChildScrollView(
                // physics: const BouncingScrollPhysics(
                //     parent: AlwaysScrollableScrollPhysics()),
                // padding: EdgeInsets.only(
                //     bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            // SizedBox(height: sizeh * 0.01),
                            title_page(),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 30.0, right: 30.0, top: 5),
                              child: Column(
                                children: [
                                  name_address(size),
                                  number_address(),
                                  SizedBox(height: 5),
                                  provinces(),
                                  amphures(),
                                  districts(),
                                ],
                              ),
                            ),
                            // SizedBox(height: 5),
                            // title_map(),
                            // text_field_lat_lng(),
                            // show_map(sizeh),
                            SizedBox(height: 5),
                            submit_button(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget title_page() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("เพิ่มสถานที่ติดตั้งสินค้า", style: MyConstant().h2_5Style()),
          ],
        ),
      );

  Widget name_address(size) => Container(
        height: size * 0.2,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                style: MyConstant().h3Style(),
                controller: name_user_address,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.home),
                  labelText: "ชื่อสถานที่",
                  labelStyle: MyConstant().normalStyle(),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );

  Widget provinces() => Row(
        children: [
          Text(
            "จังหวัด : ",
            style: MyConstant().h3Style(),
          ),
          Container(
            child: DropdownButton<String>(
              icon: Icon(Icons.arrow_drop_down),
              value: selectedValue_provinces,
              hint: Text(
                "เลือกจังหวัด",
                style: MyConstant().normalStyle(),
              ),
              iconSize: 24,
              elevation: 16,
              style: MyConstant().h3Style(),
              underline: SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  amphures_list = [];
                  selectedValue_amphures = null;
                  districts_list = [];
                  selectedValue_districts = null;
                  get_amphures(newValue);
                }
                setState(() {
                  selectedValue_provinces = newValue!;
                });
              },
              items: provinces_list.map((provinces) {
                return DropdownMenuItem<String>(
                  value: provinces['id'].toString(),
                  child: Text(provinces['name_th']),
                );
              }).toList(),
            ),
          ),
        ],
      );

  Widget amphures() => Container(
        child: Row(
          children: [
            Text(
              "อำเภอ : ",
              style: MyConstant().h3Style(),
            ),
            Container(
              child: DropdownButton<String>(
                hint: Text(
                  "เลือกอำเภอ",
                  style: MyConstant().normalStyle(),
                ),
                value: selectedValue_amphures,
                // icon: const Icon(
                //     Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: MyConstant().h3Style(),
                underline: SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    districts_list = [];
                    selectedValue_districts = null;
                    get_districts(newValue);
                  }
                  setState(() {
                    selectedValue_amphures = newValue;
                  });
                },
                items: amphures_list.isEmpty
                    ? []
                    : amphures_list.map((amphures) {
                        return DropdownMenuItem<String>(
                          value: amphures['id'].toString(),
                          child: Text(amphures['name_th']),
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      );

  Widget districts() => Container(
        child: Row(
          children: [
            Text(
              "ตำบล : ",
              style: MyConstant().h3Style(),
            ),
            Container(
              child: DropdownButton<String>(
                hint: Text(
                  "เลือกตำบล",
                  style: MyConstant().normalStyle(),
                ),
                value: selectedValue_districts,
                iconSize: 24,
                elevation: 16,
                style: MyConstant().h3Style(),
                underline: SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // get_amphures(newValue);
                    setState(() {
                      selectedValue_districts = newValue;
                    });
                  }
                },
                items: districts_list.isEmpty
                    ? []
                    : districts_list.map((districts) {
                        return DropdownMenuItem<String>(
                          value: districts['id'].toString(),
                          child: Text(districts['name_th']),
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      );

  Widget number_address() => Row(
        children: [
          Expanded(
            child: Container(
              height: 90,
              child: TextFormField(
                style: MyConstant().h3Style(),
                minLines: 2,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: user_address,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                    child: Icon(Icons.add_location_alt_outlined),
                  ),
                  hintText: "บ้านเลขที่/หมู่บ้าน",
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

  Widget title_map() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "แผนที่ตั้ง",
              style: MyConstant().h2_5Style(),
            ),
          ],
        ),
      );

  Widget text_field_lat_lng() => Container(
        // height: size * 0.2,
        padding: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 5),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: MyConstant().normalStyle(),
                    controller: lanlng_add,
                    // keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map_outlined),
                      // labelText: "lat,lng",
                      // labelStyle:
                      //     TextStyle(fontFamily: 'Prompt'),
                      // border: OutlineInputBorder(
                      //   borderRadius:
                      //       const BorderRadius.all(
                      //     const Radius.circular(10.0),
                      //   ),
                      // ),
                    ),
                    onChanged: (String keyword) {
                      // print("Test");
                      List<String> test_add = keyword.split(",");
                      setState(() {
                        lat_a = double.parse(test_add[0]);
                        lng_a = double.parse(test_add[1]);
                      });
                      foucus_mark(lat_a!, lng_a!);
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      );

  Widget show_map(sizeh) => Container(
        // padding: EdgeInsets.only(
        //   left: 10,
        //   right: 10,
        // ),
        height: sizeh * 0.40,
        // color: Colors.amber,
        width: double.infinity,
        child: lat == null
            ? ShowProgress()
            : GoogleMap(
                myLocationEnabled: true,
                // mapType: MapType.hybrid,
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat_a!, lng_a!),
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
                    position: LatLng(lat_a!, lng_a!),
                    infoWindow:
                        InfoWindow(title: 'สถานที่ติดตั้ง', snippet: '!'),
                  ),
                ].toSet(),
                onTap: (argument) {
                  // print("hello");
                  setState(() {
                    lat_a = argument.latitude;
                    lng_a = argument.longitude;

                    //แปลง ค่า lat lng เป็น string ไปแสดงที่ TextField
                    var sp_lat_a = lat_a.toString();
                    List<String> array_sp_a = sp_lat_a.split('');
                    var Rang_array_a = array_sp_a.getRange(0, 11);
                    var Array_to_String_a = StringBuffer();
                    Rang_array_a.forEach((item) {
                      Array_to_String_a.write(item);
                    });

                    var sp_lat_a2 = lng_a.toString();
                    List<String> array_sp_a2 = sp_lat_a2.split('');
                    var Rang_array_a2 = array_sp_a2.getRange(0, 11);
                    var Array_to_String_a2 = StringBuffer();
                    Rang_array_a2.forEach((item) {
                      Array_to_String_a2.write(item);
                    });

                    lanlng_add.text = "$Array_to_String_a,$Array_to_String_a2";
                    // Navigator.pop(context);
                    // foucus_mark(lat_a!, lng_a!);
                  });
                },
              ),
      );

  Widget submit_button() => Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(primary: MyConstant.dark_f),
          label: Text(
            "บันทึก",
            style: MyConstant().normalwhiteStyle(),
          ),
          icon: Icon(Icons.map_outlined),
          onPressed: () {
            if (name_user_address.text.isNotEmpty &&
                user_address.text.isNotEmpty &&
                selectedValue_provinces != null &&
                selectedValue_amphures != null &&
                selectedValue_districts != null) {
              add_address();
              // Navigator.pop(context);
            } else {
              normalDialog(context, 'แจ้งเตือน', 'กรุณากรอกข้อมูลให้ครบถ้วน');
            }
          },
        ),
      );
}
