import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/mechanic/setting_mechanic.dart';
import 'package:technician/models/detail_mechanicmodel.dart';
import 'package:technician/models/detail_product_mechanicmodel.dart';
import 'package:technician/models/job_log_addressmodel.dart';
import 'package:technician/models/jobmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:technician/widgets/show_progress.dart';
// import 'package:qrscans/qrscan.dart' as scanner;
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:url_launcher/url_launcher.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class detailjob extends StatefulWidget {
  final String id_gen_job, id_staff, time_go;
  detailjob(this.id_gen_job, this.id_staff, this.time_go);

  @override
  _detailjobState createState() => _detailjobState();
}

class _detailjobState extends State<detailjob> with WidgetsBindingObserver {
  TextEditingController warningcontroller = TextEditingController();
  List<File?> files = [];
  List<File?> files_img_install = [];
  List<File?> files2 = [];
  List name_image_install = [];
  List name_image_receipt = [];
  List<JobLogAddress> address_history = [];
  File? file;
  File? file2;
  List<DetailMechanicmodel> data_user = [];
  List<DetailProductMechanicmodel> data_product = [];
  List id_product = [];
  var lat, lng, token;
  bool show_map_status = false;
  double? lat_mec, lng_mec;
  var time_start = TextEditingController();
  var time_end = TextEditingController();
  var status_show;
  bool status_go_install = true;
  var isSwitched = false;
  var code_product;
  var show_barcode;
  var mec_no_check = 0;
  var id_data;
  late final AsyncCallback resumeCallBack;
  late Timer timer;
  String? barcode = "";
  String? dropdownValue;
  Key key = UniqueKey();

  late FocusNode myFocusNode;

  final controller = ScrollController();

  @override
  void initState() {
    // print("======================>>>${widget.time_go}");
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    CheckPermission();
    getdatauser();
    getdataproduct();
    _getAddress(widget.id_gen_job);
    myFocusNode = FocusNode();
    initialFile();
    initialFile2();
  }

  //???????????????????????????????????????????????????
  void initialFile() {
    for (var i = 0; i < 4; i++) {
      files.add(null);
    }
  }

  //??????????????????????????????????????????
  void initialFile2() {
    for (var i = 0; i < 2; i++) {
      files2.add(null);
    }
  }

  // ???????????????????????????
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        // ??????????????????
        break;
      case AppLifecycleState.resumed:
        //???????????????????????????????????????
        restartApp();
        break;
      case AppLifecycleState.paused:
        //?????????????????????????????????????????????

        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    if (status_show == "4") {
      timer.cancel();
    }
    super.dispose();
  }

