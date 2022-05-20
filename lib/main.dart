import 'package:avarias/pages/prevenda_home.dart';
import 'package:avarias/pages/product_edit2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avarias/pages/home.dart';
import 'package:avarias/pages/keyboard.dart';
import 'package:avarias/pages/login.dart';
import 'package:avarias/pages/product_edit.dart';
import 'package:avarias/pages/scanner.dart';
import 'package:avarias/pages/splashScreen.dart';
import 'package:avarias/services/routes.dart';

final ThemeData kDefaultTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.greenAccent[700]
);

void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void main() {
  runApp(MaterialApp(
    title: 'Avarias',
    theme: kDefaultTheme,
    initialRoute: Routes.SPLESHSCREEN,
    debugShowCheckedModeBanner: false,
    routes: {
      Routes.SPLESHSCREEN: (context) => SplashScreenWidget(),
      Routes.LOGIN: (context) => Login(),
      Routes.HOME: (context) => Home(),
      Routes.PREVENDA: (context) => PrevendaHome(),
      Routes.SCANNER: (context) => Scanner(),
      Routes.PRODUCTEDIT: (context) => ProductEdit(),
      Routes.PRODUCTEDIT2: (context) => ProductEdit2(),
      Routes.KEYBOARD: (context) => Keyboard(),
    },
  ));
  _portraitModeOnly();
}
