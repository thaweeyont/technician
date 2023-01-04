import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/mechanic/detail_add_job_mechanic.dart';
import 'package:technician/models/list_addjob_mechanicmodal.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:http/http.dart' as http;

class AddJobMechanic extends StatefulWidget {
  final id_branch;
  AddJobMechanic(this.id_branch);

  @override
  _AddJobMechanicState createState() => _AddJobMechanicState();
}

class _AddJobMechanicState extends State<AddJobMechanic> {
  String? selectedValue_branch, text_initials_branch;
  List dropdown_branch = [];
  List<ListAddjobMechanicmodal> datajob = [];

  TextEditingController username_text = TextEditingController();
  TextEditingController userphone_text = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dropdown_branch();
    _getJob(widget.id_branch, '', '');
  }

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

  //ข้อมูลงานติดต้ง
  Future<Null> _getJob(id_branch, username, userphone) async {
    datajob = [];
    try {
      var respose = await http.get(
          Uri.http(ipconfig, '/flutter_api/api_staff/get_job_mechanic.php', {
        "id_branch": id_branch,
        "username": username,
        "userphone": userphone,
      }));
      // print(respose.body);
      if (respose.statusCode == 200) {
        setState(() {
          datajob = listAddjobMechanicmodalFromJson(respose.body);
        });
      }
    } catch (e) {
      // print("ไม่มีข้อมูล");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
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
            "รายการงานติดตั้ง",
            style: MyConstant().h2whiteStyle(),
          ),
        ),
        body: Column(
          children: [
            header(size),
            title_list(),
            listdata(),
          ],
        ));
  }

  Expanded listdata() {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            for (var item in datajob) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) {
                      return DetailAddJobMechanic(item.idJobHead);
                    }));
                  },
                  child: Card(
                    elevation: 3,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                  "วันที่ส่ง ${item.dateinput} ช่วง${item.dateGotoSt}",
                                  style: MyConstant().mini())
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "ชื่อ : ${item.fullname}",
                                        style: MyConstant().h3Style(),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "เบอร์โทร : ${item.phoneUser}",
                                        style: MyConstant().h3Style(),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "วันที่ขาย : ${DateFormat('dd-MM-yyyy').format(DateTime.parse(item.cratedDate.toString()))}",
                                        style: MyConstant().h3Style(),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.arrow_forward_ios_rounded,
                                      color: MyConstant.dark_f)
                                ],
                              ),
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
        ),
      ),
    );
  }

  Container title_list() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "รายการทั้งหมด",
            style: MyConstant().normalStyle(),
          ),
          Text(
            "${datajob.length} รายการ",
            style: MyConstant().h3Style(),
          )
        ],
      ),
    );
  }

  //header
  Widget header(size) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
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
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                search_username(),
                search_userphone(),
                filtter_branch()
              ],
            ),
          ),
        ],
      );

  Container filtter_branch() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Container(
          //   margin: EdgeInsets.symmetric(vertical: 5),
          //   child: Row(
          //     children: [Text("สาขา", style: MyConstant().h2_5whiteStyle())],
          //   ),
          // ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.80,
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
                    });
                    _getJob(selectedValue_branch, username_text.text,
                        username_text.text);
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
    );
  }

  Container search_username() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                style: MyConstant().h3Style(),
                controller: username_text,
                // keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "ชื่อลูกค้า",
                  hintStyle: MyConstant().normalStyle(),
                  border: InputBorder.none,
                ),
                onChanged: (String keyword) {
                  print(keyword);
                  if (selectedValue_branch == null ||
                      selectedValue_branch == "null") {
                    _getJob(widget.id_branch, keyword, username_text.text);
                  } else {
                    _getJob(selectedValue_branch, keyword, username_text.text);
                  }
                },
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search,
                  color: Colors.black.withAlpha(120),
                )),
          ],
        ),
      ),
    );
  }

  Container search_userphone() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                style: MyConstant().h3Style(),
                controller: userphone_text,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "เบอร์โทรลูกค้า",
                  hintStyle: MyConstant().normalStyle(),
                  border: InputBorder.none,
                ),
                onChanged: (String keyword) {
                  if (selectedValue_branch == null ||
                      selectedValue_branch == "null") {
                    _getJob(widget.id_branch, userphone_text.text, keyword);
                  } else {
                    _getJob(selectedValue_branch, userphone_text.text, keyword);
                  }
                },
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search,
                  color: Colors.black.withAlpha(120),
                )),
          ],
        ),
      ),
    );
  }
}
