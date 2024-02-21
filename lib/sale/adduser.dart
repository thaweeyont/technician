import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/checkuser.dart';
import 'package:technician/models/product_job.dart';
import 'package:technician/sale/addlocation.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_progress.dart';
import 'package:http/http.dart' as http;
import 'package:technician/widgets/show_title.dart';

class Adduser extends StatefulWidget {
  Adduser({Key? key}) : super(key: key);

  @override
  _AdduserState createState() => _AdduserState();
}

enum SingingCharacter { morning, evening }

class _AdduserState extends State<Adduser> {
  var gen_id_job, id_staff, name_staff, id, edit_amount;
  var amount = 1, show_product;
  bool show_load = false;
  late DateTime _selectedDate;
  // int selectedIndex1 = 0;
  late Timer timer;
  String dropdownValue = 'สด';
  Completer<GoogleMapController> _controller = Completer();
  List<ProductJob> productjob = [];
  List<CheckUser> check_user = [];
  String? selectedValue_product;
  String? selectedValue_brand;
  String? selectedValue_provinces;
  String? selectedValue_amphures;
  String? selectedValue_districts;
  List provinces_list = [];
  List amphures_list = [];
  List districts_list = [];
  List product_type_list = [];
  List product_brand_list = [];
  String? edit_selectedValue_product;
  String? edit_selectedValue_brand;
  bool show_amphures = false, show_districts = false;
  var date_goto_st = "เช้า";

