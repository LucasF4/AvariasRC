import 'package:flutter/material.dart';
import 'package:avarias/pages/login.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashScreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //double screenWidth = MediaQuery.of(context).size.width; 
    return Stack(
      children: <Widget>[
        SplashScreen(
          seconds: 3,
          navigateAfterSeconds: Login(),
          backgroundColor: Colors.white,
          loaderColor: Theme.of(context).primaryColor,
        ),
        Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.asset(
              'assets/images/logo.png',
              height: 130.0,
            ),
          ),
        )
      ]
    );
  }
}
