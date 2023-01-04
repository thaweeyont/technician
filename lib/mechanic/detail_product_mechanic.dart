import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/dialog/dialog.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/product_list_job_mechanicmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

class DetailProductMechanic extends StatefulWidget {
  final idJobHead, idProduct, amount;
  DetailProductMechanic(this.idJobHead, this.idProduct, this.amount);

  @override
  _DetailProductMechanicState createState() => _DetailProductMechanicState();
}

class _DetailProductMechanicState extends State<DetailProductMechanic> {
  var count_box, max_count, idStaff;
  List<TextEditingController> code = [];
  List<ProductListJobMechanic> data_product = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_idstaff();
    for (int i = 0; i < int.parse(widget.amount.toString()); i++) {
      code.add(TextEditingController());
    }
    getdataproduct();
  }

  //รับ idstaff
  void get_idstaff() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idStaff = preferences.getString('idStaff');
    });
  }

  //แสดงข้อมูลสินค้า
  void getdataproduct() async {
    try {
      var respose = await http.get(Uri.http(
          ipconfig, '/flutter_api/api_staff/product_list_job_mechanic_s.php', {
        "idjob": widget.idJobHead,
        "idproduct": widget.idProduct,
      }));
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

  //หาจำนวนคงเหลือ
  void process_get(max_count) async {
    var result =
        int.parse(max_count.toString()) - int.parse(widget.amount.toString());
    insert_job_mechanic(result);
  }

  void insert_job_mechanic(result) async {
    for (int i = 0; i < int.parse(widget.amount.toString()); i++) {
      var uri = Uri.parse(
          "http://110.164.131.46/flutter_api/api_staff/insert_job_mechanic.php");
      var request = new http.MultipartRequest("POST", uri);
      request.fields['idProduct'] = widget.idProduct;
      request.fields['idJobHead'] = widget.idJobHead;
      request.fields['idStaff'] = idStaff;
      request.fields['code'] = code[i].text;
      // request.fields['result'] = result.toString();
      var response = await request.send();
      if (response.statusCode == 200) {
        print("เพิ่มข้อมูลสำเร็จ");
      } else {
        print("ไม่สำเร็จ");
      }
    }
    updatedata(result);
  }

  //ปรับสต็อคสินค้า
  void updatedata(result) async {
    var uri = Uri.parse(
        "http://110.164.131.46/flutter_api/api_staff/update_job_mechanic.php");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['idProduct'] = widget.idProduct;
    request.fields['idJobHead'] = widget.idJobHead;
    request.fields['result'] = result.toString();
    var response = await request.send();
    if (response.statusCode == 200) {
      print("ปรับสต็อคสินค้าสำเร็จ");
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      print("ปรับสต็อคสินค้าไม่สำเร็จ");
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
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
      ),
    );
  }

  Container list_product() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      width: double.infinity,
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            for (var item in data_product) ...[
              Row(
                children: [
                  Text("ประเภท : ", style: MyConstant().normalStyle()),
                  Text("${item.productType}", style: MyConstant().h3Style())
                ],
              ),
              Row(
                children: [
                  Text("แบรนด์ : ", style: MyConstant().normalStyle()),
                  Text("${item.productBrand}", style: MyConstant().h3Style())
                ],
              ),
              Row(
                children: [
                  Text("รายละเอียด : ", style: MyConstant().normalStyle()),
                  Flexible(
                      child: Text(
                    "${item.productDetail}",
                    style: MyConstant().h3Style(),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ))
                ],
              ),
            ],
            for (int i = 0; i < int.parse(widget.amount.toString()); i++) ...[
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Text("เลขเครื่อง : ", style: MyConstant().normalStyle()),
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
                        controller: code[i],
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
            underline(),
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
          if (_formKey.currentState!.validate()) {
            showProgressDialog(context);
            if (data_product[0].productPrice == "") {
              setState(() {
                max_count = data_product[0].productCount;
                process_get(max_count);
              });
            } else {
              setState(() {
                max_count = data_product[0].productPrice;
                process_get(max_count);
              });
            }

            // print("value ====> ${code[0].text}");
          }
        },
      ),
    );
  }
}