//?????????????????????????????????
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  //CheckPermission
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
              context, '?????????????????????????????????????????? Location', '???????????????????????? location');
        } else {
          // Find LatLong
          findLatLng();
        }
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          alertLocationService(
              context, '?????????????????????????????????????????? Location', '???????????????????????? location');
        } else {
          // Find LatLong
          findLatLng();
        }
      }
    } else {
      print('Service Location Close');
      alertLocationService(
          context, 'Location ??????????????????????', '??????????????????????????? Location ??????????????????');
    }
  }

  Future<Null> findLatLng() async {
    Position? position = await findPosition();
    setState(() {
      lat_mec = position!.latitude;
      lng_mec = position.longitude;
      print('lat_mec = $lat_mec, lng_mec = $lng_mec');
    });
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

  Future<Null> stampLatLng() async {
    Position? position_bg = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      print("------------------------------------------");
      lat_mec = position_bg.latitude;
      lng_mec = position_bg.longitude;

      if (status_show == "3") {
        getdataproduct();
        update_latlng("4");
      } else if (status_show == "4") {
        update_latlng("4");
      }
      print('lat_mec = $lat_mec, lng_mec = $lng_mec');
    });
  }

  Future<Null> stampLatLng_install() async {
    Position? position = await findPosition();
    setState(() {
      lat_mec = position!.latitude;
      lng_mec = position.longitude;

      goto_product_api("5");
      print('lat_mec = $lat_mec, lng_mec = $lng_mec');
    });
  }

  //???????????????????????? api ???????????? ??????????????????????????????????????????
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
      print("???????????????????????????????????????????????????");
    }
  }

  //stamp_lat/lng
  Future stamp() async {
    if (status_show == "3" || status_show == "4") {
      timer = Timer.periodic(
        Duration(seconds: 20),
        (Timer t) async {
          if (status_show == "3" || status_show == "4") {
            print("time");
            await stampLatLng();
          } else {
            timer.cancel();
          }
        },
      );
    } else {
      timer.cancel();
    }
  }

  //Api ???????????????????????????????????? lat/lng ???????????????????????????????????????????????????
  Future update_latlng(String function) async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/mechanic_update_status.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id_gen'] = widget.id_gen_job;
    request.fields['id_staff'] = widget.id_staff;
    request.fields['function'] = function;
    request.fields['lat_mec'] = lat_mec.toString();
    request.fields['lng_mec'] = lng_mec.toString();
    request.fields['date_time'] = widget.time_go;
    var response = await request.send();
    if (response.statusCode == 200) {
      print("??????????????????latlng??????????????????");
      // Notification_api(2);
    } else {
      print("??????????????????latlng???????????????????????????");
    }
  }

  //Api ??????????????????????????????????????????????????????
  Future check_product_api(String function) async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/mechanic_update_status.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id_gen'] = widget.id_gen_job;
    request.fields['id_staff'] = widget.id_staff;
    request.fields['function'] = function;
    request.fields['check_machine_code'] = code_product;
    request.fields['date_time'] = widget.time_go;

    var response = await request.send();
    if (response.statusCode == 200) {
      print("????????????????????????????????????????????????");
      getdataproduct();
    } else {
      print("?????????????????????????????????????????????????????????");
    }
  }

  //Api ??????????????????
  Future submit_product_api(String function) async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/mechanic_update_status.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id_gen'] = widget.id_gen_job;
    request.fields['id_staff'] = widget.id_staff;
    request.fields['function'] = function;
    request.fields['time_start'] = time_start.text;
    request.fields['time_end'] = time_end.text;
    request.fields['lat_mec'] = lat_mec.toString();
    request.fields['lng_mec'] = lng_mec.toString();
    request.fields['date_time'] = widget.time_go;
    var response = await request.send();
    if (response.statusCode == 200) {
      print("??????????????????????????????????????????????????????");
      getdataproduct();
      Notification_api(1);
    } else {
      print("???????????????????????????????????????????????????????????????");
    }
  }

  //Api ???????????????????????????
  Future start_product_api(String function) async {
    // print("$dropdownValue");
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/mechanic_update_status.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id_gen'] = widget.id_gen_job;
    request.fields['id_staff'] = widget.id_staff;
    request.fields['function'] = function;
    request.fields['lat_mec'] = lat_mec.toString();
    request.fields['lng_mec'] = lng_mec.toString();
    request.fields['date_time'] = widget.time_go;
    if (dropdownValue != null) {
      request.fields['warning'] = dropdownValue!;
    }
    var response = await request.send();
    if (response.statusCode == 200) {
      print("??????????????????????????????????????????????????????");
      getdataproduct();
      // Notification_api(1);
    } else {
      print("???????????????????????????????????????????????????????????????");
    }
  }

  //Api ?????????????????????????????????????????????
  Future goto_product_api(String function) async {
    // print("$dropdownValue");
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/mechanic_update_status.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['id_gen'] = widget.id_gen_job;
    request.fields['id_staff'] = widget.id_staff;
    request.fields['function'] = function;
    request.fields['lat_mec'] = lat_mec.toString();
    request.fields['lng_mec'] = lng_mec.toString();
    request.fields['date_time'] = widget.time_go;
    var response = await request.send();
    if (response.statusCode == 200) {
      print("??????????????????????????????????????????????????????");
      getdataproduct();
      Notification_api(3);
    } else {
      print("???????????????????????????????????????????????????????????????");
    }
  }

  //????????????????????????????????????????????????
  void getdatauser() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/detail_mechanic.php',
          {"id_gen_job": widget.id_gen_job}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("????????????????????????");
        setState(() {
          data_user = detailMechanicmodelFromJson(respose.body);
          if (data_user[0].latJob.toString().isNotEmpty) {
            show_map_status = true;
            lat = data_user[0].latJob;
            lng = data_user[0].lngJob;
          } else {
            show_map_status = false;
          }

          token = data_user[0].token;
        });
      }
    } catch (e) {
      print("?????????????????????????????????");
    }
  }

  //????????????????????????????????????????????????
  void getdataproduct() async {
    try {
      // print("------------->${widget.time_go}");
      var respose = await http.get(Uri.http(
          ipconfig, '/flutter_api/api_staff/detail_product_mechanic.php', {
        "id_gen_job": widget.id_gen_job,
        "id_staff": widget.id_staff,
        "date_time": widget.time_go,
      }));
      print("----------->${respose.body}");
      if (respose.statusCode == 200) {
        print("????????????????????????");
        setState(() {
          data_product = detailProductMechanicmodelFromJson(respose.body);
          status_show = data_product[0].statusData;
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
          if (status_show == "4") {
            status_go_install = false;
            stamp();
            stampLatLng();
          }
        });
      }
    } catch (e) {
      print("+++++>?????????????????????????????????");
    }
  }

  //????????????????????????????????????????????????????????? ??????????????????????????????
  Future<Null> processendproduct() async {
    int checkFile = 0;
    int checkFile_receipt = 0;
    for (var item in files) {
      if (item == null) {
        checkFile++;
      }
    }

    if (checkFile == 4) {
      normalDialog(context, '???????????????????????????', '?????????????????????????????????????????????????????????????????????');
    } else {
      setState(() {
        files_img_install = [];
      });

      showProgressDialog(context);
      // // ???????????????????????????????????????????????????????????? ???????????????????????????
      for (var item_receipt in files2) {
        if (item_receipt != null) {
          int i = Random().nextInt(10000000);
          String nameFile = 'img_receipt$i.jpg';
          String apisaveimg_receipt =
              'http://$ipconfig/flutter_api/img_end_install.php?id_gen_job=${widget.id_gen_job}&id_staff=${widget.id_staff}&function=2&name_img=$nameFile&id_data=$id_data';
          Map<String, dynamic> map_receipt = {};
          map_receipt['file'] = await MultipartFile.fromFile(item_receipt.path,
              filename: nameFile);
          FormData data_receipt = FormData.fromMap(map_receipt);
          var response = await Dio()
              .post(apisaveimg_receipt, data: data_receipt)
              .then((value) {
            // print("---------------->$value");
          });
        }
      }
      // ????????????????????????????????????????????????????????????????????? ???????????????????????????
      for (var item in files) {
        if (item != null) {
          setState(() {
            files_img_install.add(item);
          });
        }
      }
      int loop = 0;
      for (var item_i in files_img_install) {
        int i = Random().nextInt(10000000);
        String nameFile = 'img_install$i.jpg';
        String apisaveimg =
            'http://$ipconfig/flutter_api/img_end_install.php?id_gen_job=${widget.id_gen_job}&id_staff=${widget.id_staff}&function=1&name_img=$nameFile&id_data=$id_data';
        Map<String, dynamic> map = {};
        map['file'] =
            await MultipartFile.fromFile(item_i!.path, filename: nameFile);
        FormData data = FormData.fromMap(map);

        var response2 =
            await Dio().post(apisaveimg, data: data).then((value) async {
          loop++;
          if (loop >= files_img_install.length) {
            await findLatLng();
            for (var i = 0; i < id_product.length; i++) {
              var id_product_st = id_product[i];
              String path =
                  'http://$ipconfig/flutter_api/api_staff/insert_image_install.php?id_gen=${widget.id_gen_job}&id_staff=${widget.id_staff}&image_install=$name_image_install&imge_receipt=$name_image_receipt&warning_end=${warningcontroller.text}&lat_mec=$lat_mec&lng_mec=$lng_mec&id_product=$id_product_st&date_time=${widget.time_go}';
              await Dio().get(path).then(
                    (value) {},
                  );
            }
            Notification_api(5);
            Navigator.pop(context);
            Navigator.pop(context);
          }
          // name_image_install
        });
      }
    }
  }

  //delete ??????????????????????????????
  Future<Null> delete_receipt_img(int index) async {
    setState(() {
      files2[index] = null;
    });
  }

  //delete ?????????
  Future<Null> delete_img(int index) async {
    setState(() {
      files[index] = null;
      // files[index] = null;
    });
  }

  //??????????????????????????????
  Future<Null> process_receiptImagePicker(ImageSource source, int index) async {
    try {
      var result2 = await ImagePicker().getImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );

      setState(() {
        file2 = File(result2!.path);
        files2[index] = file2;
      });
    } catch (e) {}
  }

  //???????????????????????????????????????
  Future<Null> processImagePicker(ImageSource source, int index) async {
    try {
      var result = await ImagePicker().getImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );

      setState(() {
        file = File(result!.path);
        files[index] = file;
      });
    } catch (e) {}
  }

  //dialog ?????????????????????????????????????????????
  Future<Null> img_receipt(int index) async {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        title: ListTile(
          leading: Icon(
            Icons.image,
            size: 55,
          ),
          title: Text(
            '??????????????????????????????????????? ${index + 1} ?',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
            ),
          ),
          subtitle: Text(
            '?????????????????????????????????????????????????????????????????????????????????????????? ???????????? ?????????????????????',
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
                onPressed: () {
                  Navigator.pop(context);
                  process_receiptImagePicker(ImageSource.gallery, index);
                },
                child: Text(
                  "?????????????????????",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: ResponsiveFlutter.of(context).fontSize(1.8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  process_receiptImagePicker(ImageSource.camera, index);
                },
                child: Text(
                  "???????????????????????????",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    // color: Colors.red,
                    fontSize: ResponsiveFlutter.of(context).fontSize(1.8),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  //dialog ??????????????????????????????????????????????????????
  Future<Null> img_install(int index) async {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        title: ListTile(
          leading: Icon(
            Icons.image,
            size: 55,
          ),
          title: Text(
            '???????????????????????????????????????????????? ${index + 1} ?',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
            ),
          ),
          subtitle: Text(
            '?????????????????????????????????????????????????????????????????????????????????????????? ???????????? ?????????????????????',
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
                onPressed: () {
                  Navigator.pop(context);
                  processImagePicker(ImageSource.gallery, index);
                },
                child: Text(
                  "?????????????????????",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: ResponsiveFlutter.of(context).fontSize(1.8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  processImagePicker(ImageSource.camera, index);
                },
                child: Text(
                  "???????????????????????????",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    // color: Colors.red,
                    fontSize: ResponsiveFlutter.of(context).fontSize(1.8),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }

  //dialog ????????????????????????????????????
  Future<Null> submit_product(
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
              style: MyConstant().h2_5Style(),
            ),
            subtitle: Text(message, style: MyConstant().normalStyle()),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    if (lat_mec == null) {
                      // dialogprogress();
                    } else {
                      submit_product_api("1");
                      controller.jumpTo(0);
                      Navigator.pop(context);
                    }
                  },
                  child: Text("????????????", style: MyConstant().h3Style()),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("??????????????????", style: MyConstant().normalredStyle()),
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

  //dialog ?????????????????????????????????????????????
  Future<Null> submit_product_install() async {
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
            title: Text('???????????????????????????', style: MyConstant().h2_5Style()),
            subtitle: Text('????????????????????????????????????????????????????????????????????????????????????????????????????????????',
                style: MyConstant().normalStyle()),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    stampLatLng_install();
                    Navigator.pop(context);
                  },
                  child: Text("????????????", style: MyConstant().h3Style()),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("??????????????????", style: MyConstant().normalredStyle()),
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

  //dialog ???????????????????????????????????????????????????
  Future<Null> start_product() async {
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
            leading: mec_no_check >= 1
                ? Image.asset('images/error_log.gif')
                : Image.asset('images/success.png'),
            title: Text('???????????????????????????', style: MyConstant().h2_5Style()),
            subtitle: mec_no_check >= 1
                ? Text('???????????????????????????????????????????????????????????????????????????????????? ???????????? ??????????????????????????????',
                    style: MyConstant().normalStyle())
                : Text('??????????????????????????????????????????????????????????????????',
                    style: MyConstant().normalStyle()),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    if (lat_mec == null) {
                      // dialogprogress();
                    } else {
                      controller.jumpTo(0);
                      start_product_api("3");
                      Notification_api(4);
                      Navigator.pop(context);
                    }
                  },
                  child: mec_no_check >= 1
                      ? Text("??????????????????????????????????????????????????????????????????",
                          style: MyConstant().normalyelloStyle())
                      : Text("????????????", style: MyConstant().h3Style()),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("??????????????????", style: MyConstant().normalredStyle()),
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

  //dialog load
  Future<Null> dialogprogress() async {
    double size = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          // color: Colors.red
          shape: BoxShape.rectangle,
        ),
        child: SimpleDialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          children: [
            Column(
              children: [
                CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //???????????????????????? api Notification ?????????????????????????????????????????????????????????????????????????????????
  Future<Null> Notification_api(int function) async {
    if (function == 1) {
      try {
        var respose = await http.get(
            Uri.http(ipconfig, '/flutter_api/api_staff/apiNotification.php', {
          "isAdd": "true",
          "token": token,
          "title": "?????????????????????????????????",
          "body": "????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????"
        }));
        if (respose.statusCode == 200) {
          print("notification??????????????????1");
        }
      } catch (e) {
        print("notification???????????????????????????1");
      }
    }
    if (function == 2) {
      try {
        var respose = await http.get(
            Uri.http(ipconfig, '/flutter_api/api_staff/apiNotification.php', {
          "isAdd": "true",
          "token": token,
          "title": "?????????????????????????????????",
          "body": "??????????????????????????????????????????????????????????????????????????????????????????????????????????????????"
        }));
        if (respose.statusCode == 200) {
          print("notification??????????????????2");
        }
      } catch (e) {
        print("notification???????????????????????????2");
      }
    }
    if (function == 3) {
      try {
        var respose = await http.get(
            Uri.http(ipconfig, '/flutter_api/api_staff/apiNotification.php', {
          "isAdd": "true",
          "token": token,
          "title": "?????????????????????????????????",
          "body": "???????????????????????????????????????????????????????????????????????????????????????"
        }));
        if (respose.statusCode == 200) {
          print("notification??????????????????3");
        }
      } catch (e) {
        print("notification???????????????????????????3");
      }
    }
    // if (function == 4) {
    //   try {
    //     var respose = await http.get(
    //         Uri.http(ipconfig, '/flutter_api/api_staff/apiNotification.php', {
    //       "isAdd": "true",
    //       "token": token,
    //       "title": "?????????????????????????????????",
    //       "body": "?????????????????????????????????????????????????????????????????????????????????????????????"
    //     }));
    //     if (respose.statusCode == 200) {
    //       print("notification??????????????????4");
    //     }
    //   } catch (e) {
    //     print("notification???????????????????????????4");
    //   }
    // }
    // if (function == 5) {
    //   try {
    //     var respose = await http.get(
    //         Uri.http(ipconfig, '/flutter_api/api_staff/apiNotification.php', {
    //       "isAdd": "true",
    //       "token": token,
    //       "title": "?????????????????????????????????",
    //       "body": "??????????????????????????????????????????????????????????????????????????????????????????????????????????????????"
    //     }));
    //     if (respose.statusCode == 200) {
    //       print("notification??????????????????5");
    //     }
    //   } catch (e) {
    //     print("notification???????????????????????????5");
    //   }
    // }
  }

  //scaner
  Future<Null> _barcode() async {
    code_product = null;
    await Permission.camera.request();
    String? cameraScanResult = await scanner.scan();
    setState(() {
      show_barcode = cameraScanResult;
    });
    // var maxcode = cameraScanResult!.length;
    var mincode = cameraScanResult!.length - 6;
    var maxcode = cameraScanResult.split('');
    var spcode = maxcode.skip(mincode).take(cameraScanResult.length);
    var valuecodeinfo = StringBuffer();
    spcode.forEach((item) {
      valuecodeinfo.write(item);
    });
    for (var i = 0; i < data_product.length; i++) {
      if (data_product[i].machineCode == valuecodeinfo.toString()) {
        setState(() {
          code_product = valuecodeinfo.toString();
        });
      }
    }
    if (code_product == null) {
      normalDialog(
          context, '???????????????????????????', '????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????');
      print(
          "-----------------------????????????????????????????????????????????????--------------------------$code_product");
    } else {
      check_product_api("2");
      // print(
      //     "---------------------??????????????????????????????????????? ==> $code_product---------------------------");
    }
  }

  //zoom_img
  Future<Null> zoom_img(int index) async {
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
              Image.file(
                files[index]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Null> zoom_img_receipt(int index) async {
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
              Image.file(
                files2[index]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      key: key,
      backgroundColor: Colors.white,
      appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (context) {
                    return SettingMechanic(
                        widget.id_gen_job, widget.id_staff, status_show);
                  }));
                }),
          ],
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                // if (lat_mec != null) {
                Navigator.of(context).pop();
                // }
              }),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(27, 55, 120, 1.0),
          elevation: 0,
          title: Text(
            "???????????????????????????????????????",
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
          )),
      body: data_user.isEmpty
          ? ShowProgress()
          : GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Column(
                children: [
                  if (status_show == "1") ...[
                    Status_1(size),
                    button_getproduct(),
                  ],
                  if (status_show == "2") ...[
                    Status_2(size),
                    button_prepare(),
                  ],
                  if (status_show == "3" || status_show == "4") ...[
                    Status_3(size),
                    button_start(),
                  ],
                  if (status_show == "5") ...[
                    Status_5(size),
                    button_endproduct(),
                  ],
                ],
              ),
            ),
    );
  }

//Widget Status ??????????????????--------------------------------------------------------------------------------------------------------------------------------
  Widget Status_5(size) => Expanded(
        child: RefreshIndicator(
          onRefresh: () async {
            getdatauser();
            getdataproduct();
          },
          child: SafeArea(
            child: Scrollbar(
              radius: Radius.circular(30),
              thickness: 6,
              // isAlwaysShown: true,
              child: SingleChildScrollView(
                //????????????????????????
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                reverse: false,
                child: Column(
                  children: [
                    image_install(size),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    image_receipt(size),
                    warning_install_end(),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    showdata_user(size),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    showdata_product(size),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  //????????????????????????????????????
  Widget image_install(size) => Container(
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
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          "????????????????????????????????????????????????",
                          style: MyConstant().h2_5Style(),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        // color: Colors.amber,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width * 0.45,
                        child: Center(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Container(
                                  child: files[0] == null
                                      ? InkWell(
                                          onTap: () => img_install(0),
                                          child: Icon(
                                            Icons.add_photo_alternate_sharp,
                                            color: Colors.grey[400],
                                            size: size * 0.18,
                                          ),
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () => zoom_img(0),
                                              child: Container(
                                                decoration: new BoxDecoration(
                                                    color: Colors.white),
                                                alignment: Alignment.center,
                                                height: size * 0.45,
                                                child: Image.file(
                                                  files[0]!,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: InkWell(
                                                onTap: () {
                                                  delete_img(0);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(30),
                                                    ),
                                                    color: Colors.white38,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            27, 55, 120, 1.0),

                                                        offset: Offset(0,
                                                            0), // Shadow position
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                                SizedBox(width: 15),
                                Container(
                                  child: files[1] == null
                                      ? InkWell(
                                          onTap: () => img_install(1),
                                          child: Icon(
                                            Icons.add_photo_alternate_sharp,
                                            color: Colors.grey[400],
                                            size: size * 0.18,
                                          ),
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () => zoom_img(1),
                                              child: Container(
                                                decoration: new BoxDecoration(
                                                    color: Colors.white),
                                                alignment: Alignment.center,
                                                height: size * 0.45,
                                                child: Image.file(
                                                  files[1]!,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: InkWell(
                                                onTap: () {
                                                  delete_img(1);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(30),
                                                    ),
                                                    color: Colors.white38,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            27, 55, 120, 1.0),

                                                        offset: Offset(0,
                                                            0), // Shadow position
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                                SizedBox(width: 15),
                                Container(
                                  child: files[2] == null
                                      ? InkWell(
                                          onTap: () => img_install(2),
                                          child: Icon(
                                            Icons.add_photo_alternate_sharp,
                                            color: Colors.grey[400],
                                            size: size * 0.18,
                                          ),
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () => zoom_img(2),
                                              child: Container(
                                                decoration: new BoxDecoration(
                                                    color: Colors.white),
                                                alignment: Alignment.center,
                                                height: size * 0.45,
                                                child: Image.file(
                                                  files[2]!,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: InkWell(
                                                onTap: () {
                                                  delete_img(2);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(30),
                                                    ),
                                                    color: Colors.white38,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            27, 55, 120, 1.0),

                                                        offset: Offset(0,
                                                            0), // Shadow position
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                                SizedBox(width: 15),
                                Container(
                                  child: files[3] == null
                                      ? InkWell(
                                          onTap: () => img_install(3),
                                          child: Icon(
                                            Icons.add_photo_alternate_sharp,
                                            color: Colors.grey[400],
                                            size: size * 0.18,
                                          ),
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () => zoom_img(3),
                                              child: Container(
                                                decoration: new BoxDecoration(
                                                    color: Colors.white),
                                                alignment: Alignment.center,
                                                height: size * 0.45,
                                                child: Image.file(
                                                  files[3]!,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: InkWell(
                                                onTap: () {
                                                  delete_img(3);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(30),
                                                    ),
                                                    color: Colors.white38,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            27, 55, 120, 1.0),

                                                        offset: Offset(0,
                                                            0), // Shadow position
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  //??????????????????????????????
  Widget image_receipt(size) => Container(
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
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "????????????????????????????????????????????????",
                              style: MyConstant().h2_5Style(),
                            ),
                            Text(
                              "?????????????????????????????????????????????????????????????????????????????????????????????",
                              style: MyConstant().normalredStyle(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Scrollbar(
                    radius: Radius.circular(30),
                    thickness: 6,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  child: files2[0] == null
                                      ? InkWell(
                                          onTap: () => img_receipt(0),
                                          child: Icon(
                                            Icons.add_photo_alternate_sharp,
                                            color: Colors.grey[400],
                                            size: size * 0.18,
                                          ),
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () => zoom_img_receipt(0),
                                              child: Container(
                                                decoration: new BoxDecoration(
                                                    color: Colors.white),
                                                alignment: Alignment.center,
                                                height: size * 0.45,
                                                child: Image.file(
                                                  files2[0]!,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: InkWell(
                                                onTap: () {
                                                  delete_receipt_img(0);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(30),
                                                    ),
                                                    color: Colors.white38,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            27, 55, 120, 1.0),

                                                        offset: Offset(0,
                                                            0), // Shadow position
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 22,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                              ],
                            ),
                            SizedBox(width: 50),
                            Column(
                              children: [
                                Container(
                                  child: files2[1] == null
                                      ? InkWell(
                                          onTap: () => img_receipt(1),
                                          child: Icon(
                                            Icons.add_photo_alternate_sharp,
                                            color: Colors.grey[400],
                                            size: size * 0.18,
                                          ),
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () => zoom_img_receipt(1),
                                              child: Container(
                                                decoration: new BoxDecoration(
                                                    color: Colors.white),
                                                alignment: Alignment.center,
                                                height: size * 0.45,
                                                child: Image.file(
                                                  files2[1]!,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: InkWell(
                                                onTap: () {
                                                  delete_receipt_img(1);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(30),
                                                    ),
                                                    color: Colors.white38,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            27, 55, 120, 1.0),

                                                        offset: Offset(0,
                                                            0), // Shadow position
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 22,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget warning_install_end() => Container(
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
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "???????????????????????? ?????????????????????????????????????????????????????????????????????",
                          style: MyConstant().h2_5Style(),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
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
                                controller: warningcontroller,
                                decoration: InputDecoration(
                                  hintText:
                                      "...???????????????????????? ????????????????????????????????????????????????????????????????????? 500 ?????????",
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  //??????????????????????????????
  Widget button_endproduct() => Stack(
        children: [
          Positioned(
            child: Container(
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
              ),
              child: MaterialButton(
                // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // shape: const StadiumBorder(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.save_alt,
                        // size: size * 0.06,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '??????????????????',
                      style: MyConstant().normalwhiteStyle(),
                    ),
                  ],
                ),
                onPressed: () {
                  processendproduct();
                  print("??????????????????");
                },
              ),
            ),
          ),
        ],
      );

  //Widget Status ??????????????????--------------------------------------------------------------------------------------------------------------------------------
  Widget Status_3(size) => Expanded(
        child: SafeArea(
          child: Scrollbar(
            radius: Radius.circular(30),
            thickness: 6,
            // isAlwaysShown: true,
            child: SingleChildScrollView(
              //????????????????????????
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              reverse: false,
              child: Column(
                children: [
                  show_map_install(size),
                  SizedBox(
                    width: double.infinity,
                    height: 10,
                  ),
                  open_google_map_app(size),
                  SizedBox(
                    width: double.infinity,
                    height: 10,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                  showdata_user(size),
                  SizedBox(
                    width: double.infinity,
                    height: 10,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                  showdata_product(size),
                ],
              ),
            ),
          ),
        ),
      );

  //????????????????????????????????????????????????
  Widget button_start() => Stack(
        children: [
          Positioned(
            child: Container(
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
              ),
              child: MaterialButton(
                // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // shape: const StadiumBorder(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.save_alt,
                        // size: size * 0.06,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '??????????????????????????????????????????????????????',
                      style: MyConstant().normalwhiteStyle(),
                    ),
                  ],
                ),
                onPressed: () {
                  if (status_show == "4") {
                    timer.cancel();
                  }
                  submit_product_install();
                },
              ),
            ),
          ),
        ],
      );

  //open_google_map app //????????????????????????????????????????????????????????????????????????
  Widget open_google_map_app(double size) => Container(
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Text(
                              "????????????????????????????????????????????????????????????",
                              style: MyConstant().h2_5Style(),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                // Icon(
                                //   Icons.map_sharp,
                                //   size: size * 0.09,
                                // ),
                                Container(
                                  height: size * 0.09,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      primary: status_go_install == true
                                          ? Color.fromRGBO(27, 55, 120, 1.0)
                                          : Colors.grey[400],
                                    ),
                                    label: Text(
                                      "????????????????????????????????????????????????????????????",
                                      style: MyConstant().normalwhiteStyle(),
                                    ),
                                    icon: Icon(
                                      Icons.assistant_direction_sharp,
                                      size: size * 0.06,
                                    ),
                                    onPressed: () {
                                      if (status_show == "3" &&
                                          status_go_install == true) {
                                        stampLatLng();
                                        stamp();
                                        Notification_api(2);
                                      }
                                      setState(() {
                                        status_go_install = false;
                                      });
                                      // var uri = Uri.parse(
                                      //     "google.navigation:q=$lat,$lng&mode=d");
                                      // launch(uri.toString());
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 35.0, top: 10),
                  //   child: Column(
                  //     children: [
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           ElevatedButton(
                  //             style: ElevatedButton.styleFrom(
                  // primary: status_show == "3"
                  //     ? Color.fromRGBO(27, 55, 120, 1.0)
                  //     : Colors.grey[400],
                  //             ),
                  //             onPressed: () {
                  //               if (status_show == "3") {
                  //                 stampLatLng();
                  //                 stamp();
                  //               }
                  //             },
                  //             child: status_show == "3"
                  //                 ? Text(
                  //                     "???????????????????????????????????????????????????",
                  //                     style: TextStyle(
                  //                       fontFamily: 'Prompt',
                  //                       fontSize: 15,
                  //                     ),
                  //                   )
                  //                 : Text(
                  //                     "?????????????????????????????????????????????????????????????????????????????????",
                  //                     style: TextStyle(
                  //                       fontFamily: 'Prompt',
                  //                       fontSize: 15,
                  //                     ),
                  //                   ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ],
        ),
      );

  Widget show_map_install(size) => Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "??????????????????????????????????????????",
                    style: MyConstant().h2_5Style(),
                  ),
                  InkWell(
                    onTap: () {
                      var uri =
                          Uri.parse("google.navigation:q=$lat,$lng&mode=d");
                      launch(uri.toString());
                    },
                    child: Icon(
                      Icons.map,
                      color: Colors.grey[600],
                      size: size * 0.06,
                    ),
                  ),
                ],
              ),
            ),
            address_install(),
            // Container(
            //   height: MediaQuery.of(context).size.height * 0.50,
            //   width: double.infinity,
            //   child: show_map_status == false
            //       ? Container(
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Text(
            //                 "?????????????????????????????????????????????????????????????????????????????????????????????",
            //                 style: MyConstant().h3Style(),
            //               ),
            //             ],
            //           ),
            //         )
            //       : lat == null
            //           ? ShowProgress()
            //           : GoogleMap(
            //               myLocationEnabled: true,
            //               mapType: MapType.normal,
            //               initialCameraPosition: CameraPosition(
            //                 target: LatLng(
            //                     double.parse('$lat'), double.parse('$lng')),
            //                 zoom: 18,
            //               ),
            //               onMapCreated: (controller) async {},
            //               gestureRecognizers: Set()
            //                 ..add(Factory<EagerGestureRecognizer>(
            //                     () => EagerGestureRecognizer())),
            //               markers: <Marker>[
            //                 Marker(
            //                   markerId: MarkerId('id'),
            //                   position: LatLng(
            //                       double.parse('$lat'), double.parse('$lng')),
            //                   infoWindow: InfoWindow(
            //                     title: '??????????????????????????????????????????',
            //                     // snippet: 'Lat = $lat , lng = $lng',
            //                   ),
            //                 ),
            //               ].toSet(),
            //               onTap: (argument) {},
            //             ),
            // ),
          ],
        ),
      );

  //Widget Status ????????????????????????????????????????????????--------------------------------------------------------------------------------------------------------------------------------
  Widget Status_2(size) => Expanded(
        child: SafeArea(
          child: Scrollbar(
            radius: Radius.circular(30),
            thickness: 6,
            // isAlwaysShown: true,
            child: RefreshIndicator(
              onRefresh: () async {
                getdatauser();
                getdataproduct();
              },
              child: SingleChildScrollView(
                controller: controller,
                //????????????????????????
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Column(
                  children: [
                    check_product_number(size),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    showdata_product(size),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    showdata_user(size),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    show_map(size),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    warning(size),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  //scaner
  Widget check_product_number(double size) => Container(
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
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "??????????????????????????????????????????????????????",
                          style: MyConstant().h2_5Style(),
                        ),
                        Switch(
                          value: isSwitched,
                          onChanged: (value) {
                            setState(() {
                              isSwitched = value;
                            });
                          },
                          activeTrackColor: Colors.lightBlue[200],
                          activeColor: Colors.blue,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Column(
                      children: [
                        if (isSwitched == true) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  _barcode();
                                },
                                child: Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: size * 0.20,
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromRGBO(27, 55, 120, 1.0),
                                ),
                                label: Text(
                                  "????????????",
                                  style: MyConstant().normalwhiteStyle(),
                                ),
                                icon: Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: size * 0.06,
                                ),
                                onPressed: () {
                                  _barcode();
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (show_barcode != null) ...[
                                  Text(
                                    "$show_barcode",
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 15,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          )
                        ],
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );

  //warning
  Widget warning(double size) => Container(
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "????????????????????????",
                          style: MyConstant().h2_5Style(),
                        ),
                        Text(
                          "**?????????????????????????????????????????????!!",
                          style: MyConstant().normalredStyle(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: DropdownButton<String>(
                      hint: Text(
                        "???????????????????????? !!",
                        style: MyConstant().normalStyle(),
                      ),
                      value: dropdownValue,
                      // icon: const Icon(
                      //     Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: MyConstant().h3Style(),

                      underline: Container(
                        height: 2,
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String>[
                        '?????????????????????????????????????????????????????????????????????????????????????????????',
                        '????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????',
                        '?????????????????????????????????????????????????????????????????????????????????'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );

  //????????????????????????????????????????????????????????????
  Widget button_prepare() => Stack(
        children: [
          Positioned(
            child: Container(
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
              ),
              child: MaterialButton(
                // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // shape: const StadiumBorder(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.save_alt,
                        // size: size * 0.06,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '????????????????????????????????????????????????????????????????????????',
                      style: MyConstant().normalwhiteStyle(),
                    ),
                  ],
                ),
                onPressed: () {
                  start_product();
                },
              ),
            ),
          ),
        ],
      );

  //Widget Status ?????????????????? --------------------------------------------------------------------------------------------------------------------------------
  Widget Status_1(size) => Expanded(
        child: SafeArea(
          child: Scrollbar(
            radius: Radius.circular(30),
            thickness: 6,
            // isAlwaysShown: true,
            child: RefreshIndicator(
              onRefresh: () async {
                getdatauser();
                getdataproduct();
              },
              child: SingleChildScrollView(
                controller: controller,
                //????????????????????????
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                reverse: false,
                child: Column(
                  children: [
                    showdata_user(size),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    showdata_product(size),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    show_map(size),
                    SizedBox(
                      width: double.infinity,
                      height: 10,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    time_set(size),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  //????????????????????????????????????????????????
  Widget showdata_user(double size) => Container(
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
                            "????????????????????????????????????",
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
                                  "????????????????????????????????????????????????",
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
                          "?????????????????????",
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
                              "${data_user[0].addressUser} ???.${data_user[0].nameProvinces} ???.${data_user[0].nameAmphures} ???.${data_user[0].nameDistricts} ${data_user[0].zipCode}",
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
                          "????????????????????????????????????????????????????????????",
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

  //????????????????????????????????????????????????
  Widget showdata_product(size) => Container(
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
                        "????????????????????????????????????",
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
                    if (status_show == "2") ...[
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 35.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (data_product[product].checkMachineCode ==
                                data_product[product].machineCode) ...[
                              Text(
                                "?????????????????????????????????????????????????????????????????????????????????",
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 14,
                                  color: Colors.green[400],
                                ),
                                overflow: TextOverflow.fade,
                              ),
                            ] else ...[
                              Text(
                                "???????????????????????????????????????????????????????????????????????????????????????",
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
                    ],
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "?????????????????????????????????  ",
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
                            "????????????????????????????????????  ",
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
                            "????????????????????????????????????  ",
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
                                "????????????????????????????????????",
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
                                    "?????????????????????????????????  ",
                                    style: MyConstant().normalStyle(),
                                  ),
                                  Text(
                                    "????????????${data_product[product].productTypeContract}",
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
                        padding: EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 10.0),
                        child: new Divider()),
                  ],
                ],
              ),
            ),
          ],
        ),
      );

  //?????????????????????????????????????????????
  Widget show_map(size) => Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: Row(
                children: [
                  Text(
                    "??????????????????????????????????????????",
                    style: MyConstant().h2_5Style(),
                  )
                ],
              ),
            ),
            address_install(),
            // Container(
            //   height: MediaQuery.of(context).size.height * 0.40,
            //   width: double.infinity,
            //   child: show_map_status == false
            //       ? Container(
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Text(
            //                 "?????????????????????????????????????????????????????????????????????????????????????????????",
            //                 style: TextStyle(
            //                   fontFamily: 'Prompt',
            //                   fontSize: 15,
            //                   fontWeight: FontWeight.bold,
            //                   color: Colors.grey[600],
            //                 ),
            //               ),
            //             ],
            //           ),
            //         )
            //       : lat == null
            //           ? ShowProgress()
            //           : GoogleMap(
            //               myLocationEnabled: true,
            //               mapType: MapType.normal,
            //               initialCameraPosition: CameraPosition(
            //                 target: LatLng(
            //                     double.parse('$lat'), double.parse('$lng')),
            //                 zoom: 18,
            //               ),
            //               onMapCreated: (controller) async {},
            //               gestureRecognizers: Set()
            //                 ..add(Factory<EagerGestureRecognizer>(
            //                     () => EagerGestureRecognizer())),
            //               markers: <Marker>[
            //                 Marker(
            //                   markerId: MarkerId('id'),
            //                   position: LatLng(
            //                       double.parse('$lat'), double.parse('$lng')),
            //                   infoWindow: InfoWindow(
            //                     title: '??????????????????????????????????????????',
            //                     // snippet: 'Lat = $lat , lng = $lng',
            //                   ),
            //                 ),
            //               ].toSet(),
            //               onTap: (argument) {},
            //             ),
            // ),
          ],
        ),
      );

  Widget button_getproduct() => Stack(
        children: [
          Positioned(
            child: Container(
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
              ),
              child: MaterialButton(
                // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // shape: const StadiumBorder(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.save_alt,
                        // size: size * 0.06,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '???????????????????????????????????????',
                      style: MyConstant().normalwhiteStyle(),
                    ),
                  ],
                ),
                onPressed: () {
                  if (time_start.text.isEmpty || time_end.text.isEmpty) {
                    controller.animateTo(controller.position.maxScrollExtent,
                        duration: Duration(seconds: 1), curve: Curves.easeIn);
                    normalDialog(
                        context, '???????????????????????????', '?????????????????????????????????????????????????????????????????????');
                    myFocusNode.requestFocus();
                  } else {
                    submit_product(
                        context, '??????????????????', '?????????????????????????????????????????????????????????????????????');
                  }
                },
              ),
            ),
          ),
        ],
      );

  Widget time_set(size) => Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    "??????????????????????????????????????????????????????????????????",
                    style: MyConstant().h2_5Style(),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "???????????? ",
                  style: MyConstant().h3Style(),
                ),
                Container(
                  width: size * 0.21,
                  child: TextField(
                    // obscureText: true,
                    focusNode: myFocusNode,
                    decoration: InputDecoration(
                        hintText: '??????. : ???.',
                        contentPadding: const EdgeInsets.all(15.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(5.0))),
                        filled: false),
                    style: MyConstant().h3Style(),
                    controller: time_start,
                    readOnly: true,
                    onTap: () {
                      DatePicker.showTimePicker(context, showTitleActions: true,
                          onConfirm: (time) {
                        setState(() {
                          time_start.text = DateFormat("kk:mm").format(time);
                        });
                      }, currentTime: DateTime.now(), locale: LocaleType.th);
                    },
                  ),
                ),
                Text(
                  " ????????????????????? ",
                  style: MyConstant().h3Style(),
                ),
                Container(
                  width: size * 0.21,
                  child: TextField(
                    focusNode: myFocusNode,
                    decoration: InputDecoration(
                        hintText: '??????. : ???.',
                        contentPadding: const EdgeInsets.all(15.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(5.0))),
                        filled: false),
                    style: MyConstant().h3Style(),
                    controller: time_end,
                    readOnly: true,
                    onTap: () {
                      DatePicker.showTimePicker(context, showTitleActions: true,
                          onConfirm: (time) {
                        setState(() {
                          time_end.text = DateFormat("kk:mm").format(time);
                        });
                      }, currentTime: DateTime.now(), locale: LocaleType.th);
                    },
                  ),
                ),
                Text(
                  " ???. ",
                  style: MyConstant().h3Style(),
                ),
              ],
            ),
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
                  "??????????????????????????????????????? : ${item.addressDeliver} ???.${item.nameProvinces} ???.${item.nameAmphures} ???.${item.nameDistricts} ???????????????????????????????????? ${item.zipCode}",
                  style: MyConstant().normalStyle(),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ],
        ),
      );
}
