import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:technician/utility/my_constant.dart';
import 'package:loading_gifs/loading_gifs.dart';

Future<Null> showProgressDialog(BuildContext context) async {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    // Color.fromRGBO(230, 230, 230, 0.3),
    builder: (context) => WillPopScope(
      child: Center(child: CircularProgressIndicator()),
      onWillPop: () async {
        return false;
      },
    ),
  );
}

Future<void> showProgressLoading(BuildContext context) async {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) => Center(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 24, 24, 24).withOpacity(0.9),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(cupertinoActivityIndicator, scale: 4),
            // Text(
            //   'Loading...',
            //   style: MyConstant().textLoading(),
            // ),
          ],
        ),
      ),
    ),
  );
}

Future<Null> normalDialog(
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
          leading: Image.asset('images/error_log.gif'),
          title: Text(title, style: MyConstant().h2_5Style()),
          subtitle: Text(message, style: MyConstant().normalStyle()),
        ),
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Column(
              children: [
                Text("ตกลง", style: MyConstant().h3Style()),
              ],
            ),
          ),
        ],
      ),
    ),
    animationType: DialogTransitionType.fadeScale,
    curve: Curves.fastOutSlowIn,
    duration: Duration(seconds: 0),
  );
}

Future<Null> successDialog(
    BuildContext context, String title, String message) async {
  showDialog(
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
          title: Text(title, style: MyConstant().h2_5Style()),
          subtitle: Text(message, style: MyConstant().normalStyle()),
        ),
        children: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Column(
                children: [
                  Text("ตกลง", style: MyConstant().h3Style()),
                ],
              )),
        ],
      ),
    ),
  );
}

Future<Null> alertLocationService(
    BuildContext context, String title, String message) async {
  showDialog(
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
          leading: Image.asset('images/error_pin.gif'),
          title: Text(title, style: MyConstant().h2_5Style()),
          subtitle: Text(
            message,
            style: MyConstant().normalStyle(),
          ),
        ),
        children: [
          TextButton(
            onPressed: () async {
              // Navigator.pop(context);
              await Geolocator.openLocationSettings();
              exit(0);
            },
            child: Column(
              children: [
                Text(
                  "ตกลง",
                  style: MyConstant().h3Style(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<Null> pinlDialog(
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
          leading: Image.asset('images/error_pin.gif'),
          title: Text(
            title,
            style: MyConstant().h2_5Style(),
          ),
          subtitle: Text(
            message,
            style: MyConstant().normalStyle(),
          ),
        ),
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Column(
              children: [
                Text(
                  "ตกลง",
                  style: MyConstant().h3Style(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    animationType: DialogTransitionType.fadeScale,
    curve: Curves.fastOutSlowIn,
    duration: Duration(seconds: 1),
  );
}
