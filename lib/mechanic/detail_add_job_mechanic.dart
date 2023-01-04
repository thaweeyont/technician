import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/mechanic/detail_product_mechanic.dart';
import 'package:technician/mechanic/detail_product_mechanic_multi.dart';
import 'package:technician/models/detail_mechanicmodel.dart';
import 'package:technician/models/job_log_addressmodel.dart';
import 'package:technician/models/product_list_job_mechanicmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DetailAddJobMechanic extends StatefulWidget {
  final idJobHead;
  DetailAddJobMechanic(this.idJobHead);

  @override
  _DetailAddJobMechanicState createState() => _DetailAddJobMechanicState();
}

class _DetailAddJobMechanicState extends State<DetailAddJobMechanic> {
  List<DetailMechanicmodel> data_user = [];
  List<ProductListJobMechanic> data_product = [];
  List<JobLogAddress> address_history = [];
  var amount;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdatauser();
    _getAddress();
    getdataproduct();
  }

  //แสดงข้อมูลลูกค้า
  void getdatauser() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/detail_mechanic.php',
          {"id_gen_job": widget.idJobHead}));
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
          ipconfig,
          '/flutter_api/api_staff/product_list_job_mechanic.php',
          {"idjob": widget.idJobHead}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        setState(() {
          data_product = productListJobMechanicFromJson(respose.body);
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  //เรียกใช้ api แสดง สถานที่ติดตั้ง
  void _getAddress() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/get_job_log_address.php',
          {"gen_id_job": widget.idJobHead}));
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "รายละเอียด",
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
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            datauser(size),
            underline(),
            dataproduct(),
            underline(),
            address_install(),
            // button_get(),
          ],
        ),
      ),
    );
  }

  Container button_get() {
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
          'เลือกทั้งหมด',
          style: MyConstant().normalwhiteStyle(),
        ),
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return DetailProductMechanicMulti(widget.idJobHead);
          })).then((value) => getdataproduct());
        },
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

  Container dataproduct() {
    return Container(
      padding:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ข้อมูลสินค้า", style: MyConstant().h2_5Style()),
              Text("เลือกรับสินค้า", style: MyConstant().normalStyle()),
            ],
          ),
          for (var item in data_product) ...[
            if (item.productPrice != "0") ...[
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: InkWell(
                  onTap: () {
                    if (item.productPrice == "") {
                      setState(() {
                        amount = int.parse(item.productCount.toString());
                        get_product_dialog(
                            amount, item.idProduct, item.idJobHead);
                        // print(amount);
                      });
                    } else {
                      amount = int.parse(item.productPrice.toString());
                      get_product_dialog(
                          amount, item.idProduct, item.idJobHead);
                      // print(amount);
                    }
                  },
                  child: Card(
                    elevation: 3,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("ประเภท : ",
                                          style: MyConstant().normalStyle()),
                                      Text("${item.productType}",
                                          style: MyConstant().h3Style())
                                    ],
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  if (item.productPrice == "") ...[
                                    Text("x ${item.productCount}",
                                        style: MyConstant().h3Style())
                                  ] else ...[
                                    Text("x ${item.productPrice}",
                                        style: MyConstant().h3Style())
                                  ],
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("แบรนด์ : ",
                                  style: MyConstant().normalStyle()),
                              Text("${item.productBrand}",
                                  style: MyConstant().h3Style())
                            ],
                          ),
                          Row(
                            children: [
                              Text("รายละเอียด : ",
                                  style: MyConstant().normalStyle()),
                              Flexible(
                                child: Text(
                                  "${item.productDetail}",
                                  style: MyConstant().h3Style(),
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ],
        ],
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

  SizedBox underline() {
    return SizedBox(
      width: double.infinity,
      height: 10,
      child: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
      ),
    );
  }

  Future<Null> get_product_dialog(
      amount, String? idProduct, String? idJobHead) async {
    var mediaQuery = MediaQuery.of(context);
    double size = MediaQuery.of(context).size.width;
    double sizeh = MediaQuery.of(context).size.height;
    var amount_2 = amount;
    showAnimatedDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(25),
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
                                  "จำนวนสินค้าที่นำไปติดตั้ง ",
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
                            margin: EdgeInsets.symmetric(vertical: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      amount = amount + 1;
                                    });
                                    if (amount > amount_2) {
                                      setState(() {
                                        amount = amount_2;
                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.add_circle,
                                    size: size * 0.08,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  amount.toString(),
                                  style: MyConstant().h1Style(),
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
                          Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 15, bottom: 10),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: MyConstant.dark_f,
                              ),
                              label: Text(
                                "บันทึกข้อมูลจำนวนสินค้า",
                                style: MyConstant().normalwhiteStyle(),
                              ),
                              icon: Icon(Icons.add_shopping_cart_rounded),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    CupertinoPageRoute(builder: (context) {
                                  return DetailProductMechanic(
                                      idJobHead, idProduct, amount);
                                })).then((value) => getdataproduct());
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
}
