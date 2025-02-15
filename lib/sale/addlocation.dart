import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/address_usermodel.dart';
import 'package:technician/sale/add_address.dart';
import 'package:technician/sale/edit_address.dart';
import 'package:technician/sale/sale.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_progress.dart';

class Addlocation extends StatefulWidget {
  final String id_gen, idcard, lat_old, lng_old;

  Addlocation(this.id_gen, this.idcard, this.lat_old, this.lng_old);

  @override
  _AddlocationState createState() => _AddlocationState();
}

class _AddlocationState extends State<Addlocation> {
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
  List itemsList = [];
  var mk, show_log_address, check_null_address = 0, status_delete = 0, active;
  String? setaddress;
  Completer<GoogleMapController> _controller = Completer();
  List<AddressUser> address_user = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CheckPermission();
    get_provinces();
    _get_addressuser(widget.idcard);
    if (widget.lat_old != "0") {
      mk = 0;
      if (widget.lat_old.length > 11) {
//แปลง ค่า lat lng เป็น string ไปแสดงที่ TextField
        List<String> array_sp = widget.lat_old.split('');
        var Rang_array = array_sp.getRange(0, 11);
        var Array_to_String = StringBuffer();
        Rang_array.forEach((item) {
          Array_to_String.write(item);
        });

        List<String> array_sp2 = widget.lng_old.split('');
        var Rang_array2 = array_sp2.getRange(0, 11);
        var Array_to_String2 = StringBuffer();
        Rang_array2.forEach((item2) {
          Array_to_String2.write(item2);
        });
        lanlng.text = "$Array_to_String,$Array_to_String2";
      } else {
        lanlng.text = "${widget.lat_old},${widget.lng_old}";
      }

      // setMarker2();
      // foucus_mark2();
    }
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

  Set<Marker> setMarker() => <Marker>[
        Marker(
          markerId: MarkerId('id'),
          position: LatLng(lat!, lng!),
          infoWindow: InfoWindow(
              title: 'คุณอยู่ที่นี้', snippet: 'Lat = $lat , lng = $lng'),
        ),
      ].toSet();

  Set<Marker> setMarker2() => <Marker>[
        Marker(
          markerId: MarkerId('id'),
          position: LatLng(
              double.parse(widget.lat_old), double.parse(widget.lng_old)),
          infoWindow: InfoWindow(
              title: 'คุณอยู่ที่นี้',
              snippet: 'Lat = ${widget.lat_old} , lng = ${widget.lng_old}'),
        ),
      ].toSet();

  Future foucus_mark(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
  }

