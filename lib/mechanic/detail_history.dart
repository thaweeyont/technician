import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:technician/ipconfig.dart';
import 'package:technician/models/detail_product.dart';
import 'package:technician/models/detailhistory.dart';

class Detail_history extends StatefulWidget {
  final idjob, idproduct_joblog;

  Detail_history(this.idjob, this.idproduct_joblog);

  @override
  _Detail_historyState createState() => _Detail_historyState();
}

class _Detail_historyState extends State<Detail_history> {
  List<DetailHistory> datadetail = [];
  List<DetailProduct> datadetailproduct = [];

  //function select data
  Future<void> _getdetail() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_mechanic/detail_history.php',
          {"idjob": widget.idjob}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล");
      }

      setState(() {
        datadetail = detailHistoryFromJson(respose.body);
      });
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  Future<void> detailproduct() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_mechanic/product_detail.php',
          {"idproduct_joblog": widget.idproduct_joblog}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        print("มีข้อมูล");
      }

      setState(() {
        datadetailproduct = detailProductFromJson(respose.body);
      });
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getdetail();
    detailproduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(27, 55, 120, 1.0),
        elevation: 0,
        title: Text(
          "รายละเอียด",
          style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          Stack(
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
                    color: Color.fromRGBO(27, 55, 120, 1.0),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.02,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                for (var i = 0; i < datadetail.length; i++) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0,
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "  ข้อมูลลูกค้า",
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 15,
                                      color: Color.fromRGBO(27, 55, 120, 1.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "ชื่อ-สกุล : ${datadetail[i].fullname}",
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "วันที่ติดตั้ง : ${datadetail[i].date}",
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "สถานที่ติดตั้ง : ${datadetail[i].addressGoProduct}",
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0,
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "  ข้อมูลสินค้า",
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 15,
                                      color: Color.fromRGBO(27, 55, 120, 1.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
                                for (var c = 0;
                                    c < datadetailproduct.length;
                                    c++) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "ประเภทสินค้า : ${datadetailproduct[c].productType}",
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "ข้อมูลสินค้า : ${datadetailproduct[c].detailProduct}",
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "จำนวน : ${datadetailproduct[c].countProduct} เครื่อง",
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color.fromRGBO(27, 55, 120, 1.0),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0,
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "  ภาพงานติดตั้ง",
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 15,
                                      color: Color.fromRGBO(27, 55, 120, 1.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
                                Image.network(
                                  "http://110.164.131.46/flutter_api/mechanic_success_work/${datadetail[i].imgNamePath}",
                                  width:
                                      MediaQuery.of(context).size.width * 1.20,
                                  height:
                                      MediaQuery.of(context).size.width * 1.20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}
