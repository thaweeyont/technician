import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:technician/utility/my_constant.dart';

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
    duration: Duration(seconds: 1),
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
