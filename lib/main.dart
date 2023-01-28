import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technician/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MyColors.navy,
      ),
      home: Login(),
    );
  }
}

class MyColors {
  static const MaterialColor navy = MaterialColor(
    0xFF1b3778,
    <int, Color>{
      50: Color(0xFF1b3778),
      100: Color(0xFF1b3778),
      200: Color(0xFF1b3778),
      300: Color(0xFF1b3778),
      400: Color(0xFF1b3778),
      500: Color(0xFF1b3778),
      600: Color(0xFF1b3778),
      700: Color(0xFF1b3778),
      800: Color(0xFF1b3778),
      900: Color(0xFF1b3778),
    },
  );
}