  TextEditingController idcard = TextEditingController();
  TextEditingController fullname = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController title_product = TextEditingController();
  TextEditingController detail_product = TextEditingController();
  TextEditingController edit_title_product = TextEditingController();
  TextEditingController edit_detail_product = TextEditingController();
  TextEditingController lanlng = TextEditingController();
  TextEditingController dateinput = TextEditingController();
  SingingCharacter? _character = SingingCharacter.morning;
  String? lat, lng;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_provinces();
    CheckPermission();
    getprofile_staff();
    _gen_id_job();
    if (gen_id_job != "") {
      _getProduct(gen_id_job);
    }
  }

  Future<Null> _gen_id_job() async {
    var date_now = DateTime.now();
    String formattedDate = DateFormat('kkmmss').format(date_now);
    // print(formattedDate);
    Random random = new Random();
    int randomNumber = random.nextInt(10000);
    // print(randomNumber);
    setState(() {
      show_load = true;
      gen_id_job = formattedDate + randomNumber.toString();
    });

    // print(gen_id_job);
  }

  Future<Null> getprofile_staff() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id_staff = preferences.getString('idStaff');
      name_staff = preferences.getString('name_staff');
    });
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
        }
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          alertLocationService(
              context, 'ไม่อนุญาติแชร์ Location', 'โปรดแชร์ location');
        }
      }
    } else {
      print('Service Location Close');
      alertLocationService(
          context, 'Location ปิดอยู่?', 'กรุณาเปิด Location ด้วยคะ');
    }
  }

  //เรียกใช้ api เช็คเลขบัตรประชาชนที่มีอยู่ในระบบ
  Future<Null> _check_user(String idcard) async {
    try {
      var respose = await http.get(Uri.http(ipconfig,
          '/flutter_api/api_staff/check_user.php', {"idcard": idcard}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        // print("มีข้อมูล");
        setState(() {
          check_user = checkUserFromJson(respose.body);
          if (check_user.length > 0) {
            fullname.text = check_user[0].fullname!;
            phone.text = check_user[0].phoneUser!;
            address.text = check_user[0].addressUser!;
            get_amphures(check_user[0].idProvinces);
            get_districts(check_user[0].idAmphures);
            selectedValue_provinces = check_user[0].idProvinces;
            selectedValue_amphures = check_user[0].idAmphures;
            selectedValue_districts = check_user[0].idDistricts;

            lat = check_user[0].lat!;
            lng = check_user[0].lng!;
          }
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  //เรียกใช้ api เพิ่มข้อมูล
  Future addjob(String status_function) async {
    var uri =
        Uri.parse("http://110.164.131.46/flutter_api/api_staff/add_job.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['status_function'] = status_function;
    request.fields['id_gen'] = gen_id_job;
    request.fields['id_sale'] = id_staff;
    request.fields['id_card_user'] = idcard.text;
    request.fields['fullname'] = fullname.text;
    request.fields['phone'] = phone.text;
    request.fields['address'] = address.text;
    request.fields['title_product'] = selectedValue_product!;
    request.fields['product_brand'] = selectedValue_brand!;
    request.fields['detail_product'] = detail_product.text;
    request.fields['type_product_contract'] = dropdownValue;
    request.fields['provinces'] = selectedValue_provinces!;
    request.fields['amphures'] = selectedValue_amphures!;
    request.fields['districts'] = selectedValue_districts!;
    request.fields['amount'] = amount.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      print("เพิ่มข้อมูลสำเร็จ");
      _getProduct(gen_id_job);
    } else {
      print("ไม่สำเร็จ");
    }
  }

  //เรียกใช้ api แก้ไขประเภทสัญญา
  Future addjob_type(String status_function) async {
    var uri =
        Uri.parse("http://110.164.131.46/flutter_api/api_staff/add_job.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['status_function'] = status_function;
    request.fields['id_gen'] = gen_id_job;
    request.fields['id_sale'] = id_staff;
    request.fields['id_card_user'] = idcard.text;
    request.fields['fullname'] = fullname.text;
    request.fields['phone'] = phone.text;
    request.fields['address'] = address.text;
    request.fields['title_product'] = selectedValue_product!;
    request.fields['product_brand'] = selectedValue_brand!;
    request.fields['detail_product'] = detail_product.text;
    request.fields['type_product_contract'] = dropdownValue;
    request.fields['amount'] = amount.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      print("เพิ่มข้อมูลสำเร็จ");
      _getProduct(gen_id_job);
    } else {
      print("ไม่สำเร็จ");
    }
  }

  Future next_page(String status_function) async {
    var uri =
        Uri.parse("http://110.164.131.46/flutter_api/api_staff/add_job.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['status_function'] = status_function;
    request.fields['id_gen'] = gen_id_job;
    request.fields['id_sale'] = id_staff;
    request.fields['id_card_user'] = idcard.text;
    request.fields['fullname'] = fullname.text;
    request.fields['phone'] = phone.text;
    request.fields['address'] = address.text;
    request.fields['title_product'] = selectedValue_product!;
    request.fields['product_brand'] = selectedValue_brand!;
    request.fields['detail_product'] = detail_product.text;
    request.fields['type_product_contract'] = dropdownValue;
    request.fields['provinces'] = selectedValue_provinces!;
    request.fields['amphures'] = selectedValue_amphures!;
    request.fields['districts'] = selectedValue_districts!;
    request.fields['amount'] = amount.toString();
    request.fields['date_goto_st'] = date_goto_st;
    request.fields['dateinput'] = dateinput.text;

    var response = await request.send();
    if (response.statusCode == 200) {
      Navigator.pop(context);
      Navigator.push(context, CupertinoPageRoute(builder: (context) {
        return Addlocation(gen_id_job, idcard.text, lat!, lng!);
      }));
    } else {
      print("ไม่สำเร็จ");
    }
  }

  //เรียกใช้ api แสดง สินค้า
  Future<Null> _getProduct(String gen_id_job) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_product_job.php',
          {"gen_id_job": gen_id_job}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูลสินค้า");
        setState(() {
          show_product = 1;
          productjob = productJobFromJson(respose.body);
        });
      }
    } catch (e) {
      setState(() {
        show_product = 0;
      });
      print("ไม่มีข้อมูลสินค้า");
    }
  }

  //เรียกใช้ api ลบข้อมูล สินค้า
  Future<Null> _getDelete(String id) async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig, '/flutter_api/api_staff/delete_product.php', {"id": id}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("ลบข้อมูลสินค้าเสร็จสิ้น");
        _getProduct(gen_id_job);
        Navigator.pop(context);
      }
    } catch (e) {
      print("ลบไม่สำเร็จ");
    }
  }

  //เรียกใช้ api แก้ไขข้อมูล สินค้า
  Future<Null> _getEdit(String id, String title, String detail, String contract,
      String edit_amount, String brand) async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/update_product.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id'] = id;
    request.fields['product_type'] = title;
    request.fields['product_detail'] = detail;
    request.fields['product_type_contract'] = contract;
    request.fields['edit_amount'] = edit_amount;
    request.fields['product_brand'] = brand;

    var response = await request.send();
    if (response.statusCode == 200) {
      print("แก้ไขข้อมูลสำเร็จ");
      _getProduct(gen_id_job);
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      print("แก้ไขไม่สำเร็จ");
    }
  }

  //api dropdown product_type
  Future getproduct_type() async {
    var respose = await http.get(
        Uri.http(ipconfig, '/flutter_api/api_staff/dopdown_product_type.php'));
    if (respose.statusCode == 200) {
      var jsonData = jsonDecode(respose.body);
      setState(() {
        product_type_list = jsonData;
      });
    }
    // print(product_type_list);
  }

  Future getproduct_brand() async {
    var respose = await http.get(
        Uri.http(ipconfig, '/flutter_api/api_staff/dopdown_product_brand.php'));
    if (respose.statusCode == 200) {
      var jsonData_brand = jsonDecode(respose.body);
      setState(() {
        product_brand_list = jsonData_brand;
      });
    }
    // print(product_type_list);
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

  Future<Null> add_product() async {
    Navigator.pop(context);
    var mediaQuery = MediaQuery.of(context);
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
    showAnimatedDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "เพิ่มข้อมูลสินค้า ",
                                  style: MyConstant().h2_5Style(),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: size * 0.06,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 30.0, top: 15),
                            child: Row(
                              children: [
                                Text(
                                  "ประเภทสินค้า : ",
                                  style: MyConstant().h3Style(),
                                ),
                                Container(
                                  child: DropdownButton(
                                    hint: Text(
                                      "เลือกประเภทสินค้า",
                                      style: MyConstant().normalStyle(),
                                    ),
                                    value: selectedValue_product,
                                    items: product_type_list.map((productlist) {
                                      return DropdownMenuItem(
                                          value:
                                              productlist['name_product_type'],
                                          child: Text(
                                            productlist['name_product_type'],
                                            style: MyConstant().h3Style(),
                                          ));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue_product =
                                            value.toString();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: sizeh * 0.01,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              left: 30.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "แบรนด์สินค้า : ",
                                  style: MyConstant().h3Style(),
                                ),
                                Container(
                                  child: DropdownButton(
                                    hint: Text(
                                      "เลือกแบรนด์สินค้า",
                                      style: MyConstant().normalStyle(),
                                    ),
                                    value: selectedValue_brand,
                                    items:
                                        product_brand_list.map((productbrand) {
                                      return DropdownMenuItem(
                                          value: productbrand[
                                              'name_product_brand'],
                                          child: Text(
                                            productbrand['name_product_brand'],
                                            style: MyConstant().h3Style(),
                                          ));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue_brand = value as String?;
                                      });
                                      // print(selectedValue_product);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: sizeh * 0.01,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 30.0, right: 30.0, top: 5),
                                  child: TextFormField(
                                    style: MyConstant().h3Style(),
                                    minLines: 5,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    controller: detail_product,
                                    decoration: InputDecoration(
                                      hintText: "รายละเอียดสินค้า",
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
                          ),
                          SizedBox(
                            height: sizeh * 0.02,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      amount = amount + 1;
                                    });
                                  },
                                  child: Icon(
                                    Icons.add_circle,
                                    size: size * 0.08,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  amount.toString(),
                                  style: MyConstant().h2Style(),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (amount > 1) amount = amount - 1;
                                    });
                                  },
                                  child: Icon(
                                    Icons.remove_circle,
                                    size: size * 0.08,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 15, bottom: 10),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: MyConstant.dark_f,
                              ),
                              label: Text(
                                "บันทึกข้อมูลสินค้า",
                                style: MyConstant().normalwhiteStyle(),
                              ),
                              icon: Icon(Icons.add_shopping_cart_rounded),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (selectedValue_product == null ||
                                      selectedValue_brand == null ||
                                      detail_product.text == "") {
                                    normalDialog(context, 'แจ้งเตือน',
                                        'กรุณากรอกข้อมูลให้ครบถ้วน');
                                  } else {
                                    addjob("1");
                                    Navigator.pop(context);
                                  }
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
      animationType: DialogTransitionType.slideFromRight,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  Future<Null> delete_product(String id, String name_c) async {
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
                    _getDelete(id);
                    Navigator.pop(context);
                    showProgressDialog(context);
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

  Future<Null> edit_product(String id, String title, String detail,
      String contract, String amount, String? brand) async {
    Navigator.pop(context);
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
    edit_selectedValue_product = title;
    edit_selectedValue_brand = brand;
    edit_detail_product.text = detail;
    edit_amount = int.parse(amount);
    showAnimatedDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "แก้ไขสินค้า $title",
                                  style: MyConstant().h2_5Style(),
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
                            padding: EdgeInsets.only(left: 30.0, top: 15),
                            child: Row(
                              children: [
                                Text(
                                  "ประเภทสินค้า : ",
                                  style: MyConstant().h3Style(),
                                ),
                                Container(
                                  child: DropdownButton(
                                    hint: Text(
                                      "เลือกประเภทสินค้า",
                                      style: MyConstant().normalStyle(),
                                    ),
                                    value: edit_selectedValue_product,
                                    items: product_type_list.map((productlist) {
                                      return DropdownMenuItem(
                                          value:
                                              productlist['name_product_type'],
                                          child: Text(
                                            productlist['name_product_type'],
                                            style: MyConstant().h3Style(),
                                          ));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        edit_selectedValue_product =
                                            value as String?;
                                      });
                                      // print(selectedValue_product);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 30.0, top: 15),
                            child: Row(
                              children: [
                                Text(
                                  "แบรนด์สินค้า : ",
                                  style: MyConstant().h3Style(),
                                ),
                                Container(
                                  child: DropdownButton(
                                    hint: Text(
                                      "เลือกแบรนด์สินค้า",
                                      style: MyConstant().normalStyle(),
                                    ),
                                    value: edit_selectedValue_brand,
                                    items:
                                        product_brand_list.map((productbrand) {
                                      return DropdownMenuItem(
                                          value: productbrand[
                                              'name_product_brand'],
                                          child: Text(
                                            productbrand['name_product_brand'],
                                            style: MyConstant().h3Style(),
                                          ));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        edit_selectedValue_brand =
                                            value as String?;
                                      });
                                      // print(selectedValue_product);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: sizeh * 0.01,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 30.0, right: 30.0, top: 5),
                                  child: TextFormField(
                                    style: MyConstant().h3Style(),
                                    minLines: 5,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    controller: edit_detail_product,
                                    decoration: InputDecoration(
                                      hintText: "รายละเอียดสินค้า",
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
                          ),
                          SizedBox(
                            height: sizeh * 0.02,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      edit_amount = edit_amount + 1;
                                    });
                                  },
                                  child: Icon(
                                    Icons.add_circle,
                                    size: size * 0.08,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  edit_amount.toString(),
                                  style: MyConstant().h2Style(),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (edit_amount > 1)
                                        edit_amount = edit_amount - 1;
                                    });
                                  },
                                  child: Icon(
                                    Icons.remove_circle,
                                    size: size * 0.08,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 15, bottom: 10),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Color.fromRGBO(252, 186, 3, 1.0),
                              ),
                              label: Text(
                                "แก้ไขข้อมูลสินค้า",
                                style: MyConstant().normalwhiteStyle(),
                              ),
                              icon: Icon(
                                Icons.edit,
                                size: size * 0.06,
                              ),
                              onPressed: () async {
                                if (edit_detail_product.text == "" ||
                                    edit_selectedValue_product == null ||
                                    edit_selectedValue_brand == null) {
                                  normalDialog(context, 'แจ้งเตือน',
                                      'กรุณากรอกข้อมูลให้ครบถ้วน');
                                } else {
                                  showProgressDialog(context);
                                  _getEdit(
                                      id,
                                      edit_selectedValue_product!,
                                      edit_detail_product.text,
                                      contract,
                                      edit_amount.toString(),
                                      edit_selectedValue_brand!);
                                  // successDialog(
                                  //     context, 'Success', 'แก้ไขสำเร็จ');
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
      animationType: DialogTransitionType.slideFromRight,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

//วันที่จัดส่ง
  _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(
            2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      print(
          formattedDate); //formatted date output using intl package =>  2021-03-16
      //you can implement different kind of Date Format here according to your requirement

      setState(() {
        dateinput.text = formattedDate; //set output date to TextField value.
      });
    } else {
      print("Date is not selected");
    }
  }

  final _formKey = GlobalKey<FormState>();

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
        backgroundColor: MyConstant.dark,
        elevation: 0,
        title: Text(
          "บันทึกข้อมูล ",
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
      body: show_load == false
          ? Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              behavior: HitTestBehavior.opaque,
              child: RefreshIndicator(
                onRefresh: () async {
                  _getProduct(gen_id_job);
                },
                child: ListView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            child: Column(children: [
                              Container(
                                child: Container(
                                  child: Column(
                                    children: [
                                      //ข้อมูลลูกค้า
                                      data_user(sizeh, size),
                                      SizedBox(
                                        width: double.infinity,
                                        height: sizeh * 0.02,
                                        child: const DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFEEEEEE)),
                                        ),
                                      ),
                                      date_install(size, context),
                                      SizedBox(
                                        width: double.infinity,
                                        height: sizeh * 0.02,
                                        child: const DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFEEEEEE)),
                                        ),
                                      ),
                                      //ข้อมูลสินค้า
                                      data_product(sizeh, size),
                                      SizedBox(
                                        width: double.infinity,
                                        height: sizeh * 0.02,
                                        child: const DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFEEEEEE)),
                                        ),
                                      ),
                                      //ข้อมูลพนักงานขาย
                                      dtat_staff(sizeh, size),
                                      //ปุ่มถัดไป
                                      button_submit(size),
                                      SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Column date_install(double size, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Row(
            children: [
              Icon(
                Icons.date_range_rounded,
                color: MyConstant.dark,
                size: size * 0.06,
              ),
              Text(
                "  วันที่จัดส่ง",
                style: MyConstant().h2_5Style(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 10),
          child: Row(
            children: [
              // Text("เวลาจัดส่ง", style: MyConstant().h3Style()),
              Expanded(
                child: TextFormField(
                  controller: dateinput,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาเพิ่มวันที่จัดส่ง';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.calendar_today,
                      color: MyConstant.dark,
                    ),
                    labelText: "วันที่จัดส่ง",
                    labelStyle: MyConstant().normalStyle(),
                  ),
                  onTap: () {
                    _selectDate(context);
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 10),
                child: Text("ช่วงเวลาจัดส่ง", style: MyConstant().h3Style()),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('เช้า'),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.morning,
                        groupValue: _character,
                        onChanged: (SingingCharacter? value) {
                          setState(() {
                            _character = value;
                            date_goto_st = "เช้า";
                          });
                          print(date_goto_st);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('บ่าย'),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.evening,
                        groupValue: _character,
                        onChanged: (SingingCharacter? value) {
                          setState(() {
                            _character = value;
                            date_goto_st = "บ่าย";
                          });
                          print(date_goto_st);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget data_user(sizeh, size) => Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(
                    "ข้อมูลลูกค้า",
                    style: MyConstant().h2_5Style(),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: MyConstant().h3Style(),
                    onChanged: (String idcard) {
                      _check_user(idcard);
                    },
                    keyboardType: TextInputType.number,
                    controller: idcard,
                    maxLength: 13,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาเพิ่ม เลขบัตรประจำตัวประชาชน';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.people_sharp),
                      labelText: "เลขบัตรประจำตัวประชาชน",
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
            SizedBox(
              height: sizeh * 0.02,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: MyConstant().h3Style(),
                    controller: fullname,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาเพิ่ม ชื่อ-สกุล';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.people_sharp),
                      labelText: "ชื่อ-สกุล",
                      labelStyle: MyConstant().normalStyle(),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  // child: Container(
                  //   height: 55,
                  //   child:
                  // ),
                )
              ],
            ),
            SizedBox(
              height: sizeh * 0.02,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: MyConstant().h3Style(),
                    controller: phone,
                    maxLength: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาเพิ่ม เบอร์โทร';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      labelText: "เบอร์โทร",
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
            Container(
              padding: EdgeInsets.only(left: size * 0.05, right: size * 0.05),
              child: Row(
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
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: size * 0.05, right: size * 0.05),
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
            ),
            Container(
              padding: EdgeInsets.only(left: size * 0.05, right: size * 0.05),
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
            ),
            SizedBox(
              height: sizeh * 0.02,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 110,
                    child: TextFormField(
                      style: MyConstant().h3Style(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาเพิ่ม บ้านเลขที่/หมู่บ้าน';
                        }
                        return null;
                      },
                      minLines: 2,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: address,
                      // keyboardType: TextInputType.number,
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
            ),
            SizedBox(
              height: sizeh * 0.02,
            ),
          ],
        ),
      );

  Widget data_product(sizeh, size) => Container(
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
                  Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              showProgressDialog(context);
                              // title_product.text = "";
                              detail_product.text = "";
                              amount = 1;
                              await getproduct_type();
                              await getproduct_brand();
                              add_product();
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: Icon(
                              Icons.playlist_add,
                              color: MyConstant.dark,
                              size: size * 0.06,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            if (show_product == 1) ...[
              for (int i = 0; i < productjob.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 35.0, bottom: 10.0),
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
                        padding:
                            const EdgeInsets.only(left: 35.0, bottom: 10.0),
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
                        padding:
                            const EdgeInsets.only(left: 35.0, bottom: 10.0),
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
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Row(
                          mainAxisAlignment: productjob.length > 1
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () async {
                                showProgressDialog(context);
                                await getproduct_type();
                                await getproduct_brand();
                                var id = productjob[i].idProduct;
                                var product_type = productjob[i].productType;
                                var product_detail =
                                    productjob[i].productDetail;
                                var contract =
                                    productjob[i].productTypeContract;
                                var amount = productjob[i].productCount;
                                var brand = productjob[i].productBrand;
                                edit_product(id!, product_type!,
                                    product_detail!, contract!, amount!, brand);
                              },
                              child: Icon(
                                Icons.edit,
                                color: Colors.amber,
                              ),
                            ),
                            if (productjob.length > 1) ...[
                              InkWell(
                                onTap: () {
                                  var id = productjob[i].idProduct;
                                  var name_c = productjob[i].productType;
                                  if (id != null) {
                                    delete_product(id, name_c!);
                                  }
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: size * 0.06,
                                ),
                              ),
                            ],
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
                  height: 5,
                )
              ]
            ] else ...[
              Container(
                padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'กรุณาเพิ่มสินค้า',
                      style: MyConstant().normalStyle(),
                    ),
                    SizedBox(width: size * 0.02),
                    SizedBox(
                      width: sizeh * 0.01,
                      height: sizeh * 0.01,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    )
                  ],
                ),
              ),
            ],
            //ประเภทสัญญา
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Row(
                children: [
                  Text(
                    "ประเภทสัญญา : ",
                    style: MyConstant().h3Style(),
                  ),
                  Expanded(
                    child: Container(
                      height: sizeh * 0.05,
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        // icon: const Icon(
                        //     Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: MyConstant().h3Style(),
                        underline: Container(
                          height: 2,
                          color: MyConstant.dark,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                            addjob_type("4");
                          });
                        },
                        items: <String>['สด', 'เชื่อ', 'ผ่อน']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );

  Widget dtat_staff(sizeh, size) => Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 30.0,
          right: 30.0,
          top: 10,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "พนักงานขาย : ",
                  style: MyConstant().h3Style(),
                ),
                Text(
                  "$name_staff",
                  style: MyConstant().h3Style(),
                ),
              ],
            ),
            SizedBox(
              height: sizeh * 0.02,
            ),
          ],
        ),
      );

  Widget button_submit(size) => Container(
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
            'ถัดไป',
            style: MyConstant().normalwhiteStyle(),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (selectedValue_provinces != null &&
                  selectedValue_amphures != null &&
                  selectedValue_districts != null) {
                if (phone.text.length < 10 || phone.text.length > 13) {
                  normalDialog(
                      context, 'แจ้งเตือน', 'กรุณากรอกเบอร์โทรให้ถูกต้อง');
                } else if (productjob.length == 0) {
                  normalDialog(context, 'แจ้งเตือน', 'กรุณาเพิ่มข้อมูลสินค้า');
                } else {
                  if (lat == null) {
                    setState(() {
                      lat = "0";
                      lng = "0";
                    });
                  }
                  showProgressDialog(context);
                  next_page("2");
                }
              } else {
                normalDialog(context, 'แจ้งเตือน', 'กรุณากรอกข้อมูลให้ครบถ้วน');
              }
            } else {
              normalDialog(context, 'แจ้งเตือน', 'กรุณากรอกข้อมูลให้ครบถ้วน');
            }
          },
        ),
      );
}

// class AlwaysDisabledFocusNode extends FocusNode {
//   @override
//   bool get hasFocus => false;
// }