  Future foucus_mark2() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(double.parse(widget.lat_old), double.parse(widget.lng_old))));
  }

  Future<Null> showmap() async {
    showDialog(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(5),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 650,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: lat == null
                  ? ShowProgress()
                  : GoogleMap(
                      myLocationEnabled: true,
                      // mapType: MapType.hybrid,
                      initialCameraPosition: CameraPosition(
                        target: mk == 0
                            ? LatLng(double.parse(widget.lat_old),
                                double.parse(widget.lng_old))
                            : LatLng(lat!, lng!),
                        zoom: 20,
                      ),
                      onMapCreated: (controller) {},
                      markers: mk == 0 ? setMarker2() : setMarker(),
                      onTap: (argument) {
                        setState(() {
                          mk = 1;
                          lat = argument.latitude;
                          lng = argument.longitude;

                          //แปลง ค่า lat lng เป็น string ไปแสดงที่ TextField
                          var sp_lat = lat.toString();
                          List<String> array_sp = sp_lat.split('');
                          var Rang_array = array_sp.getRange(0, 11);
                          var Array_to_String = StringBuffer();
                          Rang_array.forEach((item) {
                            Array_to_String.write(item);
                          });

                          var sp_lng = lng.toString();
                          List<String> array_sp2 = sp_lng.split('');
                          var Rang_array2 = array_sp2.getRange(0, 11);
                          var Array_to_String2 = StringBuffer();
                          Rang_array2.forEach((item2) {
                            Array_to_String2.write(item2);
                          });

                          lanlng.text = "$Array_to_String,$Array_to_String2";
                          Navigator.pop(context);
                          foucus_mark(lat!, lng!);
                        });
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Future<Null> add_map(BuildContext context) async {
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
    lanlng_add.text = "$lat_a,$lng_a";
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: StatefulBuilder(
            builder: (context, setState) => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
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
                              height: sizeh * 0.01,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "เพิ่มสถานที่ติดตั้งสินค้า",
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 14,
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
                                  left: 30.0, right: 30.0, top: 5),
                              child: Column(
                                children: [
                                  Container(
                                    height: size * 0.2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                            ),
                                            controller: name_user_address,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.home),
                                              labelText: "ชื่อสถานที่",
                                              labelStyle: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "จังหวัด : ",
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 14,
                                          color:
                                              Color.fromRGBO(27, 55, 120, 1.0),
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        child: DropdownButton<String>(
                                          icon: Icon(Icons.arrow_drop_down),
                                          value: selectedValue_provinces,
                                          hint: Text(
                                            "เลือกจังหวัด",
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                            ),
                                          ),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                              color: Colors.black),
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
                                              selectedValue_provinces =
                                                  newValue!;
                                            });
                                          },
                                          items:
                                              provinces_list.map((provinces) {
                                            return DropdownMenuItem<String>(
                                              value: provinces['id'].toString(),
                                              child: Text(provinces['name_th']),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          "อำเภอ : ",
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                27, 55, 120, 1.0),
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          child: DropdownButton<String>(
                                            hint: Text(
                                              "เลือกอำเภอ",
                                              style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                              ),
                                            ),
                                            value: selectedValue_amphures,
                                            // icon: const Icon(
                                            //     Icons.arrow_downward),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                                color: Colors.black),

                                            underline: SizedBox(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                districts_list = [];
                                                selectedValue_districts = null;
                                                get_districts(newValue);
                                              }
                                              setState(() {
                                                selectedValue_amphures =
                                                    newValue;
                                              });
                                            },
                                            items: amphures_list.isEmpty
                                                ? []
                                                : amphures_list.map((amphures) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: amphures['id']
                                                          .toString(),
                                                      child: Text(
                                                          amphures['name_th']),
                                                    );
                                                  }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          "ตำบล : ",
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                27, 55, 120, 1.0),
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          child: DropdownButton<String>(
                                            hint: Text(
                                              "เลือกตำบล",
                                              style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                              ),
                                            ),
                                            value: selectedValue_districts,
                                            // icon: const Icon(
                                            //     Icons.arrow_downward),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                                color: Colors.black),

                                            underline: SizedBox(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                // get_amphures(newValue);
                                                setState(() {
                                                  selectedValue_districts =
                                                      newValue;
                                                });
                                              }
                                            },
                                            items: districts_list.isEmpty
                                                ? []
                                                : districts_list
                                                    .map((districts) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: districts['id']
                                                          .toString(),
                                                      child: Text(
                                                          districts['name_th']),
                                                    );
                                                  }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 90,
                                          child: TextFormField(
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                            ),
                                            minLines: 2,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            controller: user_address,
                                            decoration: InputDecoration(
                                              prefixIcon: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 25),
                                                child: Icon(Icons
                                                    .add_location_alt_outlined),
                                              ),
                                              hintText: "บ้านเลขที่/หมู่บ้าน",
                                              hintStyle: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
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
                                    "แผนที่ตั้ง",
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 14,
                                      color: Color.fromRGBO(27, 55, 120, 1.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              // height: size * 0.2,
                              padding: EdgeInsets.only(
                                  left: 30.0, right: 30.0, bottom: 5),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                          controller: lanlng_add,
                                          // keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            prefixIcon:
                                                Icon(Icons.map_outlined),
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
                                            List<String> test_add =
                                                keyword.split(",");
                                            setState(() {
                                              lat_a = double.parse(test_add[0]);
                                              lng_a = double.parse(test_add[1]);
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              height: sizeh * 0.40,
                              // color: Colors.amber,
                              width: double.infinity,
                              child: GoogleMap(
                                myLocationEnabled: true,
                                // mapType: MapType.hybrid,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(lat_a!, lng_a!),
                                  zoom: 16,
                                ),
                                onMapCreated:
                                    (GoogleMapController controller) async {
                                  _controller.complete(controller);
                                },
                                gestureRecognizers: Set()
                                  ..add(Factory<EagerGestureRecognizer>(
                                      () => EagerGestureRecognizer())),
                                markers: <Marker>[
                                  Marker(
                                    markerId: MarkerId('id'),
                                    position: LatLng(lat_a!, lng_a!),
                                    infoWindow: InfoWindow(
                                        title: 'สถานที่ติดตั้ง', snippet: '!'),
                                  ),
                                ].toSet(),
                                onTap: (argument) {
                                  // print("hello");
                                  setState(() {
                                    lat_a = argument.latitude;
                                    lng_a = argument.longitude;

                                    //แปลง ค่า lat lng เป็น string ไปแสดงที่ TextField
                                    var sp_lat_a = lat_a.toString();
                                    List<String> array_sp_a =
                                        sp_lat_a.split('');
                                    var Rang_array_a =
                                        array_sp_a.getRange(0, 11);
                                    var Array_to_String_a = StringBuffer();
                                    Rang_array_a.forEach((item) {
                                      Array_to_String_a.write(item);
                                    });

                                    var sp_lat_a2 = lng_a.toString();
                                    List<String> array_sp_a2 =
                                        sp_lat_a2.split('');
                                    var Rang_array_a2 =
                                        array_sp_a2.getRange(0, 11);
                                    var Array_to_String_a2 = StringBuffer();
                                    Rang_array_a2.forEach((item) {
                                      Array_to_String_a2.write(item);
                                    });

                                    lanlng_add.text =
                                        "$Array_to_String_a,$Array_to_String_a2";
                                    // Navigator.pop(context);
                                    foucus_mark(lat_a!, lng_a!);
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(91, 117, 178, 1.0),
                                ),
                                label: Text(
                                  "บันทึก",
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 14,
                                  ),
                                ),
                                icon: Icon(Icons.map_outlined),
                                onPressed: () {
                                  if (name_user_address.text.isNotEmpty &&
                                      user_address.text.isNotEmpty &&
                                      selectedValue_provinces != null &&
                                      selectedValue_amphures != null &&
                                      selectedValue_districts != null) {
                                    add_address();
                                    Navigator.pop(context);
                                  } else {
                                    normalDialog(context, 'แจ้งเตือน',
                                        'กรุณากรอกข้อมูลให้ครบถ้วน');
                                  }
                                },
                              ),
                            ),
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
      animationType: DialogTransitionType.slideFromRightFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  Future<Null> edit_map(
      String? idUserAddress,
      String? nameUserAddress,
      String? addressUser,
      String? lat,
      String? lng,
      String? idProvinces,
      String? idAmphures,
      String? idDistricts) async {
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
    lanlng_add.text = "$lat_a,$lng_a";
    edit_name_user_address.text = nameUserAddress!;
    edit_user_address.text = addressUser!;
    edit_lanlng_add.text = "$lat,$lng";
    edit_lat_a = double.parse('$lat');
    edit_lng_a = double.parse('$lng');
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: StatefulBuilder(
            builder: (context, setState) => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
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
                              height: sizeh * 0.01,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "แก้ไขสถานที่ติดตั้งสินค้า",
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 14,
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
                                  left: 30.0, right: 30.0, top: 5),
                              child: Column(
                                children: [
                                  Container(
                                    height: size * 0.2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                            ),
                                            controller: edit_name_user_address,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.home),
                                              labelText: "ชื่อสถานที่",
                                              labelStyle: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "จังหวัด : ",
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 14,
                                          color:
                                              Color.fromRGBO(27, 55, 120, 1.0),
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        child: DropdownButton<String>(
                                          icon: Icon(Icons.arrow_drop_down),
                                          value: edit_selectedValue_provinces,
                                          hint: Text(
                                            "เลือกจังหวัด",
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                            ),
                                          ),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                              color: Colors.black),
                                          underline: SizedBox(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              amphures_list = [];
                                              edit_selectedValue_amphures =
                                                  null;
                                              districts_list = [];
                                              edit_selectedValue_districts =
                                                  null;
                                              get_amphures(newValue);
                                            }
                                            setState(() {
                                              edit_selectedValue_provinces =
                                                  newValue!;
                                            });
                                          },
                                          items:
                                              provinces_list.map((provinces) {
                                            return DropdownMenuItem<String>(
                                              value: provinces['id'].toString(),
                                              child: Text(provinces['name_th']),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          "อำเภอ : ",
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                27, 55, 120, 1.0),
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          child: DropdownButton<String>(
                                            hint: Text(
                                              "เลือกอำเภอ",
                                              style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                              ),
                                            ),
                                            value: edit_selectedValue_amphures,
                                            // icon: const Icon(
                                            //     Icons.arrow_downward),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                                color: Colors.black),

                                            underline: SizedBox(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                districts_list = [];
                                                edit_selectedValue_districts =
                                                    null;
                                                get_districts(newValue);
                                              }
                                              setState(() {
                                                edit_selectedValue_amphures =
                                                    newValue;
                                              });
                                            },
                                            items: amphures_list.isEmpty
                                                ? []
                                                : amphures_list.map((amphures) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: amphures['id']
                                                          .toString(),
                                                      child: Text(
                                                          amphures['name_th']),
                                                    );
                                                  }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          "ตำบล : ",
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                27, 55, 120, 1.0),
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          child: DropdownButton<String>(
                                            hint: Text(
                                              "เลือกตำบล",
                                              style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                              ),
                                            ),
                                            value: edit_selectedValue_districts,
                                            // icon: const Icon(
                                            //     Icons.arrow_downward),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                                color: Colors.black),

                                            underline: SizedBox(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                // get_amphures(newValue);
                                                setState(() {
                                                  edit_selectedValue_districts =
                                                      newValue;
                                                });
                                              }
                                            },
                                            items: districts_list.isEmpty
                                                ? []
                                                : districts_list
                                                    .map((districts) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: districts['id']
                                                          .toString(),
                                                      child: Text(
                                                          districts['name_th']),
                                                    );
                                                  }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 90,
                                          child: TextFormField(
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                            ),
                                            minLines: 2,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            controller: edit_user_address,
                                            decoration: InputDecoration(
                                              prefixIcon: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 25),
                                                child: Icon(Icons
                                                    .add_location_alt_outlined),
                                              ),
                                              hintText: "บ้านเลขที่/หมู่บ้าน",
                                              hintStyle: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
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
                                    "แผนที่ตั้ง",
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 14,
                                      color: Color.fromRGBO(27, 55, 120, 1.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              // height: size * 0.2,
                              padding: EdgeInsets.only(
                                  left: 30.0, right: 30.0, bottom: 5),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                          controller: edit_lanlng_add,
                                          // keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            prefixIcon:
                                                Icon(Icons.map_outlined),
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
                                            List<String> edit_test_add =
                                                keyword.split(",");
                                            setState(() {
                                              edit_lat_a = double.parse(
                                                  edit_test_add[0]);
                                              edit_lng_a = double.parse(
                                                  edit_test_add[1]);
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              height: sizeh * 0.40,
                              // color: Colors.amber,
                              width: double.infinity,
                              child: GoogleMap(
                                myLocationEnabled: true,
                                // mapType: MapType.hybrid,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(double.parse('$edit_lat_a'),
                                      double.parse('$edit_lng_a')),
                                  zoom: 16,
                                ),
                                onMapCreated:
                                    (GoogleMapController controller) async {
                                  _controller.complete(controller);
                                },
                                gestureRecognizers: Set()
                                  ..add(Factory<EagerGestureRecognizer>(
                                      () => EagerGestureRecognizer())),
                                markers: <Marker>[
                                  Marker(
                                    markerId: MarkerId('id'),
                                    position: LatLng(
                                        double.parse('$edit_lat_a'),
                                        double.parse('$edit_lng_a')),
                                    infoWindow: InfoWindow(
                                        title: 'สถานที่ติดตั้ง', snippet: '!'),
                                  ),
                                ].toSet(),
                                onTap: (argument) {
                                  // print("hello");
                                  setState(() {
                                    edit_lat_a = argument.latitude;
                                    edit_lng_a = argument.longitude;

                                    //แปลง ค่า lat lng เป็น string ไปแสดงที่ TextField
                                    var sp_lat_a = edit_lat_a.toString();
                                    List<String> array_sp_a =
                                        sp_lat_a.split('');
                                    var Rang_array_a =
                                        array_sp_a.getRange(0, 11);
                                    var Array_to_String_a = StringBuffer();
                                    Rang_array_a.forEach((item) {
                                      Array_to_String_a.write(item);
                                    });

                                    var sp_lat_a2 = edit_lng_a.toString();
                                    List<String> array_sp_a2 =
                                        sp_lat_a2.split('');
                                    var Rang_array_a2 =
                                        array_sp_a2.getRange(0, 11);
                                    var Array_to_String_a2 = StringBuffer();
                                    Rang_array_a2.forEach((item) {
                                      Array_to_String_a2.write(item);
                                    });

                                    edit_lanlng_add.text =
                                        "$Array_to_String_a,$Array_to_String_a2";
                                    // Navigator.pop(context);
                                    foucus_mark(edit_lat_a!, edit_lng_a!);
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(252, 186, 3, 1.0),
                                ),
                                label: Text(
                                  "แก้ไข",
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 14,
                                  ),
                                ),
                                icon: Icon(Icons.map_outlined),
                                onPressed: () {
                                  if (edit_name_user_address.text.isNotEmpty &&
                                      edit_user_address.text.isNotEmpty &&
                                      edit_selectedValue_provinces != null &&
                                      edit_selectedValue_amphures != null &&
                                      edit_selectedValue_districts != null) {
                                    edit_address(idUserAddress);
                                    Navigator.pop(context);
                                  } else {
                                    normalDialog(context, 'แจ้งเตือน',
                                        'กรุณากรอกข้อมูลให้ครบถ้วน');
                                  }
                                },
                              ),
                            ),
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
      animationType: DialogTransitionType.slideFromRightFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  Future<Null> delete_address(String id, String name_c) async {
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
            leading: Image.asset('images/bin.gif'),
            title: Text(
              '${name_c}',
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
                    _delete_addressuser(id);

                    // await _getProduct(gen_id_job);
                    Navigator.pop(context);
                    // if (status_delete == 1) {
                    //   print("test");

                    //   status_delete = 0;
                    // }
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
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  //เรียกใช้ api เพิ่มข้อมูล
  Future addjob(String status_function) async {
    var uri =
        Uri.parse("http://110.164.131.46/flutter_api/api_staff/add_job.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id_card_user'] = widget.idcard;
    request.fields['status_function'] = status_function;
    request.fields['id_gen'] = widget.id_gen;
    request.fields['address'] = setaddress!;
    request.fields['provinces'] = value_provinces!;
    request.fields['amphures'] = value_amphures!;
    request.fields['districts'] = value_districts!;

    if (mk == 0) {
      request.fields['lat'] = widget.lat_old;
      request.fields['lng'] = widget.lng_old;
    } else {
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Sale()),
        (Route<dynamic> route) => false,
      );
    } else {
      print("ไม่สำเร็จ");
    }
  }

  Future<Null> success_dialog(
      BuildContext context, String title, String message) async {
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
            leading: Image.asset('images/success.png'),
            title: Text(
              title,
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              message,
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14,
              ),
            ),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    showProgressDialog(context);
                    addjob("3");
                  },
                  child: Column(
                    children: [
                      Text(
                        "ตกลง",
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 14,
                        ),
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
                        style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 14,
                            color: Colors.red),
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

  //เรียกใช้ api เพิ่มที่อยู่
  Future add_address() async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/add_user_address.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id_card_user'] = widget.idcard;
    request.fields['name_user_address'] = name_user_address.text;
    request.fields['address_user'] = user_address.text;
    request.fields['provinces'] = selectedValue_provinces!;
    request.fields['amphures'] = selectedValue_amphures!;
    request.fields['districts'] = selectedValue_districts!;
    request.fields['lat'] = lat_a.toString();
    request.fields['lng'] = lng_a.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      print("เพิ่มข้อมูลสำเร็จ");
      _get_addressuser(widget.idcard);
    } else {
      print("ไม่สำเร็จ");
    }
  }

  //เรียกใช้ api แก้ไขที่อยู่
  Future edit_address(idUserAddress) async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/edit_address.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['idUserAddress'] = idUserAddress;
    request.fields['edit_name_user_address'] = edit_name_user_address.text;
    request.fields['edit_user_address'] = edit_user_address.text;
    request.fields['provinces'] = edit_selectedValue_provinces!;
    request.fields['amphures'] = edit_selectedValue_amphures!;
    request.fields['districts'] = edit_selectedValue_districts!;
    request.fields['edit_lat_a'] = edit_lat_a.toString();
    request.fields['edit_lng_a'] = edit_lng_a.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      print("แก้ไขข้อมูลสำเร็จ");
      _get_addressuser(widget.idcard);
    } else {
      print("แก้ไขไม่สำเร็จ");
    }
  }

  //เรียกใช้ api แสดงข้อมูลสถานที่ส่งของที่มี
  Future<Null> _get_addressuser(String idcard) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_address_user.php',
          {"id_card_user": idcard}));
      print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล");
        setState(() {
          address_user = addressUserFromJson(respose.body);
          show_log_address = 1;
          itemsList = List<String>.generate(
              address_user.length, (n) => "List item ${n}");
        });
      }
    } catch (e) {
      setState(() {
        show_log_address = 0;
      });

      print("ไม่มีข้อมูล");
    }
  }

  //เรียกใช้ api ลบข้อมูล สินค้า
  Future<Null> _delete_addressuser(String id) async {
    try {
      var respose = await http.get(Uri.http(ipconfig,
          '/flutter_api/api_staff/delete_addressuser.php', {"id": id}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("ลบข้อมูลสินค้าเสร็จสิ้น");
        _get_addressuser(widget.idcard);
      }
    } catch (e) {
      status_delete = 0;
      print("ลบไม่สำเร็จ");
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
    return RefreshIndicator(
      onRefresh: () async {
        _get_addressuser(widget.idcard);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        resizeToAvoidBottomInset: false,
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
            "บันทึกสถานที่ติดตั้ง ",
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
        body: Column(
          children: [
            btn_addaddress(size),
            if (show_log_address == 1) ...[
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: itemsList.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(""),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            //เมื่อเลือกทางขวา
                            var id_address_u =
                                address_user[index].idUserAddress;
                            var address_u = address_user[index].nameUserAddress;
                            delete_address(id_address_u!, address_u!);
                            // ScaffoldMessenger.of(context)
                            //     .showSnackBar(SnackBar(content: Text('ลบ')));
                          } else {
                            //เมื่อเลือกทางซ้าย
                            Navigator.push(context,
                                CupertinoPageRoute(builder: (context) {
                              return Edit_address(
                                  address_user[index].idUserAddress,
                                  address_user[index].nameUserAddress,
                                  address_user[index].addressUser,
                                  address_user[index].lat,
                                  address_user[index].lng,
                                  address_user[index].idProvinces,
                                  address_user[index].idAmphures,
                                  address_user[index].idDistricts);
                            })).then(
                                (value) => _get_addressuser(widget.idcard));
                          }
                        },
                        // onDismissed: (direction) { //ทำงานเมื่อจบการลบ
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(content: Text(' dismissed')));
                        // },
                        secondaryBackground: slideLeftBackground(),
                        background: slideRightBackground(),
                        child: InkWell(
                          onLongPress: () async {
                            // await get_amphures(address_user[i].idProvinces);
                            // await get_districts(address_user[i].idAmphures);
                            // edit_selectedValue_provinces =
                            //     address_user[i].idProvinces;
                            // edit_selectedValue_amphures = address_user[i].idAmphures;
                            // edit_selectedValue_districts =
                            //     address_user[i].idDistricts;
                            // edit_map(
                            //     address_user[i].idUserAddress,
                            //     address_user[i].nameUserAddress,
                            //     address_user[i].addressUser,
                            //     address_user[i].lat,
                            //     address_user[i].lng,
                            //     address_user[i].idProvinces,
                            //     address_user[i].idAmphures,
                            //     address_user[i].idDistricts);
                          },
                          onTap: () async {
                            setState(() {
                              value_provinces = address_user[index].idProvinces;
                              value_amphures = address_user[index].idAmphures;
                              value_districts = address_user[index].idDistricts;
                              active = address_user[index].idUserAddress;
                              check_null_address = 1;
                              mk = 1;
                              setaddress = address_user[index].addressUser;
                              var change_lat = address_user[index].lat;
                              var change_lng = address_user[index].lng;
                              lat = double.parse(change_lat!);
                              lng = double.parse(change_lng!);
                              lanlng.text = "$lat,$lng";
                              foucus_mark(lat!, lng!);
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Card(
                              color: active == address_user[index].idUserAddress
                                  ? Colors.blue[50]
                                  : Colors.grey[50],
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(5.0),
                              // ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "สถานที่จัดส่ง : ${address_user[index].nameUserAddress}",
                                            style: MyConstant().h3Style(),
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "ที่อยู่ : ${address_user[index].addressUser} จ.${address_user[index].nameProvinces} อ.${address_user[index].nameAmphures} ต.${address_user[index].nameDistricts} ${address_user[index].zipCode}",
                                            style: MyConstant().h3Style(),
                                            overflow: TextOverflow.clip,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            submit_button(),
            SizedBox(height: 10)
          ],
        ),
        // Stack(
        //   children: [
        //     Positioned.fill(
        //       child: google_Map(),
        //     ),
        //     Positioned(
        //       bottom: 0,
        //       left: 0,
        //       right: 0,
        //       child: Container(
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.only(
        //             topLeft: Radius.circular(15),
        //             topRight: Radius.circular(15),
        //           ),
        //           color: Colors.white,
        //         ),
        //         child: Column(
        //           children: [
        //             btn_addaddress(size),
        //             if (show_log_address == 1) ...[
        //               detail_address(size, sizeh),
        //             ],
        //             submit_button(),
        //             SizedBox(height: 10)
        //           ],
        //         ),
        //       ),
        //     )
        //   ],
        // ),
      ),
    );
  }

  Widget google_Map() => Container(
        // padding: EdgeInsets.only(
        //   left: 20,
        //   right: 20,
        //   top: 10,
        // ),
        // height: 400,
        // color: Colors.amber,
        width: double.infinity,
        child: lat == null
            ? ShowProgress()
            : GoogleMap(
                myLocationEnabled: true,
                // mapType: MapType.hybrid,
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat!, lng!),
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                },
                gestureRecognizers: Set()
                  ..add(Factory<EagerGestureRecognizer>(
                      () => EagerGestureRecognizer())),
                markers: mk == 0 ? setMarker2() : setMarker(),
              ),
      );

  Widget submit_button() => Container(
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
            'บันทึกข้อมูล',
            style: MyConstant().normalwhiteStyle(),
          ),
          onPressed: () {
            if (lanlng.text.isEmpty || check_null_address == 0) {
              pinlDialog(context, 'แจ้งเตือน', 'กรุณาเลือกสถานที่ติดตั้ง');
            } else {
              success_dialog(context, 'ยืนยัน', 'ท่านต้องการบันทึกข้อมูล ?');
            }
          },
        ),
      );

  Widget btn_addaddress(size) => Container(
        // color: Colors.white,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: MyConstant.dark,
                    size: size * 0.06,
                  ),
                  Text(
                    " สถานที่ติดตั้งสินค้า",
                    style: MyConstant().h2_5Style(),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  print("dialog add map");
                  // add_map(context);
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (context) {
                    return Add_address("${widget.idcard}");
                  })).then((value) => _get_addressuser(widget.idcard));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: MyConstant.dark,
                      size: size * 0.06,
                    ),
                    Text(
                      "เพิ่ม",
                      style: MyConstant().h2_5Style(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget detail_address(size, sizeh) => Container(
        height: address_user.length > 1 ? sizeh * 0.2 : sizeh * 0.15,
        color: Colors.white,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemCount: itemsList.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(""),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  //เมื่อเลือกทางขวา
                  var id_address_u = address_user[index].idUserAddress;
                  var address_u = address_user[index].nameUserAddress;
                  delete_address(id_address_u!, address_u!);
                  // ScaffoldMessenger.of(context)
                  //     .showSnackBar(SnackBar(content: Text('ลบ')));
                } else {
                  //เมื่อเลือกทางซ้าย
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (context) {
                    return Edit_address(
                        address_user[index].idUserAddress,
                        address_user[index].nameUserAddress,
                        address_user[index].addressUser,
                        address_user[index].lat,
                        address_user[index].lng,
                        address_user[index].idProvinces,
                        address_user[index].idAmphures,
                        address_user[index].idDistricts);
                  })).then((value) => _get_addressuser(widget.idcard));
                }
              },
              // onDismissed: (direction) { //ทำงานเมื่อจบการลบ
              //   ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text(' dismissed')));
              // },
              secondaryBackground: slideLeftBackground(),
              background: slideRightBackground(),
              child: InkWell(
                onLongPress: () async {
                  // await get_amphures(address_user[i].idProvinces);
                  // await get_districts(address_user[i].idAmphures);
                  // edit_selectedValue_provinces =
                  //     address_user[i].idProvinces;
                  // edit_selectedValue_amphures = address_user[i].idAmphures;
                  // edit_selectedValue_districts =
                  //     address_user[i].idDistricts;
                  // edit_map(
                  //     address_user[i].idUserAddress,
                  //     address_user[i].nameUserAddress,
                  //     address_user[i].addressUser,
                  //     address_user[i].lat,
                  //     address_user[i].lng,
                  //     address_user[i].idProvinces,
                  //     address_user[i].idAmphures,
                  //     address_user[i].idDistricts);
                },
                onTap: () async {
                  setState(() {
                    value_provinces = address_user[index].idProvinces;
                    value_amphures = address_user[index].idAmphures;
                    value_districts = address_user[index].idDistricts;
                    active = address_user[index].idUserAddress;
                    check_null_address = 1;
                    mk = 1;
                    setaddress = address_user[index].addressUser;
                    var change_lat = address_user[index].lat;
                    var change_lng = address_user[index].lng;
                    lat = double.parse(change_lat!);
                    lng = double.parse(change_lng!);
                    lanlng.text = "$lat,$lng";
                    foucus_mark(lat!, lng!);
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Card(
                    color: active == address_user[index].idUserAddress
                        ? Colors.blue[50]
                        : Colors.grey[50],
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(5.0),
                    // ),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "สถานที่จัดส่ง : ${address_user[index].nameUserAddress}",
                                  style: MyConstant().h3Style(),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "ที่อยู่ : ${address_user[index].addressUser} จ.${address_user[index].nameProvinces} อ.${address_user[index].nameAmphures} ต.${address_user[index].nameDistricts} ${address_user[index].zipCode}",
                                  style: MyConstant().h3Style(),
                                  overflow: TextOverflow.clip,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

  Widget text_latlng() => Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: lanlng,
                // keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.pin_drop_sharp),
                  labelText: "lat,lng",
                  labelStyle: TextStyle(
                    fontFamily: 'Prompt',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                ),
                onChanged: (String keyword) {
                  List<String> test = keyword.split(",");
                  setState(() {
                    lat = double.parse(test[0]);
                    lng = double.parse(test[1]);
                  });
                },
              ),
            )
          ],
        ),
      );

  Widget slideRightBackground() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 13, top: 5),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          bottomLeft: Radius.circular(5),
        ),
      ),
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " แก้ไข",
              style: MyConstant().normalwhiteStyle(),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 13, top: 5),
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " ลบ",
              style: MyConstant().normalwhiteStyle(),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}

