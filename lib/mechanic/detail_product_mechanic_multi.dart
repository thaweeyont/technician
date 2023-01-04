import 'package:flutter/material.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/product_list_job_mechanicmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

class DetailProductMechanicMulti extends StatefulWidget {
  final idJobHead;
  DetailProductMechanicMulti(this.idJobHead);

  @override
  _DetailProductMechanicMultiState createState() =>
      _DetailProductMechanicMultiState();
}

class _DetailProductMechanicMultiState
    extends State<DetailProductMechanicMulti> {
  List<ProductListJobMechanic> data_product = [];
  TextEditingController value_code = TextEditingController();
  var num;
  var count_c = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdataproduct();
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
          num = data_product.length;
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "รายการสินค้า",
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
      body: data_product.isEmpty
          ? WillPopScope(
              child: Center(child: CircularProgressIndicator()),
              onWillPop: () async {
                return false;
              },
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                children: [
                  title_page(),
                  list_product(),
                  button_get(),
                ],
              ),
            ),
    );
  }

  Container list_product() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      width: double.infinity,
      color: Colors.white,
      child: Form(
        // key: _formKey,
        child: Column(
          children: [
            for (int c = 0; c < count_c; c++) ...[
              Row(
                children: [
                  Text("ประเภท : ", style: MyConstant().normalStyle()),
                  Text("${data_product[c].productType}",
                      style: MyConstant().h3Style())
                ],
              ),
              Row(
                children: [
                  Text("แบรนด์ : ", style: MyConstant().normalStyle()),
                  Text("${data_product[c].productBrand}",
                      style: MyConstant().h3Style())
                ],
              ),
              Row(
                children: [
                  Text("รายละเอียด : ", style: MyConstant().normalStyle()),
                  Flexible(
                      child: Text(
                    "${data_product[c].productDetail}",
                    style: MyConstant().h3Style(),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ))
                ],
              ),
              if (data_product[c].productPrice == "") ...[
                for (int i = 0;
                    i < int.parse(data_product[c].productCount.toString());
                    i++) ...[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text("เลขเครื่อง : ",
                            style: MyConstant().normalStyle()),
                        Expanded(
                          child: TextFormField(
                            maxLength: 6,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณาเพิ่ม เลขเครื่อง';
                              }
                              return null;
                            },
                            style: MyConstant().h3Style(),
                            // controller: code[i],
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.qr_code_2),
                              labelText: "เลข 6 ตัวท้าย",
                              labelStyle: MyConstant().normalStyle(),
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(5.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                for (int i = 0;
                    i < int.parse(data_product[c].productPrice.toString());
                    i++) ...[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text("เลขเครื่อง : ",
                            style: MyConstant().normalStyle()),
                        Expanded(
                          child: TextFormField(
                            maxLength: 6,
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'กรุณาเพิ่ม เลขเครื่อง';
                            //   }
                            //   return null;
                            // },
                            style: MyConstant().h3Style(),
                            controller: value_code,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.qr_code_2),
                              labelText: "เลข 6 ตัวท้าย",
                              labelStyle: MyConstant().normalStyle(),
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(5.0),
                                ),
                              ),
                            ),
                            onChanged: (key) {
                              print("=====>$key");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              underline(),
            ],
          ],
        ),
      ),
    );
  }

  Container title_page() {
    return Container(
      padding:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [Text("ข้อมูลสินค้า", style: MyConstant().h2_5Style())],
          )
        ],
      ),
    );
  }

  Padding underline() {
    return Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
        child: new Divider());
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
          'บันทึกข้อมูลงานติดตั้ง',
          style: MyConstant().normalwhiteStyle(),
        ),
        onPressed: () {
          print(value_code.text);
          // if (_formKey.currentState!.validate()) {
          //   showProgressDialog(context);
          //   if (data_product[0].productPrice == "") {
          //     setState(() {
          //       max_count = data_product[0].productCount;
          //       process_get(max_count);
          //     });
          //   } else {
          //     setState(() {
          //       max_count = data_product[0].productPrice;
          //       process_get(max_count);
          //     });
          //   }

          //   // print("value ====> ${code[0].text}");
          // }
        },
      ),
    );
  }
}
