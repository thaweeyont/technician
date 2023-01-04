import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:technician/admin_mechanic/detail_mechanic.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/models/jobmodel.dart';
import 'package:technician/models/list_data_mechanicmodel.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

class HomeMechanic extends StatefulWidget {
  final idBranch;
  HomeMechanic(this.idBranch);

  @override
  _HomeMechanicState createState() => _HomeMechanicState();
}

class _HomeMechanicState extends State<HomeMechanic> {
  String? selectedValue_branch, text_initials_branch, id_branch;
  List dropdown_branch = [];
  List<ListDataMechanic> datajob = [];
  //สาขา
  Future _dropdown_branch() async {
    var respose = await http
        .get(Uri.http(ipconfig, '/flutter_api/api_staff/dropdown_branch.php'));
    if (respose.statusCode == 200) {
      var jsonData = jsonDecode(respose.body);
      setState(() {
        dropdown_branch = jsonData;
        // print(dropdown_branch);
      });
    }
  }

  //function select data
  Future<Null> _getJob(id_branch) async {
    datajob = [];
    try {
      var respose = await http.get(Uri.http(
          ipconfig,
          '/flutter_api/api_staff/list_data_mechanic.php',
          {"id_branch": id_branch}));
      // print(respose.body);
      if (respose.statusCode == 200) {
        setState(() {
          datajob = listDataMechanicFromJson(respose.body);
        });
      }
    } catch (e) {
      print("ไม่มีข้อมูล mec");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dropdown_branch();
    _getJob(widget.idBranch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "ข้อมูลช่างติดตั้ง",
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
        margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              filtter_branch(context),
              title_page(),
              data_detail_mechanic(),
            ],
          ),
        ),
      ),
    );
  }

  Container title_page() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Text("ช่างที่ดำเนินงานอยู่", style: MyConstant().normalStyle())
        ],
      ),
    );
  }

  Row filtter_branch(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.width * 0.11,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1.0,
                      style: BorderStyle.solid,
                      color: MyConstant.dark),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.9,
              child: DropdownButton(
                isExpanded: true,
                hint: Text(
                  "สาขา",
                  style: MyConstant().normalStyle(),
                ),
                value: selectedValue_branch,
                items: dropdown_branch.map((branchlist) {
                  return DropdownMenuItem(
                    value: branchlist['id_branch'],
                    child: Text(
                      branchlist['name_branch'],
                      style: MyConstant().h3Style(),
                      overflow: TextOverflow.clip,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue_branch = value as String?;
                    text_initials_branch = selectedValue_branch;
                    _getJob(selectedValue_branch);
                  });
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
    );
  }

  SingleChildScrollView data_detail_mechanic() {
    return SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Column(
        children: [
          for (var item in datajob) ...[
            InkWell(
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) {
                  return DetailMechanic(
                      item.idGenJob,
                      item.idStaff,
                      item.statusData,
                      item.dateGo,
                      item.latData,
                      item.lngData,
                      item.idData);
                })).then((value) => _getJob(widget.idBranch));
              },
              child: Card(
                // margin: EdgeInsets.only(bottom: 18),
                elevation: 4,
                color: Colors.grey[200],
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          status_icon(item),
                          Row(
                            children: [
                              Text("รหัสช่าง : ${item.idStaff}",
                                  style: MyConstant().h3Style())
                            ],
                          ),
                          Row(
                            children: [
                              Text("ชื่อช่าง : ${item.fullnameStaff}",
                                  style: MyConstant().h3Style())
                            ],
                          ),
                          text_status(item)
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: MyConstant.dark_f)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ],
      ),
    );
  }

  Row status_icon(ListDataMechanic item) {
    return Row(
      children: [
        if (item.statusData == "1") ...[
          Icon(
            Icons.circle,
            color: Colors.grey,
          ),
        ] else ...[
          Icon(
            Icons.circle,
            color: Colors.green,
          ),
        ],
      ],
    );
  }

  Row text_status(ListDataMechanic item) {
    return Row(
      children: [
        if (item.statusData == "1") ...[
          Text("สถานะ : ยังไม่ได้รับงาน", style: MyConstant().h3Style())
        ],
        if (item.statusData == "2") ...[
          Text("สถานะ : รับงานแล้ว", style: MyConstant().h3Style())
        ],
        if (item.statusData == "3") ...[
          Text("สถานะ : จัดเตรียมสินค้า", style: MyConstant().h3Style())
        ],
        if (item.statusData == "4") ...[
          Text("สถานะ : จัดส่งสินค้า", style: MyConstant().h3Style())
        ],
        if (item.statusData == "5") ...[
          Text("สถานะ : ติดตั้งสินค้า", style: MyConstant().h3Style())
        ],
      ],
    );
  }
}