// ListView(
//           physics: const BouncingScrollPhysics(
//               parent: AlwaysScrollableScrollPhysics()),
//           children: [
//             Column(
//               children: [
//                 for (int i = 0; i < address_user.length; i++) ...[
//                   Dismissible(
//                     key: Key(""),
//                     confirmDismiss: (direction) async {
//                       if (direction == DismissDirection.endToStart) {
//                         //เมื่อเลือกทางขวา
//                         var id_address_u = address_user[i].idUserAddress;
//                         var address_u = address_user[i].nameUserAddress;
//                         delete_address(id_address_u!, address_u!);
//                         // ScaffoldMessenger.of(context)
//                         //     .showSnackBar(SnackBar(content: Text('ลบ')));
//                       } else {
//                         //เมื่อเลือกทางซ้าย
//                         Navigator.push(context,
//                             CupertinoPageRoute(builder: (context) {
//                           return Edit_address(
//                               address_user[i].idUserAddress,
//                               address_user[i].nameUserAddress,
//                               address_user[i].addressUser,
//                               address_user[i].lat,
//                               address_user[i].lng,
//                               address_user[i].idProvinces,
//                               address_user[i].idAmphures,
//                               address_user[i].idDistricts);
//                         })).then((value) => _get_addressuser(widget.idcard));
//                       }
//                     },
//                     // onDismissed: (direction) { //ทำงานเมื่อจบการลบ
//                     //   ScaffoldMessenger.of(context).showSnackBar(
//                     //       SnackBar(content: Text(' dismissed')));
//                     // },
//                     secondaryBackground: slideLeftBackground(),
//                     background: slideRightBackground(),
//                     child: InkWell(
//                       onLongPress: () async {
//                         // await get_amphures(address_user[i].idProvinces);
//                         // await get_districts(address_user[i].idAmphures);
//                         // edit_selectedValue_provinces =
//                         //     address_user[i].idProvinces;
//                         // edit_selectedValue_amphures = address_user[i].idAmphures;
//                         // edit_selectedValue_districts =
//                         //     address_user[i].idDistricts;
//                         // edit_map(
//                         //     address_user[i].idUserAddress,
//                         //     address_user[i].nameUserAddress,
//                         //     address_user[i].addressUser,
//                         //     address_user[i].lat,
//                         //     address_user[i].lng,
//                         //     address_user[i].idProvinces,
//                         //     address_user[i].idAmphures,
//                         //     address_user[i].idDistricts);
//                       },
//                       onTap: () async {
//                         setState(() {
//                           value_provinces = address_user[i].idProvinces;
//                           value_amphures = address_user[i].idAmphures;
//                           value_districts = address_user[i].idDistricts;
//                           active = address_user[i].idUserAddress;
//                           check_null_address = 1;
//                           mk = 1;
//                           setaddress = address_user[i].addressUser;
//                           var change_lat = address_user[i].lat;
//                           var change_lng = address_user[i].lng;
//                           lat = double.parse(change_lat!);
//                           lng = double.parse(change_lng!);
//                           lanlng.text = "$lat,$lng";
//                           foucus_mark(lat!, lng!);
//                         });
//                       },
//                       child: Card(
//                         color: active == address_user[i].idUserAddress
//                             ? Colors.blue[50]
//                             : Colors.grey[50],
//                         // shape: RoundedRectangleBorder(
//                         //   borderRadius: BorderRadius.circular(5.0),
//                         // ),
//                         child: Container(
//                           padding: EdgeInsets.all(10),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       "สถานที่จัดส่ง : ${address_user[i].nameUserAddress}",
//                                       style: TextStyle(
//                                         fontFamily: 'Prompt',
//                                         fontSize: ResponsiveFlutter.of(context)
//                                             .fontSize(1.7),
//                                       ),
//                                       overflow: TextOverflow.clip,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       "ที่อยู่ : ${address_user[i].addressUser} จ.${address_user[i].nameProvinces} อ.${address_user[i].nameAmphures} ต.${address_user[i].nameDistricts} ${address_user[i].zipCode}",
//                                       style: TextStyle(
//                                         fontFamily: 'Prompt',
//                                         fontSize: ResponsiveFlutter.of(context)
//                                             .fontSize(1.7),
//                                       ),
//                                       overflow: TextOverflow.clip,
//                                     ),
//                                   )
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Divider()
//                 ],
//               ],
//             )
//           ],
//         ),
