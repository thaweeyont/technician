import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician/credit/show_data_job.dart';
import 'package:technician/ipconfig.dart';
import 'package:technician/login.dart';
import 'package:technician/models/jobcheckermodel.dart';
import 'package:http/http.dart' as http;
import 'package:technician/utility/my_constant.dart';

class add_job_checker extends StatefulWidget {
  final String zonestaff, initials_branch, idStaff;
  add_job_checker(this.zonestaff, this.initials_branch, this.idStaff);

  @override
  _add_job_checkerState createState() => _add_job_checkerState();
}

class _add_job_checkerState extends State<add_job_checker> {
  TextEditingController key_idcard = TextEditingController();
  String? selectedValue_branch;
  String? dropdownValue;
  List<JobChecker> add_job_checker = [];
  List dropdown_branch = [];
  List branch_list = [];
  var status_show,
      text_initials_branch,
      text_product_type_contract,
      value_branch,
      id_card_user_key;

  //เรียกใช้ api แสดง งานที่จะรับ
  Future<Null> _getjob_checker(branch, idcard, dropdownValue) async {
    add_job_checker = [];
    if (dropdownValue == "ทั้งหมด") {
      dropdownValue = "";
    }
    try {
      var respose = await http.get(
          Uri.http(ipconfig, '/flutter_api/api_staff/get_job_checker_new.php', {
        "id_card_user": key_idcard.text.toString(),
        "initials_branch": branch.toString(),
        "product_type_contract": dropdownValue,
      }));
      if (respose.statusCode == 200) {
        setState(() {
          add_job_checker = jobCheckerFromJson(respose.body);
        });
      }
    } catch (e) {
      print("===>$e");
    }
  }

  //api dropdown product_type
  Future _dropdown_branch() async {
    var respose = await http
        .get(Uri.http(ipconfig, '/flutter_api/api_staff/dropdown_branch.php'));
    if (respose.statusCode == 200) {
      var jsonData = jsonDecode(respose.body);
      setState(() {
        dropdown_branch = jsonData;
        print(dropdown_branch);
      });
    }
    // print(product_type_list);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dropdown_branch();
    _getjob_checker(widget.initials_branch, '', '');
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
        backgroundColor: MyConstant.dark_f,
        elevation: 0,
        title: Text(
          "ค้นหาข้อมูล",
          style: MyConstant().h2whiteStyle(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          child: Column(
            children: [
              search_id(size),
              filter_b(),
              SizedBox(height: sizeh * 0.02),
              if (add_job_checker.isNotEmpty) ...[
                detail(size),
              ] else ...[
                SizedBox(height: sizeh * 0.1),
                no_data(size, sizeh),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget search_id(size) => Stack(
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
                gradient: LinearGradient(
                    colors: [MyConstant.dark_f, MyConstant.dark_e],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.12,
              child: Container(
                margin:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Container(
                  // margin: EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          style: MyConstant().h3Style(),
                          controller: key_idcard,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "เลขบัตรประจำตัวประชาชน",
                            hintStyle: MyConstant().normalStyle(),
                            border: InputBorder.none,
                          ),
                          onChanged: (String keyword) {
                            // print(keyword);
                            if (selectedValue_branch == null ||
                                selectedValue_branch == "") {
                              _getjob_checker(widget.initials_branch, keyword,
                                  dropdownValue);
                            } else {
                              _getjob_checker(selectedValue_branch!, keyword,
                                  dropdownValue);
                            }
                            // _getproduct(keyword);
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            // SharedPreferences preferences =
                            //     await SharedPreferences.getInstance();

                            // setState(() {
                            //   text_initials_branch =
                            //       preferences.getString('initials_branch');
                            //   text_product_type_contract = "";
                            //   id_card_user_key = key_idcard.text;
                            //   dropdownValue = null;
                            //   selectedValue_branch = null;
                            // });
                            // _getjob_checker(id_card_user_key, '');
                          },
                          icon: Icon(
                            Icons.search,
                            color: Colors.black.withAlpha(120),
                            size: size * 0.06,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget filter_b() => Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    // Text(
                    //   "สาขา : ",
                    //   style: MyConstant().h3Style(),
                    // ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: DropdownButton(
                          isExpanded: true,
                          hint: Text(
                            "สาขา",
                            style: MyConstant().normalStyle(),
                          ),
                          value: selectedValue_branch,
                          items: dropdown_branch.map((branchlist) {
                            return DropdownMenuItem(
                              value: branchlist['initials_branch'],
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
                              // text_initials_branch = selectedValue_branch;
                              // id_card_user_key = key_idcard.text;
                            });
                            if (selectedValue_branch == null ||
                                selectedValue_branch == "") {
                              _getjob_checker(widget.initials_branch,
                                  key_idcard.text.toString(), dropdownValue);
                            } else {
                              _getjob_checker(selectedValue_branch,
                                  key_idcard.text.toString(), dropdownValue);
                            }
                          },
                          underline: Container(
                            height: 1.0,
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.transparent,
                                        width: 0.0))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      "ประเภทสัญญา : ",
                      style: MyConstant().h3Style(),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.68,
                      child: DropdownButton<String>(
                        hint: Text(
                          "สัญญา",
                          style: MyConstant().normalStyle(),
                        ),
                        value: dropdownValue,
                        // icon: const Icon(
                        //     Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: MyConstant().h3Style(),

                        underline: Container(
                          height: 1.0,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.transparent, width: 0.0))),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                            // text_product_type_contract = dropdownValue;
                            // id_card_user_key = key_idcard.text;
                          });
                          if (selectedValue_branch == null ||
                              selectedValue_branch == "") {
                            _getjob_checker(widget.initials_branch,
                                key_idcard.text.toString(), dropdownValue);
                          } else {
                            _getjob_checker(selectedValue_branch,
                                key_idcard.text.toString(), dropdownValue);
                          }
                        },
                        items: <String>['เชื่อ', 'ผ่อน', 'ทั้งหมด']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget detail(size) => SingleChildScrollView(
        // physics: const BouncingScrollPhysics(
        //     parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            for (int i = 0; i < add_job_checker.length; i++) ...[
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: InkWell(
                  onTap: () async {
                    var id_job = add_job_checker[i].idJob;
                    var id_job_gen = add_job_checker[i].idJobHead;

                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) {
                      return show_data_job(id_job, id_job_gen, widget.idStaff);
                    }));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    elevation: 1,
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description,
                                    color: Color.fromRGBO(27, 55, 120, 1.0),
                                    size: size * 0.06,
                                  ),
                                  Text(
                                    " เงิน${add_job_checker[i].productTypeContract}",
                                    style: MyConstant().h2_5Style(),
                                  ),
                                ],
                              ),
                              Text(
                                "${add_job_checker[i].date}",
                                style: MyConstant().normalStyle(),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              // top: 5,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 2,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "เลขบัตรประชาชน : ${add_job_checker[i].idCardUser}",
                                        style: MyConstant().h3Style(),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "ชื่อลูกค้า : ${add_job_checker[i].fullname}",
                                        style: MyConstant().h3Style(),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "พนักงานขาย : ${add_job_checker[i].fullnameStaff}",
                                      style: MyConstant().h3Style(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              )
            ]
          ],
        ),
      );

  Widget no_data(size, sizeh) => Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: size * 0.20,
              color: Colors.grey[400],
            ),
            Text(
              "ไม่มีข้อมูล",
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
}
// SingleChildScrollView